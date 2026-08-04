alter table profiles add column if not exists permissions text[] default array['dashboard','clientes','cronograma','captacao','operacional','calendario','reunioes','conteudo','feedback','ponto','arquivos','config']::text[];
alter table profiles add column if not exists email text;
alter table profiles add column if not exists enabled boolean default true;

-- Atualiza profiles existentes pra terem todas permissoes
update profiles set permissions = array['dashboard','clientes','cronograma','captacao','operacional','calendario','reunioes','conteudo','feedback','ponto','arquivos','config'] where permissions is null;
