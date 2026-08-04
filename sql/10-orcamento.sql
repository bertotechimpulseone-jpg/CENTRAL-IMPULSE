alter table budgets add column if not exists numero text;
alter table budgets add column if not exists client_data jsonb;
alter table budgets add column if not exists discount numeric(10,2) default 0;
alter table budgets add column if not exists payment_method text;
alter table budgets add column if not exists delivery_time text;
alter table budgets add column if not exists observations text;
alter table budgets add column if not exists valid_until date;
alter table budgets add column if not exists status text default 'rascunho';
