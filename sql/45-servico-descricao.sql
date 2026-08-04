-- ============================================================
-- Adiciona coluna description em budget_services (orcamentos)
-- ============================================================
alter table budget_services add column if not exists description text;
comment on column budget_services.description is 'Descricao detalhada do servico que aparece no orcamento e PDF';
