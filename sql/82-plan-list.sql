-- ============================================================
-- 82 - Plano do cliente vira lista de verdade
--   plan_name guardava tudo num texto separado por vírgula. Como
--   'Plano Impulse + Captação' já tem "+" no nome, reabrir a tela
--   quebrava o texto errado, os checkboxes vinham desmarcados e o
--   save seguinte duplicava o plano. plan_list guarda a lista.
--   plan_name continua existindo como texto de exibição.
-- Idempotente.
-- ============================================================

alter table public.clients add column if not exists plan_list jsonb not null default '[]'::jsonb;

select count(*) || ' clientes prontos pra lista de planos' as resultado from public.clients;
