-- ============================================================
-- Formulario de cadastro que o proprio cliente preenche.
-- Link publico (?cadastro), sem login. O cliente envia e o cadastro
-- nasce sozinho, marcado como pre-cadastro pra equipe conferir.
-- ============================================================

-- 1) Campos novos no cadastro do cliente ---------------------
alter table public.clients
  add column if not exists endereco              text,
  add column if not exists bairro                text,
  add column if not exists cep                   text,
  add column if not exists dono_nome             text,
  add column if not exists dono_nacionalidade    text,
  add column if not exists dono_estado_civil     text,
  add column if not exists dono_profissao        text,
  add column if not exists dono_cpf              text,
  add column if not exists dono_rg               text,
  add column if not exists dono_endereco         text,
  add column if not exists dono_bairro           text,
  add column if not exists dono_cep              text,
  add column if not exists dono_telefone         text,
  add column if not exists dono_email            text,
  add column if not exists precisa_nota_fiscal   boolean,
  add column if not exists dia_pagamento         text;

comment on column public.clients.dono_cpf is
  'Dado pessoal do socio, usado so para emitir contrato. Visivel apenas para a administracao.';

-- 2) O que o cliente enviou, guardado como veio --------------
create table if not exists public.cadastros_cliente (
  id                  uuid primary key default gen_random_uuid(),
  client_id           uuid references public.clients(id) on delete set null,
  enviado_em          timestamptz not null default now(),

  empresa_nome        text not null,
  empresa_responsavel text,
  razao_social        text,
  cnpj                text,
  empresa_endereco    text,
  empresa_bairro      text,
  empresa_cep         text,

  dono_nome           text,
  dono_nacionalidade  text,
  dono_estado_civil   text,
  dono_profissao      text,
  dono_cpf            text,
  dono_rg             text,
  dono_endereco       text,
  dono_bairro         text,
  dono_cep            text,
  dono_telefone       text,
  dono_email          text,

  precisa_nota_fiscal boolean,
  dia_pagamento       text,
  aniversarios        jsonb not null default '[]'::jsonb,
  aniversario_empresa date,
  observacoes         text
);
create index if not exists cadastros_cliente_data_idx on public.cadastros_cliente (enviado_em desc);

alter table public.cadastros_cliente enable row level security;

-- Anonimo nao le nem escreve direto: so pela funcao abaixo.
drop policy if exists cadastros_cliente_leitura on public.cadastros_cliente;
create policy cadastros_cliente_leitura on public.cadastros_cliente
  for select to authenticated using (true);

-- 3) A porta de entrada: unica coisa que o link publico pode chamar
create or replace function public.cadastro_cliente_enviar(p jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $fn$
declare
  v_nome    text := nullif(btrim(coalesce(p->>'empresa_nome','')), '');
  v_cnpj    text := nullif(btrim(coalesce(p->>'cnpj','')), '');
  v_cliente uuid;
  v_envio   uuid;
  v_ini     text;
  v_anivs   jsonb := coalesce(p->'aniversarios', '[]'::jsonb);
  v_aniv_e  date;
begin
  if v_nome is null then
    raise exception 'Informe o nome da empresa';
  end if;
  if length(v_nome) > 160 then
    raise exception 'Nome da empresa muito longo';
  end if;
  if jsonb_typeof(v_anivs) <> 'array' or jsonb_array_length(v_anivs) > 12 then
    v_anivs := '[]'::jsonb;
  end if;

  begin
    v_aniv_e := nullif(p->>'aniversario_empresa','')::date;
  exception when others then
    v_aniv_e := null;
  end;

  -- Ja existe cadastro com esse CNPJ ou esse nome? Atualiza em vez de duplicar.
  select id into v_cliente
    from public.clients
   where (v_cnpj is not null and regexp_replace(coalesce(cnpj,''), '[^0-9]', '', 'g') = regexp_replace(v_cnpj, '[^0-9]', '', 'g'))
      or lower(btrim(name)) = lower(v_nome)
   order by created_at
   limit 1;

  v_ini := upper(coalesce(substring(regexp_replace(v_nome, '[^A-Za-z]', '', 'g') from 1 for 1), 'C'));
  v_ini := v_ini || upper(coalesce(substring(regexp_replace(split_part(v_nome, ' ', 2), '[^A-Za-z]', '', 'g') from 1 for 1), ''));

  if v_cliente is null then
    insert into public.clients (
      name, razao_social, cnpj, contact_name, phone, email,
      endereco, bairro, cep,
      dono_nome, dono_nacionalidade, dono_estado_civil, dono_profissao,
      dono_cpf, dono_rg, dono_endereco, dono_bairro, dono_cep, dono_telefone, dono_email,
      precisa_nota_fiscal, dia_pagamento,
      aniversarios, aniversario_empresa,
      status, pre_cadastro, pre_cadastro_origem, initials, color, observacoes
    ) values (
      v_nome,
      nullif(btrim(coalesce(p->>'razao_social','')),''),
      v_cnpj,
      nullif(btrim(coalesce(p->>'empresa_responsavel','')),''),
      nullif(btrim(coalesce(p->>'dono_telefone','')),''),
      nullif(btrim(coalesce(p->>'dono_email','')),''),
      nullif(btrim(coalesce(p->>'empresa_endereco','')),''),
      nullif(btrim(coalesce(p->>'empresa_bairro','')),''),
      nullif(btrim(coalesce(p->>'empresa_cep','')),''),
      nullif(btrim(coalesce(p->>'dono_nome','')),''),
      nullif(btrim(coalesce(p->>'dono_nacionalidade','')),''),
      nullif(btrim(coalesce(p->>'dono_estado_civil','')),''),
      nullif(btrim(coalesce(p->>'dono_profissao','')),''),
      nullif(btrim(coalesce(p->>'dono_cpf','')),''),
      nullif(btrim(coalesce(p->>'dono_rg','')),''),
      nullif(btrim(coalesce(p->>'dono_endereco','')),''),
      nullif(btrim(coalesce(p->>'dono_bairro','')),''),
      nullif(btrim(coalesce(p->>'dono_cep','')),''),
      nullif(btrim(coalesce(p->>'dono_telefone','')),''),
      nullif(btrim(coalesce(p->>'dono_email','')),''),
      (p->>'precisa_nota_fiscal')::boolean,
      nullif(btrim(coalesce(p->>'dia_pagamento','')),''),
      v_anivs, v_aniv_e,
      'active', true, 'formulario preenchido pelo cliente',
      v_ini, '#EC1E79',
      'Cadastro enviado pelo proprio cliente em ' || to_char(now() at time zone 'America/Sao_Paulo', 'DD/MM/YYYY HH24:MI') || '. Conferir antes de usar em contrato.'
    ) returning id into v_cliente;
  else
    -- So preenche o que estiver vazio: nada que a equipe ja ajustou e sobrescrito.
    update public.clients set
      razao_social        = coalesce(razao_social,        nullif(btrim(coalesce(p->>'razao_social','')),'')),
      cnpj                = coalesce(cnpj,                v_cnpj),
      contact_name        = coalesce(contact_name,        nullif(btrim(coalesce(p->>'empresa_responsavel','')),'')),
      phone               = coalesce(phone,               nullif(btrim(coalesce(p->>'dono_telefone','')),'')),
      email               = coalesce(email,               nullif(btrim(coalesce(p->>'dono_email','')),'')),
      endereco            = coalesce(endereco,            nullif(btrim(coalesce(p->>'empresa_endereco','')),'')),
      bairro              = coalesce(bairro,              nullif(btrim(coalesce(p->>'empresa_bairro','')),'')),
      cep                 = coalesce(cep,                 nullif(btrim(coalesce(p->>'empresa_cep','')),'')),
      dono_nome           = coalesce(dono_nome,           nullif(btrim(coalesce(p->>'dono_nome','')),'')),
      dono_nacionalidade  = coalesce(dono_nacionalidade,  nullif(btrim(coalesce(p->>'dono_nacionalidade','')),'')),
      dono_estado_civil   = coalesce(dono_estado_civil,   nullif(btrim(coalesce(p->>'dono_estado_civil','')),'')),
      dono_profissao      = coalesce(dono_profissao,      nullif(btrim(coalesce(p->>'dono_profissao','')),'')),
      dono_cpf            = coalesce(dono_cpf,            nullif(btrim(coalesce(p->>'dono_cpf','')),'')),
      dono_rg             = coalesce(dono_rg,             nullif(btrim(coalesce(p->>'dono_rg','')),'')),
      dono_endereco       = coalesce(dono_endereco,       nullif(btrim(coalesce(p->>'dono_endereco','')),'')),
      dono_bairro         = coalesce(dono_bairro,         nullif(btrim(coalesce(p->>'dono_bairro','')),'')),
      dono_cep            = coalesce(dono_cep,            nullif(btrim(coalesce(p->>'dono_cep','')),'')),
      dono_telefone       = coalesce(dono_telefone,       nullif(btrim(coalesce(p->>'dono_telefone','')),'')),
      dono_email          = coalesce(dono_email,          nullif(btrim(coalesce(p->>'dono_email','')),'')),
      precisa_nota_fiscal = coalesce(precisa_nota_fiscal, (p->>'precisa_nota_fiscal')::boolean),
      dia_pagamento       = coalesce(dia_pagamento,       nullif(btrim(coalesce(p->>'dia_pagamento','')),'')),
      aniversario_empresa = coalesce(aniversario_empresa, v_aniv_e),
      aniversarios        = case when coalesce(jsonb_array_length(aniversarios),0) = 0 then v_anivs else aniversarios end
    where id = v_cliente;
  end if;

  insert into public.cadastros_cliente (
    client_id, empresa_nome, empresa_responsavel, razao_social, cnpj,
    empresa_endereco, empresa_bairro, empresa_cep,
    dono_nome, dono_nacionalidade, dono_estado_civil, dono_profissao,
    dono_cpf, dono_rg, dono_endereco, dono_bairro, dono_cep, dono_telefone, dono_email,
    precisa_nota_fiscal, dia_pagamento, aniversarios, aniversario_empresa, observacoes
  ) values (
    v_cliente, v_nome,
    nullif(btrim(coalesce(p->>'empresa_responsavel','')),''),
    nullif(btrim(coalesce(p->>'razao_social','')),''), v_cnpj,
    nullif(btrim(coalesce(p->>'empresa_endereco','')),''),
    nullif(btrim(coalesce(p->>'empresa_bairro','')),''),
    nullif(btrim(coalesce(p->>'empresa_cep','')),''),
    nullif(btrim(coalesce(p->>'dono_nome','')),''),
    nullif(btrim(coalesce(p->>'dono_nacionalidade','')),''),
    nullif(btrim(coalesce(p->>'dono_estado_civil','')),''),
    nullif(btrim(coalesce(p->>'dono_profissao','')),''),
    nullif(btrim(coalesce(p->>'dono_cpf','')),''),
    nullif(btrim(coalesce(p->>'dono_rg','')),''),
    nullif(btrim(coalesce(p->>'dono_endereco','')),''),
    nullif(btrim(coalesce(p->>'dono_bairro','')),''),
    nullif(btrim(coalesce(p->>'dono_cep','')),''),
    nullif(btrim(coalesce(p->>'dono_telefone','')),''),
    nullif(btrim(coalesce(p->>'dono_email','')),''),
    (p->>'precisa_nota_fiscal')::boolean,
    nullif(btrim(coalesce(p->>'dia_pagamento','')),''),
    v_anivs, v_aniv_e,
    nullif(btrim(coalesce(p->>'observacoes','')),'')
  ) returning id into v_envio;

  return jsonb_build_object('ok', true, 'client_id', v_cliente, 'envio_id', v_envio);
end;
$fn$;

revoke all on function public.cadastro_cliente_enviar(jsonb) from public;
grant execute on function public.cadastro_cliente_enviar(jsonb) to anon, authenticated;
