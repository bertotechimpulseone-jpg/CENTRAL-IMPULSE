create table if not exists custom_links (
  id uuid primary key default uuid_generate_v4(),
  link_key text unique not null,
  url text not null,
  label text,
  created_by uuid,
  created_at timestamptz default now()
);

alter table custom_links enable row level security;
create policy "auth all" on custom_links for all to authenticated using (true) with check (true);
