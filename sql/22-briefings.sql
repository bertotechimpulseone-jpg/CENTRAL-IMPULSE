-- ============================================================
-- BRIEFINGS — formulários personalizados pra cliente responder
-- ============================================================
create table if not exists client_briefings (
  id uuid primary key default uuid_generate_v4(),
  client_id uuid references clients(id) on delete cascade,
  client_custom_name text,             -- pra briefings de cliente avulso
  title text not null default 'Briefing inicial',
  description text,                    -- mensagem de boas-vindas pro cliente
  questions jsonb not null default '[]'::jsonb,  -- array [{id, type, label, required, options[]}]
  responses jsonb,                     -- objeto {questionId: resposta}
  responded_at timestamptz,
  responded_by text,                   -- nome/email de quem respondeu
  share_token text unique,
  status text default 'rascunho',      -- 'rascunho' | 'enviado' | 'respondido'
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists idx_brief_client on client_briefings(client_id);
create index if not exists idx_brief_token on client_briefings(share_token) where share_token is not null;

alter table client_briefings enable row level security;

-- Usuários autenticados: tudo
drop policy if exists "auth all briefings" on client_briefings;
create policy "auth all briefings" on client_briefings
  for all to authenticated using (true) with check (true);

-- Anônimos: podem LER briefing pelo token + atualizar respostas
drop policy if exists "anon read briefing by token" on client_briefings;
create policy "anon read briefing by token" on client_briefings
  for select to anon using (share_token is not null);

drop policy if exists "anon update responses by token" on client_briefings;
create policy "anon update responses by token" on client_briefings
  for update to anon using (share_token is not null) with check (share_token is not null);
