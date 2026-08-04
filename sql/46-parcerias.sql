-- ============================================================
-- 46-parcerias.sql
-- Sistema de parcerias com mensuracao de resultados
-- ============================================================

create table if not exists parcerias (
  id uuid primary key default uuid_generate_v4(),
  nome text not null,                       -- nome do parceiro
  logo_url text,
  tipo text default 'referral',             -- referral | co-marketing | fornecedor | cliente-compartilhado | indicador | outro
  status text default 'ativa',              -- ativa | negociacao | pausada | encerrada
  data_inicio date,
  data_encerramento date,
  contato_nome text,
  contato_email text,
  contato_telefone text,
  combinados text,                          -- texto livre com o que foi acordado
  condicoes_financeiras text,               -- comissao, valor fixo, etc
  link_contrato text,
  observacoes text,
  tags text,                                -- separadas por virgula
  proxima_reuniao date,
  prioridade text default 'media',          -- alta | media | baixa
  responsavel_nome text,
  responsavel_id uuid references profiles(id) on delete set null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists idx_parc_status on parcerias(status);
create index if not exists idx_parc_tipo on parcerias(tipo);
create index if not exists idx_parc_inicio on parcerias(data_inicio);

alter table parcerias enable row level security;
drop policy if exists "auth all parcerias" on parcerias;
create policy "auth all parcerias" on parcerias
  for all to authenticated using (true) with check (true);


-- Tabela de resultados / eventos da parceria
create table if not exists parcerias_resultados (
  id uuid primary key default uuid_generate_v4(),
  parceria_id uuid not null references parcerias(id) on delete cascade,
  data date not null default current_date,
  tipo text default 'lead',                 -- lead | venda | evento | conteudo | reuniao | outro
  descricao text not null,
  valor numeric(12,2) default 0,            -- valor R$ gerado/economizado
  contato_cliente text,                     -- nome do cliente/lead trazido pela parceria
  observacoes text,
  status text default 'concluido',          -- concluido | em-andamento | cancelado
  created_at timestamptz default now()
);

create index if not exists idx_parc_res_parc on parcerias_resultados(parceria_id);
create index if not exists idx_parc_res_data on parcerias_resultados(data);
create index if not exists idx_parc_res_tipo on parcerias_resultados(tipo);

alter table parcerias_resultados enable row level security;
drop policy if exists "auth all parc_res" on parcerias_resultados;
create policy "auth all parc_res" on parcerias_resultados
  for all to authenticated using (true) with check (true);

select 'Tabelas parcerias + parcerias_resultados criadas' as resultado;
