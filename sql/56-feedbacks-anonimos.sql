-- ============================================================
-- 56 - FEEDBACKS ANÔNIMOS ("Desabafo")
-- Canal de feedback 100% anônimo.
--   • Envio:   qualquer colaborador autenticado pode inserir.
--   • Leitura: SOMENTE Vinícius, Heidy e Haisa.
-- A tabela NÃO guarda autor (nem nome, e-mail ou ID) — anonimato real.
-- ============================================================

create table if not exists public.feedbacks_anonimos (
  id          uuid primary key default gen_random_uuid(),
  mensagem    text not null,
  created_at  timestamptz not null default now()
);

-- Privilégios de tabela (RLS ainda governa o acesso por linha)
grant select, insert on public.feedbacks_anonimos to authenticated;

-- Liga o Row Level Security (sem política = nega tudo)
alter table public.feedbacks_anonimos enable row level security;

-- ---------- INSERÇÃO: qualquer usuário autenticado ----------
drop policy if exists feedbacks_anon_insert on public.feedbacks_anonimos;
create policy feedbacks_anon_insert
  on public.feedbacks_anonimos
  for insert
  to authenticated
  with check (true);

-- ---------- LEITURA: só Vinícius, Heidy e Haisa ----------
-- Combina (a) lista de e-mails autorizados  +  (b) checagem pelo primeiro
-- nome no profile, para robustez caso o e-mail seja diferente.
-- >>> AJUSTE os e-mails abaixo para os reais de Heidy e Haisa, se necessário. <<<
drop policy if exists feedbacks_anon_select on public.feedbacks_anonimos;
create policy feedbacks_anon_select
  on public.feedbacks_anonimos
  for select
  to authenticated
  using (
    lower(auth.jwt() ->> 'email') in (
      'vini@impulseone.com.br',
      'vinicius@impulseone.com.br',
      'heidy@impulseone.com.br',
      'haisa@impulseone.com.br'
    )
    or exists (
      select 1
      from public.profiles p
      where lower(p.email) = lower(auth.jwt() ->> 'email')
        and lower(split_part(coalesce(p.full_name, ''), ' ', 1)) in (
          'vinicius','vinícius','vini','heidy','heidi','heydi','haisa','haísa','haysa'
        )
    )
  );

-- (Opcional) Permitir que os mesmos leitores APAGUEM mensagens.
-- Descomente se quiser dar essa opção a Vinícius/Heidy/Haisa.
-- drop policy if exists feedbacks_anon_delete on public.feedbacks_anonimos;
-- create policy feedbacks_anon_delete
--   on public.feedbacks_anonimos
--   for delete
--   to authenticated
--   using (
--     lower(auth.jwt() ->> 'email') in (
--       'vini@impulseone.com.br','vinicius@impulseone.com.br',
--       'heidy@impulseone.com.br','haisa@impulseone.com.br'
--     )
--   );
