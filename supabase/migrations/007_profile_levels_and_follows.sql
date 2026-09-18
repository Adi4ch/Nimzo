-- Profile identity, independent level tracks, and user-to-user follows.
alter table public.profiles add column if not exists username text;
alter table public.profiles add column if not exists nimzo_id text;
alter table public.profiles add column if not exists country text;
alter table public.profiles add column if not exists gender text;
alter table public.profiles add column if not exists active_level integer not null default 1 check (active_level > 0);
alter table public.profiles add column if not exists charm_level integer not null default 1 check (charm_level > 0);
alter table public.profiles add column if not exists wealth_level integer not null default 1 check (wealth_level > 0);
alter table public.profiles add column if not exists active_xp bigint not null default 0 check (active_xp >= 0);
alter table public.profiles add column if not exists charm_xp bigint not null default 0 check (charm_xp >= 0);
alter table public.profiles add column if not exists wealth_xp bigint not null default 0 check (wealth_xp >= 0);

create unique index if not exists profiles_username_unique on public.profiles (lower(username)) where username is not null and length(trim(username)) > 0;
create unique index if not exists profiles_nimzo_id_unique on public.profiles (nimzo_id) where nimzo_id is not null;

create table if not exists public.user_follows (
  follower_id uuid not null references public.profiles(id) on delete cascade,
  following_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (follower_id, following_id),
  check (follower_id <> following_id)
);
alter table public.user_follows enable row level security;
drop policy if exists user_follows_select_authenticated on public.user_follows;
create policy user_follows_select_authenticated on public.user_follows for select to authenticated using (true);
drop policy if exists user_follows_insert_own on public.user_follows;
create policy user_follows_insert_own on public.user_follows for insert to authenticated with check (follower_id = auth.uid());
drop policy if exists user_follows_delete_own on public.user_follows;
create policy user_follows_delete_own on public.user_follows for delete to authenticated using (follower_id = auth.uid());

do $$ begin
  if not exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'user_follows') then
    alter publication supabase_realtime add table public.user_follows;
  end if;
end $$;

create or replace function public.delete_my_account()
returns void language plpgsql security definer set search_path = public, auth as $$
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  delete from auth.users where id = auth.uid();
end;
$$;
revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;