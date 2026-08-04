-- ============================================================
-- 78 - Aba Dúvidas: base de conhecimento da equipe
--   Cada dúvida: título, descrição, link externo e/ou PDF.
-- Idempotente.
-- ============================================================

create table if not exists public.duvidas (
  id uuid primary key default gen_random_uuid(),
  titulo text not null,
  descricao text,
  link text,
  pdf_url text,
  created_at timestamptz default now(),
  created_by_email text
);

alter table public.duvidas enable row level security;
drop policy if exists "duv_all_auth" on public.duvidas;
create policy "duv_all_auth" on public.duvidas for all to authenticated using (true) with check (true);

-- seed: primeira dúvida (agendamento mLabs + Meta)
insert into public.duvidas (titulo, descricao, link, pdf_url, created_by_email)
select 'Como agendar conteúdos (mLabs e Meta/Facebook)',
       'Passo a passo completo pra agendar posts: pelo Workflow da mLabs (criar demandas, equipe, aprovação e agendamento automático) e pelo Meta Business Suite (Instagram + Facebook, incluindo Stories e Reels). O PDF tem as duas formas.',
       'https://ajuda.mlabs.com.br/pt-BR/articles/9509582-como-criar-demandas-no-novo-workflow-da-mlabs',
       '/duvidas/como-agendar-mlabs-meta.pdf',
       'vini@impulseone.com.br'
where not exists (select 1 from public.duvidas where titulo ilike '%como agendar%');

select 'Tabela duvidas criada + seed' as resultado;
