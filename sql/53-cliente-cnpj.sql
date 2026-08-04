-- ============================================================
-- 53-cliente-cnpj.sql
-- Adiciona campo cnpj na tabela clients (contract_start já existe)
-- ============================================================

alter table clients add column if not exists cnpj text;

comment on column clients.cnpj is 'CNPJ ou CPF da empresa cliente';

select 'Coluna cnpj garantida em clients' as resultado;
