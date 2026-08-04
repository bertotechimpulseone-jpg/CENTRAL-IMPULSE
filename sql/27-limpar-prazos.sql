-- ============================================================
-- LIMPEZA DE PRAZOS ANTIGOS (fictícios) NO CRONOGRAMA
-- ============================================================
-- Use isto se você ainda tem prazos "15/05/2026" e similares
-- aparecendo automaticamente no cronograma. Esse SQL zera
-- todos os deadlines do banco — você cadastra os reais depois.
--
-- ATENÇÃO: zera TODOS os prazos. Se você já cadastrou
-- prazos reais que quer manter, NÃO rode esse script —
-- delete manualmente os que estão errados.
-- ============================================================

-- Zera deadline de TODAS as linhas do cronograma
update cronograma set deadline = null;

-- Confirma quantas linhas foram afetadas:
select count(*) as linhas_com_prazo from cronograma where deadline is not null;
-- Resultado esperado: 0
