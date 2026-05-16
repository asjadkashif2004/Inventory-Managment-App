-- Run in Supabase Dashboard → SQL Editor (new projects)

create table if not exists public.items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  item_code text not null,
  name text not null,
  quantity integer not null default 0 check (quantity >= 0),
  price numeric(12, 2) not null default 0 check (price >= 0),
  created_at timestamptz not null default now(),
  unique (user_id, item_code)
);

alter table public.items enable row level security;

drop policy if exists "Users read own items" on public.items;
drop policy if exists "Users insert own items" on public.items;
drop policy if exists "Users update own items" on public.items;
drop policy if exists "Users delete own items" on public.items;

create policy "Users read own items"
  on public.items for select
  using (auth.uid() = user_id);

create policy "Users insert own items"
  on public.items for insert
  with check (auth.uid() = user_id);

create policy "Users update own items"
  on public.items for update
  using (auth.uid() = user_id);

create policy "Users delete own items"
  on public.items for delete
  using (auth.uid() = user_id);
