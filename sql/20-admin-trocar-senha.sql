-- ============================================================
-- FUNÇÃO ADMIN: trocar senha de qualquer usuário pelo sistema
-- ============================================================
-- Permite que o ADMIN (você ou usuários com role='admin') troque
-- a senha de QUALQUER usuário direto pelo painel do sistema,
-- sem precisar de email de reset (útil quando o email é fictício).
--
-- IMPORTANTE: a função é SECURITY DEFINER (roda com privilegio
-- elevado), mas a primeira coisa que ela faz é checar se quem
-- está chamando é admin. Se não for, devolve "sem permissao".
-- ============================================================

-- Extensão pra crypt + gen_salt (geralmente já está habilitada)
create extension if not exists pgcrypto;

create or replace function admin_set_password(
  target_email text,
  new_password text
)
returns text
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
declare
  uid uuid;
  caller_email text;
  is_caller_admin boolean;
begin
  -- Quem está chamando (extrai email do JWT)
  caller_email := lower(coalesce(auth.jwt() ->> 'email', ''));
  if caller_email = '' then
    return 'erro: nao autenticado';
  end if;

  -- Verifica se quem chama é admin (na tabela profiles) OU é o vini
  select coalesce(role, '') = 'admin' into is_caller_admin
    from public.profiles
   where lower(email) = caller_email
   limit 1;

  if not coalesce(is_caller_admin, false)
     and caller_email not like 'vini@%' then
    return 'erro: sem permissao (apenas admin pode trocar senha de outros)';
  end if;

  -- Validações basicas
  if new_password is null or length(new_password) < 6 then
    return 'erro: senha precisa ter pelo menos 6 caracteres';
  end if;

  -- Acha o usuário alvo pelo email
  select id into uid
    from auth.users
   where lower(email) = lower(target_email)
   limit 1;

  if uid is null then
    return 'erro: usuario nao encontrado no Auth';
  end if;

  -- Atualiza a senha (bcrypt do crypt do pgcrypto)
  update auth.users
     set encrypted_password = crypt(new_password, gen_salt('bf')),
         updated_at = now(),
         email_confirmed_at = coalesce(email_confirmed_at, now())  -- confirma automaticamente
   where id = uid;

  -- Atualiza o hint salvo no profile
  update public.profiles
     set stored_password_hint = new_password
   where lower(email) = lower(target_email);

  return 'ok';
end;
$$;

-- Permite que qualquer usuário autenticado chame (a função em si checa permissão dentro)
grant execute on function admin_set_password(text, text) to authenticated;
