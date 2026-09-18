-- Complete virtual gift accounting, inventory, XP and notifications atomically.
alter table public.profiles add column if not exists active_xp bigint not null default 0 check (active_xp >= 0);
alter table public.profiles add column if not exists charm_xp bigint not null default 0 check (charm_xp >= 0);
alter table public.profiles add column if not exists wealth_xp bigint not null default 0 check (wealth_xp >= 0);

create or replace function public.send_virtual_gift(target_room uuid, target_gift uuid, target_receiver uuid, target_quantity integer, request_key text)
returns public.gift_events language plpgsql security definer set search_path = public as $$
declare sender uuid := auth.uid(); gift public.gifts; wallet public.wallets; event_row public.gift_events; receiver uuid; cost bigint;
begin
  if sender is null then raise exception 'Authentication required'; end if;
  if request_key is null or length(trim(request_key)) = 0 then raise exception 'Idempotency key required'; end if;
  select * into event_row from public.gift_events where idempotency_key = request_key;
  if event_row.id is not null then return event_row; end if;
  if target_quantity not between 1 and 99 then raise exception 'Invalid quantity'; end if;
  if not exists (select 1 from public.rooms where id = target_room) then raise exception 'Room not found'; end if;
  select * into gift from public.gifts where id = target_gift;
  if gift.id is null then raise exception 'Gift not found'; end if;
  receiver := coalesce(target_receiver, (select user_id from public.room_seats where room_id = target_room and user_id is not null order by position limit 1));
  cost := gift.coin_cost * target_quantity;
  select * into wallet from public.wallets where user_id = sender for update;
  if wallet.id is null or wallet.balance < cost then raise exception 'Insufficient virtual coins'; end if;
  update public.wallets set balance = balance - cost, updated_at = now() where id = wallet.id;
  insert into public.wallet_transactions(wallet_id, type, amount, description) values (wallet.id, 'room_gift', -cost, 'Virtual gift combo');
  insert into public.gift_events(idempotency_key, room_id, gift_id, sender_id, receiver_id, quantity, total_cost) values (request_key, target_room, target_gift, sender, receiver, target_quantity, cost) returning * into event_row;
  if receiver is not null then
    insert into public.gift_inventory(user_id, gift_id, quantity) values (receiver, target_gift, target_quantity) on conflict (user_id, gift_id) do update set quantity = public.gift_inventory.quantity + excluded.quantity, updated_at = now();
    update public.profiles set charm_xp = charm_xp + target_quantity * cost, updated_at = now() where id = receiver;
    insert into public.notifications(user_id, actor_id, type, title, body, target_id) values (receiver, sender, 'gift', 'You received a gift', 'A virtual gift was sent to you.', event_row.id);
  end if;
  update public.profiles set wealth_xp = wealth_xp + cost, updated_at = now() where id = sender;
  insert into public.room_messages(room_id, user_id, text, message_type, gift_id) values (target_room, sender, 'Sent a virtual gift', 'gift', target_gift);
  insert into public.room_activities(room_id, actor_id, activity_type, message) values (target_room, sender, 'gift_sent', 'Virtual gift sent');
  return event_row;
end;
$$;
revoke all on function public.send_virtual_gift(uuid, uuid, uuid, integer, text) from public, anon;
grant execute on function public.send_virtual_gift(uuid, uuid, uuid, integer, text) to authenticated;