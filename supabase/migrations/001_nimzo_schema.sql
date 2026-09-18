-- Nimzo Step 4: schema and row-level security foundation.
-- Run with the Supabase CLI or SQL editor after creating a Supabase project.

create extension if not exists pgcrypto;

do $$
begin
  create type public.wallet_transaction_type as enum ('recharge', 'game_win', 'room_gift', 'withdraw', 'adjustment');
exception
  when duplicate_object then null;
end $$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '',
  bio text not null default '',
  avatar_url text,
  level integer not null default 1 check (level > 0),
  friends_count integer not null default 0 check (friends_count >= 0),
  followers_count integer not null default 0 check (followers_count >= 0),
  following_count integer not null default 0 check (following_count >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.rooms (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  subtitle text not null default '',
  category text not null default 'All',
  listener_count integer not null default 0 check (listener_count >= 0),
  is_featured boolean not null default false,
  created_by uuid not null references public.profiles(id) on delete restrict,
  host_id uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.room_seats (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.rooms(id) on delete cascade,
  position integer not null check (position between 0 and 9),
  active boolean not null default false,
  user_id uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  unique (room_id, position)
);

create table if not exists public.social_posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  text text not null,
  image_url text,
  likes integer not null default 0 check (likes >= 0),
  comments integer not null default 0 check (comments >= 0),
  shares integer not null default 0 check (shares >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.social_posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  text text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.post_likes (
  post_id uuid not null references public.social_posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);

create table if not exists public.post_follows (
  follower_id uuid not null references public.profiles(id) on delete cascade,
  following_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (follower_id, following_id),
  check (follower_id <> following_id)
);

create table if not exists public.wallets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles(id) on delete cascade,
  balance bigint not null default 0 check (balance >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.wallet_transactions (
  id uuid primary key default gen_random_uuid(),
  wallet_id uuid not null references public.wallets(id) on delete cascade,
  type public.wallet_transaction_type not null,
  amount bigint not null,
  description text not null default '',
  created_at timestamptz not null default now()
);

create table if not exists public.games (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  category text not null default 'Classic',
  created_at timestamptz not null default now()
);

create table if not exists public.gifts (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  coin_cost bigint not null check (coin_cost > 0),
  icon_name text,
  created_at timestamptz not null default now()
);

create table if not exists public.host_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles(id) on delete cascade,
  level integer not null default 1 check (level > 0),
  agency_name text,
  earnings_coins bigint not null default 0 check (earnings_coins >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'display_name', ''))
  on conflict (id) do nothing;

  insert into public.wallets (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

create index if not exists rooms_category_idx on public.rooms(category);
create index if not exists rooms_created_by_idx on public.rooms(created_by);
create index if not exists rooms_host_id_idx on public.rooms(host_id);
create index if not exists room_seats_room_id_idx on public.room_seats(room_id);
create index if not exists social_posts_user_id_idx on public.social_posts(user_id);
create index if not exists social_posts_created_at_idx on public.social_posts(created_at desc);
create index if not exists comments_post_id_idx on public.comments(post_id);
create index if not exists comments_user_id_idx on public.comments(user_id);
create index if not exists post_likes_user_id_idx on public.post_likes(user_id);
create index if not exists post_follows_following_id_idx on public.post_follows(following_id);
create index if not exists wallet_transactions_wallet_id_idx on public.wallet_transactions(wallet_id);
create index if not exists host_profiles_user_id_idx on public.host_profiles(user_id);

alter table public.profiles enable row level security;
alter table public.rooms enable row level security;
alter table public.room_seats enable row level security;
alter table public.social_posts enable row level security;
alter table public.comments enable row level security;
alter table public.post_likes enable row level security;
alter table public.post_follows enable row level security;
alter table public.wallets enable row level security;
alter table public.wallet_transactions enable row level security;
alter table public.games enable row level security;
alter table public.gifts enable row level security;
alter table public.host_profiles enable row level security;

create policy profiles_select_authenticated on public.profiles for select to authenticated using (true);
create policy profiles_insert_own on public.profiles for insert to authenticated with check (id = auth.uid());
create policy profiles_update_own on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

create policy rooms_select_authenticated on public.rooms for select to authenticated using (true);
create policy rooms_insert_own on public.rooms for insert to authenticated with check (created_by = auth.uid());
create policy rooms_update_owner on public.rooms for update to authenticated using (created_by = auth.uid()) with check (created_by = auth.uid());
create policy rooms_delete_owner on public.rooms for delete to authenticated using (created_by = auth.uid());

create policy room_seats_select_authenticated on public.room_seats for select to authenticated using (true);
create policy room_seats_insert_owner_or_self on public.room_seats for insert to authenticated with check (user_id = auth.uid() or exists (select 1 from public.rooms as owned_room where owned_room.id = room_seats.room_id and owned_room.created_by = auth.uid()));
create policy room_seats_update_owner_or_self on public.room_seats for update to authenticated using (user_id = auth.uid() or exists (select 1 from public.rooms as owned_room where owned_room.id = room_seats.room_id and owned_room.created_by = auth.uid())) with check (user_id = auth.uid() or exists (select 1 from public.rooms as owned_room where owned_room.id = room_seats.room_id and owned_room.created_by = auth.uid()));

create policy social_posts_select_authenticated on public.social_posts for select to authenticated using (true);
create policy social_posts_insert_own on public.social_posts for insert to authenticated with check (user_id = auth.uid());
create policy social_posts_update_own on public.social_posts for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy social_posts_delete_own on public.social_posts for delete to authenticated using (user_id = auth.uid());

create policy comments_select_authenticated on public.comments for select to authenticated using (true);
create policy comments_insert_own on public.comments for insert to authenticated with check (user_id = auth.uid());
create policy comments_update_own on public.comments for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy comments_delete_own on public.comments for delete to authenticated using (user_id = auth.uid());

create policy post_likes_select_authenticated on public.post_likes for select to authenticated using (true);
create policy post_likes_insert_own on public.post_likes for insert to authenticated with check (user_id = auth.uid());
create policy post_likes_delete_own on public.post_likes for delete to authenticated using (user_id = auth.uid());

create policy post_follows_select_authenticated on public.post_follows for select to authenticated using (true);
create policy post_follows_insert_own on public.post_follows for insert to authenticated with check (follower_id = auth.uid());
create policy post_follows_delete_own on public.post_follows for delete to authenticated using (follower_id = auth.uid());

create policy wallets_select_own on public.wallets for select to authenticated using (user_id = auth.uid());
create policy wallet_transactions_select_own on public.wallet_transactions for select to authenticated using (exists (select 1 from public.wallets where wallets.id = wallet_transactions.wallet_id and wallets.user_id = auth.uid()));

create policy games_select_authenticated on public.games for select to authenticated using (true);
create policy gifts_select_authenticated on public.gifts for select to authenticated using (true);

create policy host_profiles_select_own on public.host_profiles for select to authenticated using (user_id = auth.uid());
create policy host_profiles_insert_own on public.host_profiles for insert to authenticated with check (user_id = auth.uid());
create policy host_profiles_update_own on public.host_profiles for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Wallet balances and transaction rows intentionally have no client insert/update/delete policies.
-- Any future coin operation must be implemented in a reviewed server-side function or Edge Function.
