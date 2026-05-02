create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  display_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.documents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  local_document_id text not null,
  title text not null,
  source_file_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, local_document_id)
);

create table if not exists public.reading_positions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  document_id uuid not null references public.documents(id) on delete cascade,
  section_id text not null,
  paragraph_index integer not null,
  token_index integer not null,
  audio_position_ms integer not null default 0,
  updated_at timestamptz not null default now(),
  unique (user_id, document_id)
);

create table if not exists public.user_settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  voice_id text not null default 'default',
  speech_speed numeric not null default 1.0 check (speech_speed >= 0.5 and speech_speed <= 2.0),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.documents enable row level security;
alter table public.reading_positions enable row level security;
alter table public.user_settings enable row level security;

create policy profiles_select_own on public.profiles for select using (id = auth.uid());
create policy profiles_insert_own on public.profiles for insert with check (id = auth.uid());
create policy profiles_update_own on public.profiles for update using (id = auth.uid()) with check (id = auth.uid());

create policy documents_select_own on public.documents for select using (user_id = auth.uid());
create policy documents_insert_own on public.documents for insert with check (user_id = auth.uid());
create policy documents_update_own on public.documents for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy documents_delete_own on public.documents for delete using (user_id = auth.uid());

create policy reading_positions_select_own on public.reading_positions for select using (user_id = auth.uid());
create policy reading_positions_insert_own on public.reading_positions for insert with check (user_id = auth.uid());
create policy reading_positions_update_own on public.reading_positions for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy reading_positions_delete_own on public.reading_positions for delete using (user_id = auth.uid());

create policy user_settings_select_own on public.user_settings for select using (user_id = auth.uid());
create policy user_settings_insert_own on public.user_settings for insert with check (user_id = auth.uid());
create policy user_settings_update_own on public.user_settings for update using (user_id = auth.uid()) with check (user_id = auth.uid());

create trigger profiles_set_updated_at before update on public.profiles
for each row execute function public.set_updated_at();

create trigger documents_set_updated_at before update on public.documents
for each row execute function public.set_updated_at();

create trigger reading_positions_set_updated_at before update on public.reading_positions
for each row execute function public.set_updated_at();

create trigger user_settings_set_updated_at before update on public.user_settings
for each row execute function public.set_updated_at();
