-- ============================================================
-- Captacoes — campos extras (cliente avulso, contatos, material, link)
-- ============================================================
alter table captacoes add column if not exists client_custom_name text;
alter table captacoes add column if not exists client_custom_company text;
alter table captacoes add column if not exists responsavel_nome text;
alter table captacoes add column if not exists responsavel_telefone text;
alter table captacoes add column if not exists contato_local_nome text;
alter table captacoes add column if not exists contato_local_telefone text;
alter table captacoes add column if not exists material_url text;
alter table captacoes add column if not exists briefing_arquivo_url text;
alter table captacoes add column if not exists briefing_arquivo_nome text;
alter table captacoes add column if not exists share_token text unique;
alter table captacoes add column if not exists referencia_url text;

-- Indice no token pra busca rapida na pagina publica
create index if not exists idx_capt_share_token on captacoes(share_token) where share_token is not null;

-- Permite leitura anonima (so do registro com token informado, controlado no client)
drop policy if exists "anon read captacoes by token" on captacoes;
create policy "anon read captacoes by token" on captacoes
  for select to anon using (share_token is not null);

-- Bucket pra anexos de briefing (criar manualmente no Supabase Storage tambem)
-- No painel: Storage > Create bucket > "captacoes-briefing" > Public: true
