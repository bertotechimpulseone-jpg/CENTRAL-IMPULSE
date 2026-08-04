-- ============================================================
-- Relacionamento com clientes — timeline de contatos
-- ============================================================

create table if not exists client_relationships (
  id uuid primary key default uuid_generate_v4(),
  client_id uuid not null references clients(id) on delete cascade,
  profile_id uuid references profiles(id) on delete set null,
  responsavel_nome text,                  -- cache do nome do responsável
  tipo text not null,                     -- whatsapp | ligacao | reuniao | email | presencial | feedback | suporte | aprovacao
  data_contato timestamptz not null default now(),
  resumo text not null,                   -- o que foi tratado
  proxima_acao text,                      -- texto livre da próxima ação
  proxima_data date,                      -- quando essa próxima ação deve acontecer
  arquivo_url text,                       -- link de anexo (Supabase Storage ou base64)
  arquivo_nome text,                      -- nome original do arquivo
  observacoes_internas text,              -- só visível pra equipe
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists idx_rel_client on client_relationships(client_id);
create index if not exists idx_rel_data on client_relationships(data_contato desc);
create index if not exists idx_rel_tipo on client_relationships(tipo);
create index if not exists idx_rel_responsavel on client_relationships(profile_id);
create index if not exists idx_rel_proxima on client_relationships(proxima_data);

alter table client_relationships enable row level security;

drop policy if exists "auth all relationships" on client_relationships;
create policy "auth all relationships" on client_relationships
  for all to authenticated using (true) with check (true);
