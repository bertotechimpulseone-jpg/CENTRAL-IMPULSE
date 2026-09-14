-- Aniversario da empresa do cliente (data de fundacao / abertura).
-- Fica junto do aniversario dos contatos, que ja mora em clients.aniversarios.
alter table public.clients
  add column if not exists aniversario_empresa date;

comment on column public.clients.aniversario_empresa is
  'Data de fundacao da empresa do cliente. Vira evento anual no calendario e entra nas pendencias de cadastro quando esta vazia.';
