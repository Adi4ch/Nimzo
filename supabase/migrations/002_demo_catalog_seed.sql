-- Safe Nimzo demo catalog seed.
-- Games and gifts are global catalog rows. Demo rooms require an existing owner.

insert into public.games (name, category)
values
  ('Ludo', 'Board'),
  ('Carrom', 'Board'),
  ('8 Ball Pool', 'Classic'),
  ('Fruit Party', 'Classic'),
  ('Teen Patti', 'Classic'),
  ('Luck 77', 'Classic')
on conflict (name) do nothing;

insert into public.gifts (name, coin_cost, icon_name)
values ('Rose', 10, 'favorite')
on conflict (name) do nothing;

create or replace function public.seed_demo_rooms(p_owner_id uuid)
returns void
language plpgsql
security invoker
set search_path = public
as $$
begin
  if not exists (select 1 from public.profiles where profiles.id = p_owner_id) then
    raise exception 'owner_id must reference an existing profile';
  end if;

  insert into public.rooms (name, subtitle, category, listener_count, is_featured, created_by, host_id)
  select seed.name, seed.subtitle, seed.category, seed.listener_count, seed.is_featured, p_owner_id, p_owner_id
  from (values
    ('Chill Vibes', 'Sing  |  Dance  |  Enjoy', 'Popular', 2400, true),
    ('Music Room', 'Sing  |  Dance  |  Enjoy', 'Music', 2400, true),
    ('Friends Talk', 'Sing  |  Dance  |  Enjoy', 'Chat', 2400, true),
    ('Gaming Zone', 'Sing  |  Dance  |  Enjoy', 'New', 2400, false)
  ) as seed(name, subtitle, category, listener_count, is_featured)
  where not exists (select 1 from public.rooms existing where existing.name = seed.name and existing.created_by = p_owner_id);

  insert into public.room_seats (room_id, position, active)
  select rooms.id, seats.position, seats.position < 5
  from public.rooms
  cross join generate_series(0, 9) as seats(position)
  where rooms.created_by = p_owner_id
  on conflict (room_id, position) do nothing;
end;
$$;

-- Room seeding is intentionally not granted to browser roles. Run it from a
-- trusted SQL session after an owner profile exists:
-- select public.seed_demo_rooms('<existing-profile-uuid>');
revoke all on function public.seed_demo_rooms(uuid) from public, anon, authenticated;
