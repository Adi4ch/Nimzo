-- Room creation and settings are validated in server-side functions.
alter table public.rooms add column if not exists avatar_url text;
alter table public.rooms add column if not exists privacy text not null default 'public' check (privacy in ('public', 'private'));
alter table public.rooms add column if not exists password_hash text;
alter table public.rooms add column if not exists announcement text not null default '';
alter table public.rooms add column if not exists theme text not null default 'mint';

create or replace function public.create_room(room_name text, room_subtitle text, room_category text, room_description text, room_avatar text, room_background text, room_privacy text, room_password text, room_announcement text, room_theme text)
returns public.rooms language plpgsql security definer set search_path = public, extensions as $$
declare result public.rooms; new_id uuid;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  if length(trim(coalesce(room_name, ''))) < 2 then raise exception 'Room name must have at least 2 characters'; end if;
  if room_privacy not in ('public', 'private') then raise exception 'Invalid room privacy'; end if;
  if room_privacy = 'private' and length(trim(coalesce(room_password, ''))) < 4 then raise exception 'Private rooms require a password of at least 4 characters'; end if;
  insert into public.rooms(name, subtitle, category, description, avatar_url, background_url, privacy, password_hash, announcement, theme, created_by, host_id)
  values(trim(room_name), coalesce(room_subtitle, ''), coalesce(room_category, 'Chat'), coalesce(room_description, ''), room_avatar, room_background, room_privacy, case when room_privacy = 'private' then crypt(room_password, gen_salt('bf')) else null end, coalesce(room_announcement, ''), coalesce(room_theme, 'mint'), auth.uid(), auth.uid()) returning id into new_id;
  perform public.ensure_room_seats(new_id);
  select * into result from public.rooms where id = new_id;
  return result;
end;
$$;

drop function if exists public.update_room_settings(uuid, text, text, text, text);
create or replace function public.update_room_settings(target_room uuid, room_name text, room_subtitle text, room_description text, room_avatar text, room_background text, room_privacy text, room_password text, room_announcement text, room_theme text)
returns public.rooms language plpgsql security definer set search_path = public, extensions as $$
declare result public.rooms;
begin
  if not exists (select 1 from public.rooms where id = target_room and (created_by = auth.uid() or host_id = auth.uid())) then raise exception 'Room owner permission required'; end if;
  if room_privacy not in ('public', 'private') then raise exception 'Invalid room privacy'; end if;
  if room_privacy = 'private' and length(trim(coalesce(room_password, ''))) < 4 and not exists (select 1 from public.rooms where id = target_room and password_hash is not null) then raise exception 'Private rooms require a password of at least 4 characters'; end if;
  update public.rooms set name = trim(room_name), subtitle = coalesce(room_subtitle, ''), description = coalesce(room_description, ''), avatar_url = room_avatar, background_url = room_background, privacy = room_privacy, password_hash = case when room_privacy = 'public' then null when nullif(trim(coalesce(room_password, '')), '') is not null then crypt(room_password, gen_salt('bf')) else password_hash end, announcement = coalesce(room_announcement, ''), theme = coalesce(room_theme, 'mint'), updated_at = now() where id = target_room returning * into result;
  insert into public.room_activities(room_id, actor_id, activity_type, message) values (target_room, auth.uid(), 'settings_updated', 'Room settings updated');
  return result;
end;
$$;
revoke all on function public.create_room(text, text, text, text, text, text, text, text, text, text) from public, anon;
grant execute on function public.create_room(text, text, text, text, text, text, text, text, text, text) to authenticated;
revoke all on function public.update_room_settings(uuid, text, text, text, text, text, text, text, text, text) from public, anon;
grant execute on function public.update_room_settings(uuid, text, text, text, text, text, text, text, text, text) to authenticated;

create or replace function public.unban_room_member(target_room uuid, target_member uuid)
returns void language plpgsql security definer set search_path = public as $$
begin
  if not exists (select 1 from public.rooms r where r.id = target_room and (r.created_by = auth.uid() or r.host_id = auth.uid() or exists (select 1 from public.room_moderators m where m.room_id = target_room and m.user_id = auth.uid()))) then raise exception 'Room management permission required'; end if;
  delete from public.room_sanctions sanction where sanction.room_id = target_room and sanction.target_user = target_member and sanction.action = 'ban';
  insert into public.room_activities(room_id, actor_id, activity_type, message) values (target_room, auth.uid(), 'unban', 'Room member ban removed');
end;
$$;
revoke all on function public.unban_room_member(uuid, uuid) from public, anon;
grant execute on function public.unban_room_member(uuid, uuid) to authenticated;