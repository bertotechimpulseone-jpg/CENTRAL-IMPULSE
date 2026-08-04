
alter table profiles add column if not exists address text;
alter table profiles add column if not exists contract_type text default 'CLT';
alter table profiles add column if not exists bank text;
