-- ============================================================
-- 81 - Cartões: compra parcelada
--   Uma compra parcelada vira N linhas em cartao_gastos, uma por mês.
--   Assim o total de cada mês continua sendo a soma simples de valor,
--   e cada parcela cai no mês em que ela realmente pesa na fatura.
--   O registro guarda o valor da compra inteira (valor_total) e a
--   posição da parcela (parcela_num de parcelas).
--   compra_id junta as parcelas da mesma compra.
-- Idempotente.
-- ============================================================

alter table public.cartao_gastos add column if not exists valor_total  numeric;
alter table public.cartao_gastos add column if not exists parcelas     integer not null default 1;
alter table public.cartao_gastos add column if not exists parcela_num  integer not null default 1;
alter table public.cartao_gastos add column if not exists compra_id    uuid;

create index if not exists idx_cartao_gastos_compra on public.cartao_gastos(compra_id);

-- Gasto antigo (à vista): o total da compra é o próprio valor.
update public.cartao_gastos set valor_total = valor where valor_total is null;

select count(*) || ' lancamentos com valor_total preenchido' as resultado
from public.cartao_gastos where valor_total is not null;
