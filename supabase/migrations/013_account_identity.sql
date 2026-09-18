-- Persistent account identity and secure self-service deletion.
alter table public.profiles add column if not exists username text;
alter table public.profiles add column if not exists country text;
alter table public.profiles add column if not exists gender text;

update public.profiles
set username = 'nimzo_' || replace(left(id::text, 12), '-', '')
where username is null or username = '';

create unique index if not exists profiles_username_unique_idx on public.profiles (lower(username)) where username is not null and username <> '';
alter table public.profiles alter column username set default '';

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, display_name, username, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'display_name', new.raw_user_meta_data ->> 'full_name', ''),
    'nimzo_' || replace(left(new.id::text, 12), '-', ''),
    new.raw_user_meta_data ->> 'avatar_url'
  ) on conflict (id) do update set
    display_name = case when profiles.display_name = '' then excluded.display_name else profiles.display_name end,
    avatar_url = coalesce(profiles.avatar_url, excluded.avatar_url);

  insert into public.wallets (user_id) values (new.id) on conflict (user_id) do nothing;
  return new;
end;
$$;

create or replace function public.delete_my_account()
returns void language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  delete from auth.users where id = auth.uid();
end;
$$;
revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;