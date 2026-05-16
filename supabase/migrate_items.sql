-- Run this if you already created the OLD items table (title / description).
-- Supabase Dashboard → SQL Editor → Run

alter table public.items add column if not exists item_code text;
alter table public.items add column if not exists name text;
alter table public.items add column if not exists quantity integer not null default 0;
alter table public.items add column if not exists price numeric(12, 2) not null default 0;

-- Copy old data if present
update public.items
set
  item_code = coalesce(item_code, 'ITEM-' || left(id::text, 8)),
  name = coalesce(name, title, 'Unnamed'),
  quantity = coalesce(quantity, 0),
  price = coalesce(price, 0)
where item_code is null or name is null;

alter table public.items alter column item_code set not null;
alter table public.items alter column name set not null;

alter table public.items drop column if exists title;
alter table public.items drop column if exists description;

alter table public.items drop constraint if exists items_user_id_item_code_key;
alter table public.items add constraint items_user_id_item_code_key unique (user_id, item_code);

alter table public.items drop constraint if exists items_quantity_check;
alter table public.items add constraint items_quantity_check check (quantity >= 0);

alter table public.items drop constraint if exists items_price_check;
alter table public.items add constraint items_price_check check (price >= 0);
