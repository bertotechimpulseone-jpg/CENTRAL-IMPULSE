-- ============================================================
-- 72 - Clientes: nome social (nome preferido de exibição)
--   Guarda um "nome social" opcional por cliente. Quando preenchido,
--   vira o nome exibido na lista e no cabeçalho do cliente; o `name`
--   (nome cadastrado) continua guardado para registros/contratos.
-- Idempotente.
-- ============================================================

alter table public.clients add column if not exists nome_social text;

select 'Clientes OK: coluna clients.nome_social criada' as resultado;
