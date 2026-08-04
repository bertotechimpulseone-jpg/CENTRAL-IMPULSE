-- ============================================================
-- 49-clientes-ocultos.sql
-- Adiciona campo pra ocultar cliente da lista principal
-- ============================================================
alter table clients add column if not exists oculto boolean default false;
create index if not exists idx_clients_oculto on clients(oculto) where oculto = true;

comment on column clients.oculto is 'Quando true, cliente fica escondido da lista principal mas continua no banco';

select 'Campo oculto adicionado em clients' as resultado;
