-- Backend phase additions. Wallet mutations remain server-side only.
alter table public.profiles add column if not exists bio text not null default '';
alter table public.rooms add column if not exists description text not null default '';
alter table public.rooms add column if not exists background_url text;

create or replace function public.ensure_room_seats(target_room uuid)
returns void language plpgsql security definer set search_path = public as $$
begin
  insert into public.room_seats (room_id, position)
  select target_room, positions.position from generate_series(0, 9) as positions(position)
  on conflict (room_id, position) do nothing;
end;
$$;

create or replace function public.join_room_seat(target_room uuid, target_position integer)
returns public.room_seats language plpgsql security invoker set search_path = public as $$
declare result public.room_seats;
begin
  if target_position not between 0 and 9 then raise exception 'Seat position must be between 0 and 9'; end if;
  perform public.ensure_room_seats(target_room);
  update public.room_seats set user_id = auth.uid(), active = true
    where room_id = target_room and position = target_position and user_id is null
    returning * into result;
  if result.id is null then raise exception 'Seat is already occupied'; end if;
  return result;
end;
$$;

create or replace function public.leave_room_seat(target_room uuid)
returns void language sql security invoker set search_path = public as $$
  update public.room_seats set user_id = null, active = false
  where room_id = target_room and user_id = auth.uid();
$$;

drop policy if exists room_seats_join_empty on public.room_seats;
create policy room_seats_join_empty on public.room_seats
for update to authenticated
using (user_id is null)
with check (user_id = auth.uid());

revoke all on function public.ensure_room_seats(uuid) from public, anon;
grant execute on function public.ensure_room_seats(uuid) to authenticated;
revoke all on function public.join_room_seat(uuid, integer) from public, anon;
grant execute on function public.join_room_seat(uuid, integer) to authenticated;
revoke all on function public.leave_room_seat(uuid) from public, anon;
grant execute on function public.leave_room_seat(uuid) to authenticated;