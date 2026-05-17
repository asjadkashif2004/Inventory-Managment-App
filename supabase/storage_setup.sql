-- Run in Supabase Dashboard → SQL Editor (profile pictures)

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do update set public = true;

drop policy if exists "Avatar public read" on storage.objects;
drop policy if exists "Avatar insert own" on storage.objects;
drop policy if exists "Avatar update own" on storage.objects;
drop policy if exists "Avatar delete own" on storage.objects;

create policy "Avatar public read"
  on storage.objects for select
  using (bucket_id = 'avatars');

create policy "Avatar insert own"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "Avatar update own"
  on storage.objects for update
  to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "Avatar delete own"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
