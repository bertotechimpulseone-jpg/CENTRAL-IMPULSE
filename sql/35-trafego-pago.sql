-- ============================================================
-- Tráfego pago — campanhas por cliente
-- ============================================================

create table if not exists trafego_campanhas (
  id uuid primary key default uuid_generate_v4(),
  client_id uuid references clients(id) on delete cascade,
  client_name text,                       -- nome do cliente (cache para clients sem _dbId)
  data_ref date not null default current_date,   -- mês de referência (use dia 1 do mês)
  gestor_id uuid references profiles(id) on delete set null,
  gestor_nome text,                       -- cache
  plataforma text,                        -- Meta Ads | Google Ads | TikTok Ads | LinkedIn Ads | YouTube Ads | Outros
  objetivo text,                          -- Leads | Vendas | Conversas | Engajamento | Seguidores | Reconhecimento | Trafego | Vendas no Site | Outros
  campanha_nome text,                     -- nome da campanha (opcional)
  campanhas_qtd integer default 0,        -- quantidade de campanhas
  conjuntos_qtd integer default 0,        -- quantidade de conjuntos/ad sets
  status text default 'Ativa',            -- Ativa | Pausada | Encerrada | Planejada
  orcamento_total numeric(12,2) default 0,
  orcamento_diario numeric(12,2) default 0,
  gasto_semana numeric(12,2) default 0,
  gasto_total numeric(12,2) default 0,
  resultado integer default 0,            -- número de conversões/leads/vendas
  cpa numeric(12,2) default 0,            -- custo por aquisição (calculado: gasto_total/resultado)
  observacoes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists idx_trf_client on trafego_campanhas(client_id);
create index if not exists idx_trf_data on trafego_campanhas(data_ref);
create index if not exists idx_trf_plataforma on trafego_campanhas(plataforma);
create index if not exists idx_trf_status on trafego_campanhas(status);

alter table trafego_campanhas enable row level security;

drop policy if exists "auth all trafego" on trafego_campanhas;
create policy "auth all trafego" on trafego_campanhas
  for all to authenticated using (true) with check (true);
