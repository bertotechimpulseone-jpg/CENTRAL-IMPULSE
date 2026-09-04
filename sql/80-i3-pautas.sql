-- ============================================================
-- 80 - I3 · PAUTAS com assinatura eletrônica
--   i3_pautas             : a pauta da reunião (itens em jsonb) + assinaturas
--   i3_assinatura_senhas  : senha de assinatura de cada admin (hash bcrypt,
--                           NUNCA sai do banco — só as funções abaixo leem)
--
-- A assinatura não é gravada pelo app: ela passa pela função
-- i3_pauta_assinar(), que confere a senha e carimba nome, e-mail, hora,
-- código de verificação e o hash do conteúdo assinado. Um gatilho impede
-- que um UPDATE comum mexa na coluna assinaturas.
-- Idempotente — seguro rodar mais de uma vez.
-- ============================================================

create extension if not exists pgcrypto;

create table if not exists public.i3_pautas (
  id            uuid primary key default gen_random_uuid(),
  titulo        text not null,
  data_pauta    date,
  reuniao_id    uuid,                                   -- i3_reunioes.id (opcional)
  itens         jsonb not null default '[]'::jsonb,     -- [{assunto, responsavel, tempo, obs}]
  observacoes   text,
  status        text not null default 'aberta',         -- aberta | encerrada
  assinaturas   jsonb not null default '[]'::jsonb,     -- [{email, nome, assinado_em, codigo, conteudo_hash}]
  created_by_email text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);
create index if not exists idx_i3_pautas_data on public.i3_pautas(data_pauta desc);

create table if not exists public.i3_assinatura_senhas (
  email      text primary key,
  nome       text,
  senha_hash text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Quem é da gestão (mesma função das outras abas restritas). Recriada aqui
-- pra essa migration não depender da ordem de execução.
create or replace function public.is_gestor_app()
returns boolean language sql stable security definer set search_path = public as $fn$
  select
    lower(auth.jwt() ->> 'email') in (
      'vini@impulseone.com.br','vinicius@impulseone.com.br',
      'heidy@impulseone.com.br','heidi@impulseone.com.br','haisa@impulseone.com.br'
    )
    or exists (
      select 1 from public.profiles p
      where lower(p.email) = lower(auth.jwt() ->> 'email')
        and (
          lower(coalesce(p.role,'')) in ('admin','gestor')
          or lower(split_part(coalesce(p.full_name,''),' ',1)) in (
            'vinicius','vinícius','vini','heidy','heidi','heydi','heydy','haisa','haísa','haysa'
          )
        )
    );
$fn$;

-- ---------- pautas: só a gestão vê e mexe ----------
grant select, insert, update, delete on public.i3_pautas to authenticated;
alter table public.i3_pautas enable row level security;
drop policy if exists i3_pautas_select on public.i3_pautas;
create policy i3_pautas_select on public.i3_pautas for select to authenticated using (public.is_gestor_app());
drop policy if exists i3_pautas_insert on public.i3_pautas;
create policy i3_pautas_insert on public.i3_pautas for insert to authenticated with check (public.is_gestor_app());
drop policy if exists i3_pautas_update on public.i3_pautas;
create policy i3_pautas_update on public.i3_pautas for update to authenticated using (public.is_gestor_app()) with check (public.is_gestor_app());
drop policy if exists i3_pautas_delete on public.i3_pautas;
create policy i3_pautas_delete on public.i3_pautas for delete to authenticated using (public.is_gestor_app());

-- ---------- senhas: ninguém lê pelo app, nem a própria dona ----------
alter table public.i3_assinatura_senhas enable row level security;
revoke all on public.i3_assinatura_senhas from authenticated, anon;
drop policy if exists i3_senhas_nada on public.i3_assinatura_senhas;
create policy i3_senhas_nada on public.i3_assinatura_senhas for select to authenticated using (false);

-- ---------- gatilho: assinatura só entra pela função ----------
create or replace function public.i3_pautas_guard()
returns trigger language plpgsql as $fn$
begin
  if TG_OP = 'UPDATE'
     and new.assinaturas is distinct from old.assinaturas
     and coalesce(current_setting('i3.assinando', true), '') <> 'on' then
    new.assinaturas := old.assinaturas;   -- silenciosamente ignora
  end if;
  new.updated_at := now();
  return new;
end $fn$;
drop trigger if exists trg_i3_pautas_guard on public.i3_pautas;
create trigger trg_i3_pautas_guard before update on public.i3_pautas
  for each row execute function public.i3_pautas_guard();

-- ---------- tenho senha de assinatura cadastrada? ----------
create or replace function public.i3_assinatura_tem()
returns boolean language sql stable security definer set search_path = public as $fn$
  select exists (
    select 1 from public.i3_assinatura_senhas
    where email = lower(auth.jwt() ->> 'email')
  );
$fn$;

-- ---------- cadastrar / trocar a senha de assinatura ----------
-- Primeira vez: p_senha_atual pode vir vazia. Depois disso, só troca sabendo a atual.
create or replace function public.i3_assinatura_definir(p_senha text, p_senha_atual text default null)
returns jsonb language plpgsql security definer set search_path = public as $fn$
declare v_email text; v_nome text; v_hash text;
begin
  v_email := lower(auth.jwt() ->> 'email');
  if v_email is null then return jsonb_build_object('ok', false, 'erro', 'sessao'); end if;
  if not public.is_gestor_app() then return jsonb_build_object('ok', false, 'erro', 'permissao'); end if;
  if p_senha is null or length(trim(p_senha)) < 6 then
    return jsonb_build_object('ok', false, 'erro', 'curta');
  end if;
  select senha_hash into v_hash from public.i3_assinatura_senhas where email = v_email;
  if v_hash is not null then
    if p_senha_atual is null or v_hash <> crypt(p_senha_atual, v_hash) then
      return jsonb_build_object('ok', false, 'erro', 'senha_atual');
    end if;
  end if;
  select coalesce(full_name, v_email) into v_nome from public.profiles where lower(email) = v_email limit 1;
  insert into public.i3_assinatura_senhas (email, nome, senha_hash)
  values (v_email, coalesce(v_nome, v_email), crypt(p_senha, gen_salt('bf', 10)))
  on conflict (email) do update
    set senha_hash = excluded.senha_hash, nome = excluded.nome, updated_at = now();
  return jsonb_build_object('ok', true);
end $fn$;

-- ---------- assinar a pauta ----------
create or replace function public.i3_pauta_assinar(p_pauta_id uuid, p_senha text, p_conteudo_hash text default null)
returns jsonb language plpgsql security definer set search_path = public as $fn$
declare v_email text; v_nome text; v_hash text; v_ass jsonb; v_nova jsonb;
begin
  v_email := lower(auth.jwt() ->> 'email');
  if v_email is null then return jsonb_build_object('ok', false, 'erro', 'sessao'); end if;
  if not public.is_gestor_app() then return jsonb_build_object('ok', false, 'erro', 'permissao'); end if;
  select senha_hash into v_hash from public.i3_assinatura_senhas where email = v_email;
  if v_hash is null then return jsonb_build_object('ok', false, 'erro', 'sem_senha'); end if;
  if v_hash <> crypt(coalesce(p_senha, ''), v_hash) then
    return jsonb_build_object('ok', false, 'erro', 'senha');
  end if;
  select assinaturas into v_ass from public.i3_pautas where id = p_pauta_id;
  if v_ass is null then return jsonb_build_object('ok', false, 'erro', 'pauta'); end if;
  select coalesce(full_name, v_email) into v_nome from public.profiles where lower(email) = v_email limit 1;
  -- re-assinatura: a assinatura antiga da mesma pessoa sai e entra a nova
  select coalesce(jsonb_agg(x), '[]'::jsonb) into v_ass
    from jsonb_array_elements(v_ass) x where lower(x->>'email') <> v_email;
  v_nova := jsonb_build_object(
    'email', v_email,
    'nome', coalesce(v_nome, v_email),
    'assinado_em', to_char(now() at time zone 'America/Sao_Paulo', 'YYYY-MM-DD"T"HH24:MI:SS'),
    'conteudo_hash', p_conteudo_hash,
    'codigo', upper(substr(encode(digest(p_pauta_id::text || v_email || clock_timestamp()::text || coalesce(p_conteudo_hash, ''), 'sha256'), 'hex'), 1, 12))
  );
  v_ass := v_ass || jsonb_build_array(v_nova);
  perform set_config('i3.assinando', 'on', true);
  update public.i3_pautas set assinaturas = v_ass where id = p_pauta_id;
  return jsonb_build_object('ok', true, 'assinatura', v_nova, 'assinaturas', v_ass);
end $fn$;

-- ---------- sócio pode zerar a senha de quem esqueceu ----------
create or replace function public.i3_assinatura_resetar(p_email text)
returns jsonb language plpgsql security definer set search_path = public as $fn$
begin
  if lower(auth.jwt() ->> 'email') not in (
    'vini@impulseone.com.br','vinicius@impulseone.com.br',
    'heidy@impulseone.com.br','heidi@impulseone.com.br','haisa@impulseone.com.br'
  ) then return jsonb_build_object('ok', false, 'erro', 'permissao'); end if;
  delete from public.i3_assinatura_senhas where email = lower(p_email);
  return jsonb_build_object('ok', true);
end $fn$;

revoke all on function public.i3_assinatura_definir(text, text) from public, anon;
revoke all on function public.i3_pauta_assinar(uuid, text, text) from public, anon;
revoke all on function public.i3_assinatura_resetar(text) from public, anon;
grant execute on function public.i3_assinatura_tem() to authenticated;
grant execute on function public.i3_assinatura_definir(text, text) to authenticated;
grant execute on function public.i3_pauta_assinar(uuid, text, text) to authenticated;
grant execute on function public.i3_assinatura_resetar(text) to authenticated;

select 'I3 pautas + assinatura eletronica prontos' as resultado;
