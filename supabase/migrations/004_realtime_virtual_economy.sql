-- Realtime chat, virtual gift events, and server-authoritative demo game results.
create table if not exists public.room_messages (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.rooms(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  text text not null default '',
  message_type text not null default 'text' check (message_type in ('text', 'gift', 'system')),
  reply_to_id uuid references public.room_messages(id) on delete set null,
  gift_id uuid references public.gifts(id) on delete set null,
  recalled boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.gift_events (
  id uuid primary key default gen_random_uuid(),
  idempotency_key text not null unique,
  room_id uuid not null references public.rooms(id) on delete cascade,
  gift_id uuid not null references public.gifts(id),
  sender_id uuid not null references public.profiles(id),
  receiver_id uuid references public.profiles(id),
  quantity integer not null default 1 check (quantity between 1 and 99),
  total_cost bigint not null check (total_cost > 0),
  created_at timestamptz not null default now()
);

create table if not exists public.game_results (
  id uuid primary key default gen_random_uuid(),
  idempotency_key text not null unique,
  game_id uuid not null references public.games(id),
  user_id uuid not null references public.profiles(id),
  stake bigint not null check (stake > 0),
  reward bigint not null check (reward >= 0),
  result jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.room_messages enable row level security;
alter table public.gift_events enable row level security;
alter table public.game_results enable row level security;

create policy room_messages_select_authenticated on public.room_messages for select to authenticated using (true);
create policy room_messages_insert_own on public.room_messages for insert to authenticated with check (user_id = auth.uid());
create policy room_messages_update_own on public.room_messages for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy gift_events_select_authenticated on public.gift_events for select to authenticated using (true);
create policy game_results_select_own on public.game_results for select to authenticated using (user_id = auth.uid());

create or replace function public.send_virtual_gift(target_room uuid, target_gift uuid, target_receiver uuid, target_quantity integer, request_key text)
returns public.gift_events language plpgsql security definer set search_path = public as $$
declare sender uuid := auth.uid(); gift public.gifts; wallet public.wallets; event_row public.gift_events;
begin
  if sender is null then raise exception 'Authentication required'; end if;
  select * into event_row from public.gift_events where idempotency_key = request_key;
  if event_row.id is not null then return event_row; end if;
  if target_quantity not between 1 and 99 then raise exception 'Invalid quantity'; end if;
  select * into gift from public.gifts where id = target_gift;
  if gift.id is null then raise exception 'Gift not found'; end if;
  select * into wallet from public.wallets where user_id = sender for update;
  if wallet.balance < gift.coin_cost * target_quantity then raise exception 'Insufficient virtual coins'; end if;
  update public.wallets set balance = balance - gift.coin_cost * target_quantity, updated_at = now() where id = wallet.id;
  insert into public.wallet_transactions(wallet_id, type, amount, description) values (wallet.id, 'room_gift', -(gift.coin_cost * target_quantity), 'Virtual gift');
  insert into public.gift_events(idempotency_key, room_id, gift_id, sender_id, receiver_id, quantity, total_cost) values (request_key, target_room, target_gift, sender, target_receiver, target_quantity, gift.coin_cost * target_quantity) returning * into event_row;
  return event_row;
end;
$$;

create or replace function public.play_fruit_rush(target_game uuid, target_stake bigint, request_key text)
returns jsonb language plpgsql security definer set search_path = public as $$
declare player uuid := auth.uid(); wallet public.wallets; reward bigint; symbols jsonb; result_row public.game_results;
begin
  if player is null then raise exception 'Authentication required'; end if;
  select * into result_row from public.game_results where idempotency_key = request_key;
  if result_row.id is not null then return jsonb_build_object('id', result_row.id, 'reward', result_row.reward, 'result', result_row.result); end if;
  if target_stake < 1 then raise exception 'Invalid stake'; end if;
  select * into wallet from public.wallets where user_id = player for update;
  if wallet.balance < target_stake then raise exception 'Insufficient virtual coins'; end if;
  symbols := jsonb_build_array((array['apple', 'orange', 'berry', 'melon'])[1 + floor(random() * 4)::int], (array['apple', 'orange', 'berry', 'melon'])[1 + floor(random() * 4)::int], (array['apple', 'orange', 'berry', 'melon'])[1 + floor(random() * 4)::int]);
  reward := case when symbols->0 = symbols->1 and symbols->1 = symbols->2 then target_stake * 5 when symbols->0 = symbols->1 or symbols->1 = symbols->2 then target_stake * 2 else 0 end;
  update public.wallets set balance = balance - target_stake + reward, updated_at = now() where id = wallet.id;
  insert into public.wallet_transactions(wallet_id, type, amount, description) values (wallet.id, 'game_win', reward - target_stake, 'Fruit Rush virtual play');
  insert into public.game_results(idempotency_key, game_id, user_id, stake, reward, result) values (request_key, target_game, player, target_stake, reward, jsonb_build_object('symbols', symbols)) returning * into result_row;
  return jsonb_build_object('id', result_row.id, 'reward', reward, 'result', result_row.result);
end;
$$;

revoke all on function public.send_virtual_gift(uuid, uuid, uuid, integer, text) from public, anon;
grant execute on function public.send_virtual_gift(uuid, uuid, uuid, integer, text) to authenticated;
revoke all on function public.play_fruit_rush(uuid, bigint, text) from public, anon;
grant execute on function public.play_fruit_rush(uuid, bigint, text) to authenticated;

do $$
declare table_name text;
begin
  foreach table_name in array array['room_seats', 'room_messages', 'gift_events', 'social_posts', 'post_likes', 'comments'] loop
    if not exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = table_name) then
      execute format('alter publication supabase_realtime add table public.%I', table_name);
    end if;
  end loop;
end $$;