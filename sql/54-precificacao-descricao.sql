-- ============================================================
-- 54-precificacao-descricao.sql
-- Adiciona campo descricao nos produtos da precificacao
-- Texto livre que descreve o escopo do servico — usado nos orcamentos
-- ============================================================

alter table precificacao_produtos add column if not exists descricao text default '';

comment on column precificacao_produtos.descricao is 'Descrição/escopo do serviço — aparece no orçamento e PDF';

select 'Campo descricao adicionado em precificacao_produtos' as resultado;
