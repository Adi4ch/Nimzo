-- Missing non-voice state for gifts, room management, and agency applications.
create table if not exists public.gift_favorites (
  user_id uuid not null references public.profiles(id) on delete cascade,
  gift_id uuid not null references public.gifts(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, gift_id)
);
alter table public.gift_favorites enable row level security;
drop policy if exists gift_favorites_own on public.gift_favorites;
create policy gift_favorites_own on public.gift_favorites for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

create table if not exists public.room_moderators (
  room_id uuid not null references public.rooms(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  assigned_by uuid not null references public.profiles(id),
  created_at timestamptz not null default now(),
  primary key (room_id, user_id)
);
create table if not exists public.room_sanctions (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.rooms(id) on delete cascade,
  target_user uuid not null references public.profiles(id) on delete cascade,
  actor_id uuid not null references public.profiles(id),
  action text not null check (action in ('mute', 'kick', 'ban')),
  expires_at timestamptz,
  created_at timestamptz not null default now()
);
alter table public.room_moderators enable row level security;
alter table public.room_sanctions enable row level security;
drop policy if exists room_moderators_authenticated_select on public.room_moderators;
create policy room_moderators_authenticated_select on public.room_moderators for select to authenticated using (true);
drop policy if exists room_sanctions_authenticated_select on public.room_sanctions;
create policy room_sanctions_authenticated_select on public.room_sanctions for select to authenticated using (true);

create or replace function public.toggle_gift_favorite(target_gift uuid, should_favorite boolean)
returns void language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if should_favorite then
    insert into public.gift_favorites(user_id, gift_id) values (auth.uid(), target_gift) on conflict do nothing;
  else
    delete from public.gift_favorites where user_id = auth.uid() and gift_id = target_gift;
  end if;
end;
$$;
revoke all on function public.toggle_gift_favorite(uuid, boolean) from public, anon;
grant execute on function public.toggle_gift_favorite(uuid, boolean) to authenticated;

create or replace function public.manage_room_member(target_room uuid, target_user uuid, action_name text, duration_minutes integer default null)
returns public.room_sanctions language plpgsql security definer set search_path = public as $$
declare actor uuid := auth.uid(); sanction public.room_sanctions; expiry timestamptz;
begin
  if actor is null or action_name not in ('mute', 'kick', 'ban') then raise exception 'Invalid room action'; end if;
  if not exists (select 1 from public.rooms r where r.id = target_room and (r.created_by = actor or r.host_id = actor or exists (select 1 from public.room_moderators m where m.room_id = target_room and m.user_id = actor))) then raise exception 'Room management permission required'; end if;
  if duration_minutes is not null and duration_minutes > 0 then expiry := now() + make_interval(mins => duration_minutes); end if;
  if action_name in ('kick', 'ban') then update public.room_seats set user_id = null, active = false where room_id = target_room and user_id = target_user; end if;
  insert into public.room_sanctions(room_id, target_user, actor_id, action, expires_at) values (target_room, target_user, actor, action_name, expiry) returning * into sanction;
  insert into public.room_activities(room_id, actor_id, activity_type, message) values (target_room, actor, action_name, 'Room member moderation action');
  insert into public.audit_logs(actor_id, action, target_type, target_id, metadata) values (actor, 'room_' || action_name, 'room', target_room, jsonb_build_object('target_user', target_user));
  return sanction;
end;
$$;
revoke all on function public.manage_room_member(uuid, uuid, text, integer) from public, anon;
grant execute on function public.manage_room_member(uuid, uuid, text, integer) to authenticated;

create or replace function public.assign_room_moderator(target_room uuid, target_user uuid, should_assign boolean)
returns void language plpgsql security definer set search_path = public as $$
begin
  if not exists (select 1 from public.rooms where id = target_room and (created_by = auth.uid() or host_id = auth.uid())) then raise exception 'Room owner permission required'; end if;
  if should_assign then insert into public.room_moderators(room_id, user_id, assigned_by) values (target_room, target_user, auth.uid()) on conflict do nothing;
  else delete from public.room_moderators where room_id = target_room and user_id = target_user;
  end if;
end;
$$;
revoke all on function public.assign_room_moderator(uuid, uuid, boolean) from public, anon;
grant execute on function public.assign_room_moderator(uuid, uuid, boolean) to authenticated;

create or replace function public.update_room_settings(target_room uuid, room_name text, room_subtitle text, room_description text, room_background text)
returns public.rooms language plpgsql security definer set search_path = public as $$
declare result public.rooms;
begin
  if not exists (select 1 from public.rooms where id = target_room and (created_by = auth.uid() or host_id = auth.uid())) then raise exception 'Room owner permission required'; end if;
  update public.rooms set name = trim(room_name), subtitle = coalesce(room_subtitle, ''), description = coalesce(room_description, ''), background_url = room_background, updated_at = now() where id = target_room returning * into result;
  insert into public.room_activities(room_id, actor_id, activity_type, message) values (target_room, auth.uid(), 'settings_updated', 'Room settings updated');
  return result;
end;
$$;
revoke all on function public.update_room_settings(uuid, text, text, text, text) from public, anon;
grant execute on function public.update_room_settings(uuid, text, text, text, text) to authenticated;

create or replace function public.apply_to_agency(target_agency uuid)
returns public.agency_hosts language plpgsql security definer set search_path = public as $$
declare result public.agency_hosts;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if not exists (select 1 from public.agencies where id = target_agency and status in ('pending', 'active')) then raise exception 'Agency unavailable'; end if;
  if not exists (select 1 from public.host_profiles where user_id = auth.uid()) then raise exception 'Host profile required'; end if;
  insert into public.agency_hosts(agency_id, host_id, status) values (target_agency, auth.uid(), 'pending') on conflict (agency_id, host_id) do update set status = 'pending' returning * into result;
  return result;
end;
$$;
revoke all on function public.apply_to_agency(uuid) from public, anon;
grant execute on function public.apply_to_agency(uuid) to authenticated;