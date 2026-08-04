-- ============================================================
-- 70 - I3 v2: resumo nas atas + Combinados/lembretes + Atas assinadas
--   (1) coluna resumo em i3_reunioes (aparece no cartao compacto da home)
--   (2) i3_combinados: o que ficou tratado + responsavel + prazo + status
--   (3) i3_atas_assinadas: arquivo em anexo (bucket uploads) + resumo ao lado
-- Idempotente. Acesso segue o padrao do I3 (authenticated; gate no front por isGestor()).
-- Reusa a funcao public.set_updated_at_i3() criada no sql/69.
-- ============================================================

-- (1) Resumo da reuniao
alter table public.i3_reunioes add column if not exists resumo text default '';

-- (2) Combinados & lembretes (bloco geral)
create table if not exists public.i3_combinados (
  id           uuid primary key default gen_random_uuid(),
  descricao    text not null,          -- o que foi tratado / combinado
  responsavel  text,                   -- quem faz acontecer
  prazo        text,                   -- ex: 15/07 ou "fim do mes"
  status       text default 'pendente',-- pendente / feito
  ordem        int default 0,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);
grant select, insert, update, delete on public.i3_combinados to authenticated;
alter table public.i3_combinados enable row level security;
drop policy if exists i3_combinados_all on public.i3_combinados;
create policy i3_combinados_all on public.i3_combinados for all to authenticated using (true) with check (true);
drop trigger if exists trg_i3_combinados_updated on public.i3_combinados;
create trigger trg_i3_combinados_updated before update on public.i3_combinados
  for each row execute function public.set_updated_at_i3();

-- (3) Atas assinadas (arquivo + resumo)
create table if not exists public.i3_atas_assinadas (
  id               uuid primary key default gen_random_uuid(),
  titulo           text,
  resumo           text,
  arquivo_url      text,               -- link publico no bucket 'uploads'
  arquivo_nome     text,
  data_assinatura  text,               -- texto (formatos variados)
  ordem            int default 0,
  created_at       timestamptz not null default now()
);
grant select, insert, update, delete on public.i3_atas_assinadas to authenticated;
alter table public.i3_atas_assinadas enable row level security;
drop policy if exists i3_atas_assinadas_all on public.i3_atas_assinadas;
create policy i3_atas_assinadas_all on public.i3_atas_assinadas for all to authenticated using (true) with check (true);

select 'I3 v2 OK: coluna resumo + i3_combinados + i3_atas_assinadas' as resultado;
