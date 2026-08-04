-- ============================================================
-- 51-precificacao.sql
-- Aba Precificação dentro de Comercial
-- Base de cálculo DRE + tabela de produtos com 3 faixas de preço
-- ============================================================

-- Tabela 1: parametros gerais (1 linha so — singleton)
create table if not exists precificacao_config (
  id uuid primary key default gen_random_uuid(),
  pessoas_custo numeric default 25000,
  custo_fixo_variavel numeric default 8000,
  clientes integer default 20,
  horas_trabalhadas integer default 364,
  -- valor_hora_calc = (pessoas_custo + custo_fixo_variavel) / horas_trabalhadas
  -- margem_padrao = 70 (default em %)
  margem_m numeric default 70,
  margem_g numeric default 100,
  margem_gg numeric default 200,
  margem_negociacao numeric default 10,
  observacoes text default '',
  updated_at timestamptz default now()
);

-- Tabela 2: produtos da precificacao
create table if not exists precificacao_produtos (
  id uuid primary key default gen_random_uuid(),
  produto text not null,
  categoria text default '',
  horas_estimadas numeric default 1,
  -- Precos M, G, GG editaveis (calculados auto se NULL)
  preco_m_override numeric,
  preco_g_override numeric,
  preco_gg_override numeric,
  margem_negociacao_pct numeric default 10,
  ordem integer default 0,
  ativo boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists idx_precif_prod_ordem on precificacao_produtos(ordem);
create index if not exists idx_precif_prod_ativo on precificacao_produtos(ativo) where ativo = true;

-- Trigger updated_at
create or replace function set_updated_at_precif()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_precif_config_updated on precificacao_config;
create trigger trg_precif_config_updated before update on precificacao_config
  for each row execute function set_updated_at_precif();

drop trigger if exists trg_precif_prod_updated on precificacao_produtos;
create trigger trg_precif_prod_updated before update on precificacao_produtos
  for each row execute function set_updated_at_precif();

-- RLS: leitura/escrita pra authenticated, controle de acesso no frontend
alter table precificacao_config enable row level security;
alter table precificacao_produtos enable row level security;

drop policy if exists "precif_config_authenticated" on precificacao_config;
create policy "precif_config_authenticated" on precificacao_config
  for all to authenticated using (true) with check (true);

drop policy if exists "precif_prod_authenticated" on precificacao_produtos;
create policy "precif_prod_authenticated" on precificacao_produtos
  for all to authenticated using (true) with check (true);

-- Insere config padrao se nao existe
insert into precificacao_config (pessoas_custo, custo_fixo_variavel, clientes, horas_trabalhadas)
select 25000, 8000, 20, 364
where not exists (select 1 from precificacao_config);

-- Insere produtos padrao (16 da planilha) se nao existem
insert into precificacao_produtos (produto, categoria, horas_estimadas, ordem) values
  ('Plano Pulse', 'Redes Sociais', 12, 1),
  ('Impulse +', 'Marketing Estratégico', 20, 2),
  ('Impulse + Captação', 'Premium', 25, 3),
  ('Captação', 'Produção', 10, 4),
  ('Captação + Postagem', 'Produção', 15, 5),
  ('Fee Fixo', 'Alocação', 40, 6),
  ('Identidade Visual', 'Branding', 20, 7),
  ('Ficha Google', 'SEO', 6, 8),
  ('Tráfego Pago [F-I]', 'Performance', 10, 9),
  ('Tráfego Pago [Google]', 'Performance', 10, 10),
  ('Combo tráfego [F-i-G]', 'Performance', 20, 11),
  ('Design para redes', '10 conteúdos', 10, 12),
  ('Fotografia', 'Retrato pessoal', 20, 13),
  ('Consultoria de marketing', 'Consultoria 2 sessões', 10, 14),
  ('E-book 10 páginas', '10 páginas', 8, 15),
  ('Post', 'Post', 0.5, 16),
  ('Carrossel', 'Carrossel', 1, 17),
  ('Site', 'Site', 10, 18)
on conflict do nothing;

select 'Tabelas precificacao criadas com produtos padrao' as resultado;
