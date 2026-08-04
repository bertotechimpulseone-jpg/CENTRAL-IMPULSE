-- ============================================================
-- Coluna POP no cronograma (POP 1 / POP 2 / POP 3 / vazio)
-- ============================================================
alter table cronograma add column if not exists pop text;
