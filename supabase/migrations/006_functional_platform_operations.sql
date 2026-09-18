-- Incremental secure mutations for the existing platform tables.
alter table public.daily_tasks add column if not exists target integer not null default 1;
alter table public.achievements add column if not exists target integer not null default 1;
alter table public.user_achievements add column if not exists claimed_at timestamptz;
alter table public.vip_levels add column if not exists cost_coins bigint not null default 0;
alter table public.user_vip add column if not exists progress bigint not null default 0;
alter table public.user_vip add column if not exists updated_at timestamptz not null default now();

create table if not exists public.vip_purchases (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  vip_level_id uuid not null references public.vip_levels(id),
  idempotency_key text not null unique,
  price_coins bigint not null,
  created_at timestamptz not null default now()
);
alter table public.vip_purchases enable row level security;
drop policy if exists vip_purchases_own_select on public.vip_purchases;
create policy vip_purchases_own_select on public.vip_purchases for select to authenticated using (user_id = auth.uid());

create or replace function public.claim_daily_task(target_task uuid)
returns public.daily_task_progress language plpgsql security definer set search_path = public as $$
declare claimant uuid := auth.uid(); task public.daily_tasks; result public.daily_task_progress;
begin
  if claimant is null then raise exception 'Authentication required'; end if;
  select * into task from public.daily_tasks where id = target_task and active;
  if task.id is null then raise exception 'Task unavailable'; end if;
  insert into public.daily_task_progress(user_id, task_id, task_date, progress)
    values (claimant, task.id, current_date, 0)
    on conflict (user_id, task_id, task_date) do nothing;
  select * into result from public.daily_task_progress
    where user_id = claimant and task_id = task.id and task_date = current_date for update;
  if result.claimed_at is not null then return result; end if;
  if result.progress < task.target then raise exception 'Task is not complete'; end if;
  update public.wallets set balance = balance + task.reward_coins, updated_at = now() where user_id = claimant;
  insert into public.wallet_transactions(wallet_id, type, amount, description)
    select id, 'adjustment', task.reward_coins, 'Daily task reward' from public.wallets where user_id = claimant;
  update public.daily_task_progress set claimed_at = now()
    where user_id = claimant and task_id = task.id and task_date = current_date returning * into result;
  return result;
end;
$$;
revoke all on function public.claim_daily_task(uuid) from public, anon;
grant execute on function public.claim_daily_task(uuid) to authenticated;

create or replace function public.claim_achievement_reward(target_achievement uuid)
returns public.user_achievements language plpgsql security definer set search_path = public as $$
declare claimant uuid := auth.uid(); achievement public.achievements; result public.user_achievements;
begin
  if claimant is null then raise exception 'Authentication required'; end if;
  select * into achievement from public.achievements where id = target_achievement;
  if achievement.id is null then raise exception 'Achievement unavailable'; end if;
  select * into result from public.user_achievements where user_id = claimant and achievement_id = achievement.id for update;
  if result.user_id is null then raise exception 'Achievement is not complete'; end if;
  if result.claimed_at is not null then return result; end if;
  update public.wallets set balance = balance + achievement.reward_coins, updated_at = now() where user_id = claimant;
  insert into public.wallet_transactions(wallet_id, type, amount, description)
    select id, 'adjustment', achievement.reward_coins, 'Achievement reward' from public.wallets where user_id = claimant;
  update public.user_achievements set claimed_at = now()
    where user_id = claimant and achievement_id = achievement.id returning * into result;
  return result;
end;
$$;
revoke all on function public.claim_achievement_reward(uuid) from public, anon;
grant execute on function public.claim_achievement_reward(uuid) to authenticated;

create or replace function public.purchase_vip(target_level uuid, request_key text)
returns public.user_vip language plpgsql security definer set search_path = public as $$
declare buyer uuid := auth.uid(); level_row public.vip_levels; current_row public.user_vip; wallet_row public.wallets; result public.user_vip;
begin
  if buyer is null then raise exception 'Authentication required'; end if;
  if request_key is null or length(trim(request_key)) = 0 then raise exception 'Idempotency key required'; end if;
  select vip_level_id into current_row from public.user_vip where user_id = buyer;
  if exists (select 1 from public.vip_purchases where idempotency_key = request_key) then
    select * into result from public.user_vip where user_id = buyer; return result;
  end if;
  select * into level_row from public.vip_levels where id = target_level;
  if level_row.id is null then raise exception 'VIP level unavailable'; end if;
  if current_row.vip_level_id is not null and exists (select 1 from public.vip_levels old where old.id = current_row.vip_level_id and old.level >= level_row.level) then raise exception 'VIP level already owned'; end if;
  select * into wallet_row from public.wallets where user_id = buyer for update;
  if wallet_row.balance < level_row.cost_coins then raise exception 'Insufficient virtual coins'; end if;
  update public.wallets set balance = balance - level_row.cost_coins, updated_at = now() where id = wallet_row.id;
  insert into public.wallet_transactions(wallet_id, type, amount, description) values (wallet_row.id, 'adjustment', -level_row.cost_coins, 'VIP upgrade');
  insert into public.vip_purchases(user_id, vip_level_id, idempotency_key, price_coins) values (buyer, level_row.id, request_key, level_row.cost_coins);
  insert into public.user_vip(user_id, vip_level_id, progress, updated_at) values (buyer, level_row.id, 0, now())
    on conflict (user_id) do update set vip_level_id = excluded.vip_level_id, progress = 0, updated_at = now();
  select * into result from public.user_vip where user_id = buyer; return result;
end;
$$;
revoke all on function public.purchase_vip(uuid, text) from public, anon;
grant execute on function public.purchase_vip(uuid, text) to authenticated;

create or replace function public.equip_mall_item(target_inventory uuid)
returns public.user_inventory language plpgsql security definer set search_path = public as $$
declare owner_id uuid := auth.uid(); selected public.user_inventory; result public.user_inventory;
begin
  select * into selected from public.user_inventory where id = target_inventory and user_id = owner_id;
  if selected.id is null then raise exception 'Inventory item unavailable'; end if;
  update public.user_inventory set equipped = false where user_id = owner_id and item_id = selected.item_id;
  update public.user_inventory set equipped = true where id = selected.id returning * into result;
  return result;
end;
$$;
create or replace function public.unequip_mall_item(target_inventory uuid)
returns public.user_inventory language plpgsql security definer set search_path = public as $$
declare result public.user_inventory;
begin
  update public.user_inventory set equipped = false where id = target_inventory and user_id = auth.uid() returning * into result;
  if result.id is null then raise exception 'Inventory item unavailable'; end if;
  return result;
end;
$$;
revoke all on function public.equip_mall_item(uuid), public.unequip_mall_item(uuid) from public, anon;
grant execute on function public.equip_mall_item(uuid), public.unequip_mall_item(uuid) to authenticated;

create or replace function public.share_social_post(target_post uuid)
returns void language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  update public.social_posts set shares = shares + 1, updated_at = now() where id = target_post;
  if not found then raise exception 'Post unavailable'; end if;
end;
$$;
revoke all on function public.share_social_post(uuid) from public, anon;
grant execute on function public.share_social_post(uuid) to authenticated;

create or replace function public.block_user(target_user uuid)
returns void language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null or auth.uid() = target_user then raise exception 'Invalid block target'; end if;
  insert into public.blocks(blocker_id, blocked_id) values (auth.uid(), target_user) on conflict do nothing;
  delete from public.post_follows where follower_id = auth.uid() and following_id = target_user;
  delete from public.post_follows where follower_id = target_user and following_id = auth.uid();
end;
$$;
create or replace function public.unblock_user(target_user uuid)
returns void language sql security definer set search_path = public as $$
  delete from public.blocks where blocker_id = auth.uid() and blocked_id = target_user;
$$;
revoke all on function public.block_user(uuid), public.unblock_user(uuid) from public, anon;
grant execute on function public.block_user(uuid), public.unblock_user(uuid) to authenticated;

create or replace function public.create_agency(agency_name text, agency_description text)
returns public.agencies language plpgsql security definer set search_path = public as $$
declare result public.agencies;
begin
  if auth.uid() is null or length(trim(agency_name)) < 2 then raise exception 'Agency name is required'; end if;
  insert into public.agencies(owner_id, name, description, status) values (auth.uid(), trim(agency_name), coalesce(agency_description, ''), 'pending') returning * into result;
  update public.host_profiles set agency_name = result.name, updated_at = now() where user_id = auth.uid();
  return result;
end;
$$;
create or replace function public.add_agency_host(target_agency uuid, target_host uuid)
returns public.agency_hosts language plpgsql security definer set search_path = public as $$
declare result public.agency_hosts;
begin
  if not exists (select 1 from public.agencies where id = target_agency and owner_id = auth.uid()) then raise exception 'Agency permission required'; end if;
  if not exists (select 1 from public.host_profiles where user_id = target_host) then raise exception 'Host profile required'; end if;
  insert into public.agency_hosts(agency_id, host_id, status) values (target_agency, target_host, 'pending') on conflict (agency_id, host_id) do update set status = 'pending' returning * into result;
  return result;
end;
$$;
create or replace function public.remove_agency_host(target_agency uuid, target_host uuid)
returns void language plpgsql security definer set search_path = public as $$
begin
  if not exists (select 1 from public.agencies where id = target_agency and owner_id = auth.uid()) then raise exception 'Agency permission required'; end if;
  delete from public.agency_hosts where agency_id = target_agency and host_id = target_host;
end;
$$;
revoke all on function public.create_agency(text, text), public.add_agency_host(uuid, uuid), public.remove_agency_host(uuid, uuid) from public, anon;
grant execute on function public.create_agency(text, text), public.add_agency_host(uuid, uuid), public.remove_agency_host(uuid, uuid) to authenticated;