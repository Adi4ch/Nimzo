-- Nimzo platform foundation. Coin-changing operations stay in security-definer RPCs.
create table if not exists public.game_sessions (id uuid primary key default gen_random_uuid(), game_id uuid not null references public.games(id), room_id uuid references public.rooms(id) on delete set null, user_id uuid not null references public.profiles(id), started_at timestamptz not null default now(), ended_at timestamptz, status text not null default 'active');
create table if not exists public.game_transactions (id uuid primary key default gen_random_uuid(), session_id uuid not null references public.game_sessions(id) on delete cascade, amount bigint not null, type text not null check (type in ('stake', 'reward')), created_at timestamptz not null default now());
create table if not exists public.gift_inventory (user_id uuid not null references public.profiles(id) on delete cascade, gift_id uuid not null references public.gifts(id), quantity integer not null default 0 check (quantity >= 0), updated_at timestamptz not null default now(), primary key (user_id, gift_id));
create table if not exists public.notifications (id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(id) on delete cascade, actor_id uuid references public.profiles(id) on delete set null, type text not null, title text not null, body text not null default '', target_id uuid, read_at timestamptz, created_at timestamptz not null default now());
create table if not exists public.blocks (blocker_id uuid not null references public.profiles(id) on delete cascade, blocked_id uuid not null references public.profiles(id) on delete cascade, created_at timestamptz not null default now(), primary key (blocker_id, blocked_id), check (blocker_id <> blocked_id));
create table if not exists public.reports (id uuid primary key default gen_random_uuid(), reporter_id uuid not null references public.profiles(id), target_type text not null check (target_type in ('user', 'post', 'comment', 'room')), target_id uuid not null, reason text not null check (reason in ('spam', 'harassment', 'inappropriate_content', 'fraud', 'other')), details text not null default '', status text not null default 'open', created_at timestamptz not null default now());
create table if not exists public.agencies (id uuid primary key default gen_random_uuid(), owner_id uuid not null references public.profiles(id), name text not null, description text not null default '', status text not null default 'pending', created_at timestamptz not null default now());
create table if not exists public.agency_hosts (agency_id uuid not null references public.agencies(id) on delete cascade, host_id uuid not null references public.profiles(id) on delete cascade, status text not null default 'pending', created_at timestamptz not null default now(), primary key (agency_id, host_id));
create table if not exists public.daily_tasks (id uuid primary key default gen_random_uuid(), code text not null unique, title text not null, description text not null default '', reward_coins bigint not null default 0, active boolean not null default true);
create table if not exists public.daily_task_progress (user_id uuid not null references public.profiles(id) on delete cascade, task_id uuid not null references public.daily_tasks(id) on delete cascade, task_date date not null default current_date, progress integer not null default 0, claimed_at timestamptz, primary key (user_id, task_id, task_date));
create table if not exists public.achievements (id uuid primary key default gen_random_uuid(), code text not null unique, title text not null, description text not null default '', reward_coins bigint not null default 0);
create table if not exists public.user_achievements (user_id uuid not null references public.profiles(id) on delete cascade, achievement_id uuid not null references public.achievements(id) on delete cascade, achieved_at timestamptz not null default now(), primary key (user_id, achievement_id));
create table if not exists public.vip_levels (id uuid primary key default gen_random_uuid(), level integer not null unique, name text not null, benefits jsonb not null default '{}'::jsonb);
create table if not exists public.user_vip (user_id uuid primary key references public.profiles(id) on delete cascade, vip_level_id uuid references public.vip_levels(id), expires_at timestamptz);
create table if not exists public.mall_items (id uuid primary key default gen_random_uuid(), category text not null, name text not null, description text not null default '', price_coins bigint not null check (price_coins >= 0), asset_url text, duration_days integer, active boolean not null default true);
create table if not exists public.user_inventory (id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(id) on delete cascade, item_id uuid not null references public.mall_items(id), equipped boolean not null default false, expires_at timestamptz, purchased_at timestamptz not null default now());
create table if not exists public.rankings (id uuid primary key default gen_random_uuid(), period text not null check (period in ('daily', 'weekly', 'monthly')), kind text not null, subject_id uuid not null, score bigint not null default 0, rank integer not null, period_start date not null);
create table if not exists public.room_activities (id uuid primary key default gen_random_uuid(), room_id uuid not null references public.rooms(id) on delete cascade, actor_id uuid references public.profiles(id) on delete set null, activity_type text not null, message text not null default '', created_at timestamptz not null default now());
create table if not exists public.user_settings (user_id uuid primary key references public.profiles(id) on delete cascade, language text not null default 'en', notifications_enabled boolean not null default true, privacy jsonb not null default '{}'::jsonb, updated_at timestamptz not null default now());
create table if not exists public.audit_logs (id uuid primary key default gen_random_uuid(), actor_id uuid references public.profiles(id) on delete set null, action text not null, target_type text, target_id uuid, metadata jsonb not null default '{}'::jsonb, created_at timestamptz not null default now());
create table if not exists public.mall_purchases (id uuid primary key default gen_random_uuid(), idempotency_key text not null unique, user_id uuid not null references public.profiles(id), item_id uuid not null references public.mall_items(id), price_coins bigint not null, created_at timestamptz not null default now());

do $$ declare table_name text; begin
  foreach table_name in array array['game_sessions','game_transactions','gift_inventory','notifications','blocks','reports','agencies','agency_hosts','daily_tasks','daily_task_progress','achievements','user_achievements','vip_levels','user_vip','mall_items','user_inventory','rankings','room_activities','user_settings','audit_logs','mall_purchases'] loop
    execute format('alter table public.%I enable row level security', table_name);
  end loop;
end $$;

drop policy if exists game_sessions_own_select on public.game_sessions;
create policy game_sessions_own_select on public.game_sessions for select to authenticated using (user_id = auth.uid());
drop policy if exists game_transactions_own_select on public.game_transactions;
create policy game_transactions_own_select on public.game_transactions for select to authenticated using (exists (select 1 from public.game_sessions s where s.id = session_id and s.user_id = auth.uid()));
drop policy if exists gift_inventory_own_select on public.gift_inventory;
create policy gift_inventory_own_select on public.gift_inventory for select to authenticated using (user_id = auth.uid());
drop policy if exists notifications_own_select on public.notifications;
create policy notifications_own_select on public.notifications for select to authenticated using (user_id = auth.uid());
drop policy if exists notifications_own_update on public.notifications;
create policy notifications_own_update on public.notifications for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists blocks_own_all on public.blocks;
create policy blocks_own_all on public.blocks for all to authenticated using (blocker_id = auth.uid()) with check (blocker_id = auth.uid());
drop policy if exists reports_own_insert on public.reports;
create policy reports_own_insert on public.reports for insert to authenticated with check (reporter_id = auth.uid());
drop policy if exists reports_own_select on public.reports;
create policy reports_own_select on public.reports for select to authenticated using (reporter_id = auth.uid());
drop policy if exists agencies_authenticated_select on public.agencies;
create policy agencies_authenticated_select on public.agencies for select to authenticated using (true);
drop policy if exists agencies_owner_insert on public.agencies;
create policy agencies_owner_insert on public.agencies for insert to authenticated with check (owner_id = auth.uid());
drop policy if exists agency_hosts_authenticated_select on public.agency_hosts;
create policy agency_hosts_authenticated_select on public.agency_hosts for select to authenticated using (true);
drop policy if exists daily_tasks_authenticated_select on public.daily_tasks;
create policy daily_tasks_authenticated_select on public.daily_tasks for select to authenticated using (active);
drop policy if exists task_progress_own on public.daily_task_progress;
create policy task_progress_own on public.daily_task_progress for select to authenticated using (user_id = auth.uid());
drop policy if exists achievements_authenticated_select on public.achievements;
create policy achievements_authenticated_select on public.achievements for select to authenticated using (true);
drop policy if exists user_achievements_own_select on public.user_achievements;
create policy user_achievements_own_select on public.user_achievements for select to authenticated using (user_id = auth.uid());
drop policy if exists vip_levels_authenticated_select on public.vip_levels;
create policy vip_levels_authenticated_select on public.vip_levels for select to authenticated using (true);
drop policy if exists user_vip_own_select on public.user_vip;
create policy user_vip_own_select on public.user_vip for select to authenticated using (user_id = auth.uid());
drop policy if exists mall_items_authenticated_select on public.mall_items;
create policy mall_items_authenticated_select on public.mall_items for select to authenticated using (active);
drop policy if exists inventory_own_select on public.user_inventory;
create policy inventory_own_select on public.user_inventory for select to authenticated using (user_id = auth.uid());
drop policy if exists rankings_authenticated_select on public.rankings;
create policy rankings_authenticated_select on public.rankings for select to authenticated using (true);
drop policy if exists room_activities_authenticated_select on public.room_activities;
create policy room_activities_authenticated_select on public.room_activities for select to authenticated using (true);
drop policy if exists settings_own_all on public.user_settings;
create policy settings_own_all on public.user_settings for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

create or replace function public.purchase_mall_item(target_item uuid, request_key text)
returns public.user_inventory language plpgsql security definer set search_path = public as $$
declare buyer uuid := auth.uid(); item public.mall_items; wallet public.wallets; inventory_row public.user_inventory; purchase public.mall_purchases;
begin
  if buyer is null then raise exception 'Authentication required'; end if;
  if request_key is null or length(trim(request_key)) = 0 then raise exception 'Idempotency key required'; end if;
  select * into purchase from public.mall_purchases where idempotency_key = request_key;
  if purchase.id is not null then select * into inventory_row from public.user_inventory where user_id = buyer and item_id = purchase.item_id order by purchased_at desc limit 1; return inventory_row; end if;
  select * into item from public.mall_items where id = target_item and active;
  if item.id is null then raise exception 'Item unavailable'; end if;
  select * into wallet from public.wallets where user_id = buyer for update;
  if wallet.balance < item.price_coins then raise exception 'Insufficient virtual coins'; end if;
  update public.wallets set balance = balance - item.price_coins, updated_at = now() where id = wallet.id;
  insert into public.wallet_transactions(wallet_id, type, amount, description) values (wallet.id, 'adjustment', -item.price_coins, 'Mall purchase');
  insert into public.mall_purchases(idempotency_key, user_id, item_id, price_coins) values (request_key, buyer, item.id, item.price_coins);
  insert into public.user_inventory(user_id, item_id, expires_at) values (buyer, item.id, case when item.duration_days is null then null else now() + make_interval(days => item.duration_days) end) returning * into inventory_row;
  return inventory_row;
end;
$$;
revoke all on function public.purchase_mall_item(uuid, text) from public, anon;
grant execute on function public.purchase_mall_item(uuid, text) to authenticated;

do $$ declare table_name text; begin
  foreach table_name in array array['notifications','room_activities','gift_events'] loop
    if not exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = table_name) then execute format('alter publication supabase_realtime add table public.%I', table_name); end if;
  end loop;
end $$;