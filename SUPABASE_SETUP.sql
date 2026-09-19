-- SUPABASE SETUP — Le lucciole di Nonna Teresa
create extension if not exists pgcrypto;

create table if not exists public.memories (
 id uuid primary key default gen_random_uuid(),
 author text not null default 'Una persona che ti vuole bene',
 text text not null default '',
 quote text not null default '',
 color text not null default '#ffd66e',
 image_url text not null default '',
 created_at timestamptz not null default now()
);
create table if not exists public.wishes (
 id uuid primary key default gen_random_uuid(),
 text text not null,
 created_at timestamptz not null default now()
);

alter table public.memories enable row level security;
alter table public.wishes enable row level security;

drop policy if exists memories_select_public on public.memories;
create policy memories_select_public on public.memories for select to anon,authenticated using (true);
drop policy if exists memories_insert_public on public.memories;
create policy memories_insert_public on public.memories for insert to anon,authenticated with check (true);
drop policy if exists memories_delete_public on public.memories;
create policy memories_delete_public on public.memories for delete to anon,authenticated using (true);

drop policy if exists wishes_select_public on public.wishes;
create policy wishes_select_public on public.wishes for select to anon,authenticated using (true);
drop policy if exists wishes_insert_public on public.wishes;
create policy wishes_insert_public on public.wishes for insert to anon,authenticated with check (true);
drop policy if exists wishes_delete_public on public.wishes;
create policy wishes_delete_public on public.wishes for delete to anon,authenticated using (true);

insert into storage.buckets(id,name,public)
values('memory-photos','memory-photos',true)
on conflict(id) do update set public=true;

drop policy if exists memory_photos_insert_public on storage.objects;
create policy memory_photos_insert_public on storage.objects for insert to anon,authenticated with check(bucket_id='memory-photos');
drop policy if exists memory_photos_read_public on storage.objects;
create policy memory_photos_read_public on storage.objects for select to anon,authenticated using(bucket_id='memory-photos');
drop policy if exists memory_photos_delete_public on storage.objects;
create policy memory_photos_delete_public on storage.objects for delete to anon,authenticated using(bucket_id='memory-photos');

do $$
begin
 begin alter publication supabase_realtime add table public.memories; exception when duplicate_object then null; end;
 begin alter publication supabase_realtime add table public.wishes; exception when duplicate_object then null; end;
end $$;
