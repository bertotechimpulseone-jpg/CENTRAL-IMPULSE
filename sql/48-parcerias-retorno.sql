-- ============================================================
-- 48-parcerias-retorno.sql
-- Adiciona campo de retorno manual em parcerias
-- ============================================================
alter table parcerias add column if not exists valor_retorno numeric(12,2) default 0;
comment on column parcerias.valor_retorno is 'Retorno total consolidado (se preenchido sobrescreve soma dos resultados)';

select 'Campo valor_retorno adicionado' as resultado;
