-- ============================================================
-- Captacoes — prazo de entrega (15 dias apos data da captacao)
-- ============================================================

alter table captacoes add column if not exists prazo_entrega date;
alter table captacoes add column if not exists entregue boolean default false;
alter table captacoes add column if not exists entregue_em timestamptz;

create index if not exists idx_capt_prazo on captacoes(prazo_entrega) where entregue = false;

comment on column captacoes.prazo_entrega is 'Data limite pra entrega (default: scheduled_date + 15 dias)';
comment on column captacoes.entregue is 'Marcado true quando a captacao for entregue ao cliente';
