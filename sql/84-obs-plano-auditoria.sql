-- ============================================================
-- 84 - Quem escreveu a observação do plano, e quando
--   Sem isso não dá pra saber se o campo está vazio porque
--   ninguém escreveu ou porque a tela não mostrou.
-- Idempotente.
-- ============================================================

alter table public.clients add column if not exists plan_observacao_em  timestamptz;
alter table public.clients add column if not exists plan_observacao_por text;

-- As 7 anotações que já existem ficam marcadas como anteriores a esta mudança.
update public.clients
   set plan_observacao_em = coalesce(plan_observacao_em, now())
 where coalesce(plan_observacao,'') <> '' and plan_observacao_em is null;

select count(*) || ' anotacoes existentes marcadas' as resultado
from public.clients where plan_observacao_em is not null;
