-- ============================================================
-- Campos extras de pagamento no perfil
-- ============================================================

-- Chave PIX (texto livre: pode ser CPF, CNPJ, email, telefone, aleatória)
alter table profiles add column if not exists pix_key text;

-- Tipo de documento (CPF ou CNPJ) — controla o que está no campo "cpf"
alter table profiles add column if not exists cpf_type text default 'CPF';
