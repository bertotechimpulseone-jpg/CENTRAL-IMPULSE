-- Campos extras editaveis em clients (informacoes de contato e links)
alter table clients add column if not exists contact_name text;
alter table clients add column if not exists contact_role text;
alter table clients add column if not exists contact_phone text;
alter table clients add column if not exists contact_email text;
alter table clients add column if not exists instagram_url text;
alter table clients add column if not exists drive_url text;
alter table clients add column if not exists meet_url text;
alter table clients add column if not exists mlabs_url text;
alter table clients add column if not exists site_url text;
alter table clients add column if not exists contrato_url text;
alter table clients add column if not exists criativos_url text;
alter table clients add column if not exists relatorios_url text;
alter table clients add column if not exists whatsapp_url text;
alter table clients add column if not exists owner_interno text;
alter table clients add column if not exists observacoes text;

-- Tabela de acessos do cliente (logins e senhas das plataformas)
create table if not exists client_credentials (
  id uuid primary key default uuid_generate_v4(),
  client_id uuid not null references clients(id) on delete cascade,
  categoria text not null,        -- 'redes', 'anuncios', 'ferramentas', 'hospedagem', 'outros'
  plataforma text not null,       -- 'Instagram', 'Meta Ads', 'Google Drive', etc.
  icone text,                     -- emoji ou char
  login text,
  senha text,
  url text,
  obs text,
  position int default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists idx_cred_client on client_credentials(client_id);
create index if not exists idx_cred_categoria on client_credentials(categoria);

alter table client_credentials enable row level security;

-- Quem esta autenticado pode tudo (a UI restringe por isGestor)
drop policy if exists "auth all credentials" on client_credentials;
create policy "auth all credentials" on client_credentials
  for all to authenticated using (true) with check (true);
