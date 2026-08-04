-- ============================================================
-- 47-parcerias-investimento.sql
-- Adiciona campo de investimento em parcerias
-- ============================================================
alter table parcerias add column if not exists valor_investido numeric(12,2) default 0;
comment on column parcerias.valor_investido is 'Total investido nesta parceria (acordos, comissoes, materiais, etc)';

select 'Campo valor_investido adicionado em parcerias' as resultado;
