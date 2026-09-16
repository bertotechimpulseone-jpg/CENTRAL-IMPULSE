-- ============================================================
-- Apagar solicitacao de melhoria/bug.
--
-- Quem abriu pode apagar a propria. A administracao pode apagar qualquer uma.
-- A Bertotech apaga pelo painel dela, que usa a service role e nao passa
-- por RLS.
-- ============================================================

-- A administracao da Impulse. Separada de melhorias_permitido() porque a
-- Francielle ve e abre solicitacao, mas nao apaga a dos outros.
create or replace function public.melhorias_admin()
returns boolean
language sql
stable
as $$
  select lower(coalesce(auth.jwt() ->> 'email', '')) in (
    'vini@impulseone.com.br',
    'vinicius@impulseone.com.br',
    'haisa@impulseone.com.br',
    'heidy@impulseone.com.br',
    'edersonoliveira.eder@gmail.com'
  );
$$;

drop policy if exists melhorias_apagar on public.melhorias;
create policy melhorias_apagar on public.melhorias
  for delete to authenticated
  using (
    public.melhorias_permitido()
    and (
      public.melhorias_admin()
      or lower(coalesce(autor_email,'')) = lower(coalesce(auth.jwt() ->> 'email',''))
    )
  );
