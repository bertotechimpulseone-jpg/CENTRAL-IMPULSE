-- ============================================================
-- 85 - Tarefa para várias pessoas + histórico da observação do plano
--
--  tasks.grupo_id       : quando a tarefa é criada pra mais de um
--                         responsável, cada pessoa ganha a SUA linha
--                         (o checklist é individual) e o grupo_id liga
--                         todas elas, pra saber que nasceram juntas.
--
--  plan_observacao_hist : toda versão da observação do plano vira uma
--                         linha aqui. Nada é apagado, nunca.
-- Idempotente.
-- ============================================================

alter table public.tasks add column if not exists grupo_id uuid;
create index if not exists idx_tasks_grupo on public.tasks(grupo_id);
create index if not exists idx_tasks_client on public.tasks(client_id);

create table if not exists public.plan_observacao_hist (
  id          uuid primary key default gen_random_uuid(),
  client_id   uuid not null,
  texto       text,
  autor       text,
  autor_email text,
  criado_em   timestamptz not null default now()
);
create index if not exists idx_plan_obs_hist_cli on public.plan_observacao_hist(client_id, criado_em desc);

grant select, insert on public.plan_observacao_hist to authenticated, anon;
alter table public.plan_observacao_hist enable row level security;

-- Leitura e escrita liberadas pra quem está no sistema. Apagar e editar NÃO:
-- histórico que pode ser mexido não é histórico.
drop policy if exists plan_obs_hist_ler on public.plan_observacao_hist;
create policy plan_obs_hist_ler on public.plan_observacao_hist
  for select to authenticated, anon using (true);
drop policy if exists plan_obs_hist_gravar on public.plan_observacao_hist;
create policy plan_obs_hist_gravar on public.plan_observacao_hist
  for insert to authenticated, anon with check (true);

-- Semeia o histórico com o que já está escrito hoje, pra nenhuma anotação
-- existente ficar sem primeira versão registrada.
insert into public.plan_observacao_hist (client_id, texto, autor, criado_em)
select c.id, c.plan_observacao, coalesce(c.plan_observacao_por, 'registro anterior'),
       coalesce(c.plan_observacao_em, now())
  from public.clients c
 where coalesce(c.plan_observacao,'') <> ''
   and not exists (select 1 from public.plan_observacao_hist h where h.client_id = c.id);

select (select count(*) from public.plan_observacao_hist) || ' versoes no historico' as resultado;
