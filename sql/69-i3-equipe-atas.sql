-- ============================================================
-- 69 - I3: Painel da Equipe (visao dos socios) + expansao das atas
--   Espelha a planilha "Operacoes e RH": roster com Farol, contrato,
--   vencimento, M. Conduta, valores, aniversario, feedback e carteira
--   de clientes. + 3 secoes novas nas atas (pontos positivos, financeiro,
--   pontos para ver). NAO inclui ferias/freelas (ja existem no sistema).
-- Idempotente. Acesso segue o padrao do I3 (authenticated; gate no front por isGestor()).
-- ============================================================

-- ---- Painel da Equipe (roster vivo dos socios) ----
create table if not exists public.i3_equipe (
  id               uuid primary key default gen_random_uuid(),
  colaborador      text not null,
  cargo            text,
  inicio           text,           -- inicio na Impulse (texto, formatos variados)
  contrato         text,           -- Ok PJ / Ok ITD / Freelancer / ...
  vcto_contrato    text,           -- vencimento do contrato
  manual_conduta   boolean default false,
  valores          text,           -- remuneracao / regra de pagamento (texto livre)
  aniversario      text,
  ultimo_feedback  text,
  ultima_bonif     text,
  farol            text,           -- Bom / Regular / Ruim / N/D / Fixo
  clientes         jsonb not null default '[]'::jsonb,  -- carteira de clientes (array de nomes)
  ativo            boolean default true,
  ordem            int default 0,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);
create index if not exists idx_i3_equipe_ordem on public.i3_equipe(ordem, colaborador);

grant select, insert, update, delete on public.i3_equipe to authenticated;
alter table public.i3_equipe enable row level security;
-- Mesmo padrao das outras tabelas do I3: authenticated CRUD (gate real fica no frontend por isGestor()).
drop policy if exists i3_equipe_all on public.i3_equipe;
create policy i3_equipe_all on public.i3_equipe for all to authenticated using (true) with check (true);

-- trigger updated_at (reusa a funcao do sql/50 se existir; senao cria)
create or replace function public.set_updated_at_i3()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;
drop trigger if exists trg_i3_equipe_updated on public.i3_equipe;
create trigger trg_i3_equipe_updated before update on public.i3_equipe
  for each row execute function public.set_updated_at_i3();

-- ---- Expansao das atas (i3_reunioes) ----
alter table public.i3_reunioes add column if not exists pontos_positivos text default '';
alter table public.i3_reunioes add column if not exists financeiro text default '';
alter table public.i3_reunioes add column if not exists pontos_para_ver text default '';

select 'I3: tabela i3_equipe criada + atas expandidas (pontos_positivos/financeiro/pontos_para_ver)' as resultado;

-- (O seed do roster e das atas historicas e anexado abaixo por script.)

-- ===== SEED gerado da planilha (roster mai/2025 + atas historicas) — idempotente =====
insert into public.i3_equipe (colaborador, cargo, inicio, contrato, vcto_contrato, manual_conduta, valores, aniversario, ultimo_feedback, ultima_bonif, farol, clientes)
select v.colaborador, v.cargo, v.inicio, v.contrato, v.vcto_contrato, v.manual_conduta, v.valores, v.aniversario, v.ultimo_feedback, v.ultima_bonif, v.farol, v.clientes from (values
  ('Haisa', 'CEO', '01/07/2023', 'Ok', NULL, true, NULL, '30/09/2025', NULL, NULL, NULL, '[]'::jsonb),
  ('Heidy', 'CFO', '01/07/2023', 'Ok', NULL, true, NULL, '22/02/1989', NULL, NULL, NULL, '[]'::jsonb),
  ('Vini', 'Head de marketing', '01/08/2023', 'Ok PJ', NULL, true, NULL, '21/10/1999', NULL, NULL, 'Bom', jsonb_build_array('Academia 61', 'Banca', 'Biehl', 'Portal de Suporte', 'PS ID', 'Tassy', 'Click Sindico', 'Concept', 'Empreenda-me', 'Eucassel', 'Impulse', 'ITD', 'MIG', 'Marmitina', 'Nação Verde', 'Natacenter', 'Rômulo', 'Steel', 'Top Sports', 'Vizzio', 'Ymani', 'Fit Box')),
  ('Ellen', 'PJ', '01/02/2024', 'Ok PJ', NULL, true, '1,500.00', '16/10/1999', '11/06', 'March/25', 'Regular', jsonb_build_array('Biehl', 'Click Sindico', 'Concept', 'ITD', 'Nação Verde', 'Steel', 'Top Sports', 'Ymani')),
  ('Julia', 'PJ', '04/10/2023', 'Ok PJ', NULL, true, '1,000.00', '28/07/2006', '11/06', 'May/25', 'Regular', jsonb_build_array('Academia 61', 'Impulse', 'Marmitina', 'Nação Verde', 'Natacenter', 'Natacenter', 'Steel', 'Haisa')),
  ('Antonio (planilha separada)', 'Corretor', '01/03/2024', NULL, NULL, false, '30 fee fixo 20 demais', '11/05/1990', NULL, NULL, 'Regular', '[]'::jsonb),
  ('Su Nogueira', 'PJ', '01/06/2024', 'Freelancer', NULL, false, '197,00 cada MIV', '28/02/1989', NULL, NULL, 'Regular', '[]'::jsonb),
  ('Eduarda', 'Estágio - D1', '10/10/2024', 'Ok ITD', '09/04/2025', false, '700.00', '22/03/2004', NULL, NULL, 'Regular', jsonb_build_array('Concept')),
  ('Nathan', 'Estágio - Social Mídea', '16/10/2024', 'Ok ITD', '16/04/2025', false, '700.00', '04/07/2001', NULL, NULL, 'Bom', '[]'::jsonb),
  ('Henrique', 'PJ', '12/08/2024', 'Ok PJ', NULL, true, '700,00 + 300 p/c', '27/11/2000', '13/06', 'January/25', 'Regular', jsonb_build_array('Eucassel', 'Impulse', 'Marmitina')),
  ('Isabelle', 'Estágio', '11/11/2024', 'Ok ITD', '12/11/2025', true, '700.00', '11/06/2003', '13/06', NULL, 'Regular', jsonb_build_array('Banca', 'Impulse', 'Nação Verde', 'Natacenter', 'Clean X')),
  ('Clara', 'PJ - D3', '14/11/2024', 'Ok PJ', '13/07/2025', false, '700,00 + 300 p/c', '26/06/2025', NULL, 'January/25', 'Regular', '[]'::jsonb),
  ('Fran', 'PJ - Audio Visual', '21/01/2025', 'Freelancer', 'Freelancer', false, '150,00 captação', NULL, NULL, NULL, 'N/D', '[]'::jsonb),
  ('Enrique', 'PJ', '20/02/2025', 'OK PJ', NULL, true, '350 Mig', '29/01/2001', NULL, NULL, 'Bom', jsonb_build_array('MIG')),
  ('Haniel', 'PJ', '25/02/2025', 'Ok PJ', NULL, true, '1,000.00', '13/09/1995', '17/06', NULL, 'Bom', jsonb_build_array('Tassy', 'Eucassel', 'MIG', 'Marmitina', 'Natacenter', 'Rômulo', 'Fitbox')),
  ('Sabrina', 'PJ', '27/01/2024', 'Ok PJ', NULL, true, '300,00 p/c +25 extra', '10/04/1999', NULL, NULL, 'Bom', jsonb_build_array('Vizzio', 'R$ 225.00')),
  ('André', 'PJ - Tráfego', '30/01/2025', 'OK PJ', NULL, true, '280,00 por cliente', '07/06/1997', NULL, NULL, 'N/D', jsonb_build_array('Academia 61', 'MIG', 'Nação Verde', 'Natacenter', 'Steel', 'Vizzio')),
  ('Mateus', 'PJ -', '28/02/2025', 'OK PJ', NULL, true, '300,00 por cliente', '02/03/2004', NULL, NULL, 'Regular', jsonb_build_array('Banca', 'Tassy')),
  ('Tiago - Fotográgo', 'PJ', '01/02/2025', 'Freelancer', 'Freelancer', false, '250,00 por cliente', NULL, NULL, NULL, 'Bom', '[]'::jsonb),
  ('Wini - Edição', 'Estágio', '21/03/2025', 'Ok ITD', '24/09/2025', true, '700.00', '24/05/2009', '17/06', NULL, 'Ruim', '[]'::jsonb),
  ('Bento', 'Estagio', '23/04/2025', 'Ok ITD', '05/07/2025', true, '700.00', '20/06/2003', NULL, NULL, 'Bom', jsonb_build_array('Banca', 'ITD'))
) as v(colaborador, cargo, inicio, contrato, vcto_contrato, manual_conduta, valores, aniversario, ultimo_feedback, ultima_bonif, farol, clientes)
where not exists (select 1 from public.i3_equipe e where e.colaborador = v.colaborador);

insert into public.i3_reunioes (data_reuniao, titulo, obs_rh, conclusoes, pontos_atencao, pontos_positivos, financeiro, pontos_para_ver)
select '2025-01-01'::date, '📥 Operacoes e RH — 01/2025 · Haisa, Heidy e Vini', '- Impressão do ponto das gurias para assinar (Heidy) - assinatura pelo GOV BR;
- Entregar os crachás para o próximo evento;
- Renovar o contrato da Julia
- Feriado de carnaval: 03/02 a 5/02 voltando 12h

📍 Encontro: 14/03 · Impulse Verão
🎓 Impulse Learning:
29/01 Marketing aplicado ao preço, ponto de venda,
05/02 Marketing aplicado a produto e promoção
12/02 Gatilhos mentais para prospeccção de clientes
26/02 Pendente', '- O time fazer os cursos de dentro da plataforma RD Station
- Criar manual de conduta; (Heidy fazer o time assinar)
- Criar videos de onnboard boas vindas aos clientes;
- Roteiro de onboard (boas vindas, uso de imagem, manual de conduta, premiações e desligamentos);', NULL, NULL, 'COBRAR UM POST A MAIS DA TOPO', NULL
where not exists (select 1 from public.i3_reunioes r where r.titulo = '📥 Operacoes e RH — 01/2025 · Haisa, Heidy e Vini');

insert into public.i3_reunioes (data_reuniao, titulo, obs_rh, conclusoes, pontos_atencao, pontos_positivos, financeiro, pontos_para_ver)
select '2025-02-01'::date, '📥 Operacoes e RH — 02/2025 · Haisa, Heidy e Vini', '- Renovar o contrato da Julia
- Impressão do ponto das gurias para assinar (Heidy) - assinatura pelo GOV BR;
- Fazer crachá para o Haniel + Crachá genérico;
- Feriado de carnaval: 03/02 a 5/02 voltando 12h
- Comprar os itens que estão na planilha do planejamento estratégico;

📍 Encontro: 14/03 · Tarde de pinturas
🎓 Impulse Learning:
05/03 [Vini] - Conhecendo o time, atividades variadas
12/03 [Henrique] - Design
19/03 [Éllen] - Atendimento ao cliente
26/03 [Haniel] - Copy', '- O time fazer os cursos de dentro da plataforma RD Station
- Criar videos de onnboard boas vindas aos clientes;
- Roteiro de onboard (boas vindas, uso de imagem, manual de conduta, premiações e desligamentos);', 'Rever os clientes da Clara | E analisar as entregas da Duda; 27/02 | Contratação de outra pessoal no tráfego pago;', 'Entrada da Sabrina com qualidade de vídeos | Henrique andou sozinho na Eucassel | Entrada do Haniel e Enrique', '[RD] - COBRAR UM POST A MAIS DA TOP ESPORTES PARA A COBRANÇA 28/02 - R$90
ok', NULL
where not exists (select 1 from public.i3_reunioes r where r.titulo = '📥 Operacoes e RH — 02/2025 · Haisa, Heidy e Vini');

insert into public.i3_reunioes (data_reuniao, titulo, obs_rh, conclusoes, pontos_atencao, pontos_positivos, financeiro, pontos_para_ver)
select '2025-03-01'::date, '📥 Operacoes e RH — 03/2025 · Haisa, Heidy e Vini', '- Renovar o contrato da Julia
- Impressão do ponto das gurias para assinar (Heidy) - assinatura pelo GOV BR;
- Fazer crachá para o Haniel + Crachá genérico;
- Feriado da páscoa (sexta á segunda, voltando a trabalhar na terça)
- Comprar os itens que estão na planilha do planejamento estratégico;

📍 Encontro: 09/05/2025 · No Click Síndico
🎓 Impulse Learning:
02/04 [Éllen] - Atendimento ao cliente
09/04 [Haniel] - Copy', NULL, 'Entrada da Sabrina com qualidade de vídeos | Henrique andou sozinho na Eucassel | Entrada do Haniel e Enrique
- O time fazer os cursos de dentro da plataforma RD Station
- Criar videos de onnboard boas vindas aos clientes;
- Roteiro de onboard (boas vindas, uso de imagem, manual de conduta, premiações e desligamentos);', NULL, 'Tassy
Fee fixo
Natacenter
Fee fixo
Concept
Fee fixo
MIG
Fee fixo', NULL
where not exists (select 1 from public.i3_reunioes r where r.titulo = '📥 Operacoes e RH — 03/2025 · Haisa, Heidy e Vini');

insert into public.i3_reunioes (data_reuniao, titulo, obs_rh, conclusoes, pontos_atencao, pontos_positivos, financeiro, pontos_para_ver)
select '2025-04-01'::date, '📥 Operacoes e RH — 04/2025 · Haisa, Heidy e Vini', '- Renovar o contrato da Julia
- Impressão do ponto das gurias para assinar (Heidy) - assinatura pelo GOV BR;
- Fazer crachá para o Haniel + Crachá genérico;
- Comprar o rebatedor

📍 Encontro: 09/05/2025 · No Click Síndico
🎓 Impulse Learning:
07/04 [Éllen] - Atendimento ao cliente
14/04 [Haniel] - Copy', NULL, '- Matheus alerta pois ele esta reclamando dos prazos;
- Sabrina vai assumar a MIG
- Isa começará a fazer as gravações;
- Enrique saiu da Impulse e fizemos a reunião de desligamento;
- Colaborador destaque (Prêmios, Troféus, Broche);
- O time fazer os cursos de dentro da plataforma RD Station
- Criar videos de onnboard boas vindas aos clientes;
- Roteiro de onboard (boas vindas, uso de imagem, manual de conduta, premiações e desligamentos);', NULL, NULL, NULL
where not exists (select 1 from public.i3_reunioes r where r.titulo = '📥 Operacoes e RH — 04/2025 · Haisa, Heidy e Vini');

insert into public.i3_reunioes (data_reuniao, titulo, obs_rh, conclusoes, pontos_atencao, pontos_positivos, financeiro, pontos_para_ver)
select '2025-05-01'::date, '📥 Operacoes e RH — 05/2025 · Haisa, Heidy e Vini', '- Impressão do ponto das gurias para assinar (Heidy) | Isa e Bento
- Assinar contrato Isa
- Manual de conduta Wini

📍 Encontro: 23/07/2025 · Festa Junina · 18/06/2025 Jantar da liderança — Vini, Ellen, Julia, Haisa, Heidy, Haniel
🎓 Impulse Learning:
11/06 [Éllen] - Atendimento ao cliente
18/06 [Haniel] - Copy
25/06 [Julia] - Desgner para o tráfego', NULL, '- Mateus vamos romper com ele e o Bento vai absorver as demandas da Tassy e da Banca;
- Passar a estrategia e criação de design do trafego pago para o designer resposavel pelo Redes social;
- Recrutamento do novo estagiário de desgner e comercial;
- Enrique saiu da Impulse e fizemos a reunião de desligamento;
- Fizemos a festa de 2 anos da Impulse;
- Entrada da Mary na produção do lançamento;
- Guia da Alma | atualização;
- Material da Cultura e missão, visão e valores;
- Colaborador destaque (Prêmios, Troféus, Broche);
- O time fazer os cursos de dentro da plataforma RD Station
- Criar videos de onnboard boas vindas aos clientes;
- Roteiro de onboard (boas vindas, uso de imagem, manual de conduta, premiações e desligamentos);', NULL, NULL, NULL
where not exists (select 1 from public.i3_reunioes r where r.titulo = '📥 Operacoes e RH — 05/2025 · Haisa, Heidy e Vini');

insert into public.i3_reunioes (data_reuniao, titulo, obs_rh, conclusoes, pontos_atencao, pontos_positivos, financeiro, pontos_para_ver)
select '2025-06-01'::date, '📥 Operacoes e RH — 06/2025 · Haisa e Heidy', '- Impressão do ponto das gurias para assinar (Heidy) | Isa e Bento

📍 Encontro: 23/07/2025 · Festa Junina · 05/08/2025 Jantar da liderança — Vini, Ellen, Julia, Haisa, Heidy, Haniel
🎓 Impulse Learning:
09/07 [Éllen] - Atendimento ao cliente
16/07 [Haniel] - Copy
23/07 [Julia] - Desgner para o tráfego', NULL, '- Mateus vamos romper com ele e o Bento vai absorver as demandas da Tassy e da Banca; [Ok, passamos para o bento e julia]
- Passar a estrategia e criação de design do trafego pago para o designer resposavel pelo Redes social; [Em processo]
- Recrutamento do novo estagiário de desgner e comercial; [Em processo]
- Colaborador destaque (Prêmios, Troféus, Broche); [Mandar fazer o boneco de crochê]
- O time fazer os cursos de dentro da plataforma RD Station
- Criar videos de onnboard boas vindas aos clientes;
- Roteiro de onboard (boas vindas, uso de imagem, manual de conduta, premiações e desligamentos);', NULL, NULL, NULL
where not exists (select 1 from public.i3_reunioes r where r.titulo = '📥 Operacoes e RH — 06/2025 · Haisa e Heidy');

insert into public.i3_reunioes (data_reuniao, titulo, obs_rh, conclusoes, pontos_atencao, pontos_positivos, financeiro, pontos_para_ver)
select '2025-07-01'::date, '📥 Operacoes e RH — 07/2025', NULL, NULL, '- Mateus vamos romper com ele e o Bento vai absorver as demandas da Tassy e da Banca; [Ok, passamos para o bento e julia]
- Passar a estrategia e criação de design do trafego pago para o designer resposavel pelo Redes social; [Em processo]
- Recrutamento do novo estagiário de desgner e comercial; [Em processo]
- Colaborador destaque (Prêmios, Troféus, Broche); [Mandar fazer o boneco de crochê]
- O time fazer os cursos de dentro da plataforma RD Station
- Criar videos de onnboard boas vindas aos clientes;
- Roteiro de onboard (boas vindas, uso de imagem, manual de conduta, premiações e desligamentos);', NULL, NULL, NULL
where not exists (select 1 from public.i3_reunioes r where r.titulo = '📥 Operacoes e RH — 07/2025');

insert into public.i3_reunioes (data_reuniao, titulo, obs_rh, conclusoes, pontos_atencao, pontos_positivos, financeiro, pontos_para_ver)
select '2025-08-01'::date, '📥 Operacoes e RH — 08/2025', 'Crachá novos
Novo colaborador

🎓 Impulse Learning:
Organizar datas e temas', NULL, NULL, NULL, NULL, NULL
where not exists (select 1 from public.i3_reunioes r where r.titulo = '📥 Operacoes e RH — 08/2025');

insert into public.i3_reunioes (data_reuniao, titulo, obs_rh, conclusoes, pontos_atencao, pontos_positivos, financeiro, pontos_para_ver)
select '2025-09-01'::date, '📥 Operacoes e RH — 09/2025', 'Crachá novos
Novo colaborador

📍 Encontro: 10/10/25 · Redenção', NULL, NULL, NULL, NULL, NULL
where not exists (select 1 from public.i3_reunioes r where r.titulo = '📥 Operacoes e RH — 09/2025');

insert into public.i3_reunioes (data_reuniao, titulo, obs_rh, conclusoes, pontos_atencao, pontos_positivos, financeiro, pontos_para_ver)
select '2025-10-01'::date, '📥 Operacoes e RH — 10/2025', '📍 Encontro: 13/12/25', NULL, NULL, NULL, NULL, NULL
where not exists (select 1 from public.i3_reunioes r where r.titulo = '📥 Operacoes e RH — 10/2025');

insert into public.i3_reunioes (data_reuniao, titulo, obs_rh, conclusoes, pontos_atencao, pontos_positivos, financeiro, pontos_para_ver)
select '2025-11-01'::date, '📥 Operacoes e RH — 11/2025', '📍 Encontro: 12/12/25', NULL, 'SERVIÇO
COLABORADOR
LIDER Plano Fee Fixo
R$ 300.00
R$ 300.00 Plano Impulse +
R$ 300.00
R$ 220.00 Plano Lançamento
R$ 300.00
R$ 220.00 Plano Pulse
R$ 300.00
R$ 150.00 Plano Trafego pago
R$ 300.00
R$ 100.00 Google
R$ 890.00
R$ 120.00 Trafego pago
R$ 350.00
R$ 100.00 Criação de logomarca / id visual
R$ 250.00
R$ 200.00 Portofólio/E-book (até 10 páginas)
R$ 200.00
R$ 90.00 Materiais extras
R$ 25.00
R$ 25.00 Fotografia retrato 1 pessoa
R$ 0.00
R$ 150.00 Retrato Pessoal / corporativo
R$ 0.00
R$ 150.00 Captação vídeo e fotos 4hs s/edição
R$ 150.00
R$ 0.00 Consultoria de marketing
R$ 0.00
R$ 490.00 Designer Estático (combo 10)
R$ 200.00
R$ 150.00 Designer Estático (combo 5)
R$ 100.00
R$ 80.00 Designer extra
R$ 25.00
R$ 25.00 Carrosséis
R$ 25.00
R$ 25.00 Banner
R$ 25.00
R$ 25.00 Designer p/embalagem
R$ 25.00
R$ 25.00 Cartão de Visita
R$ 25.00
R$ 25.00 Aplicação
R$ 25.00
R$ 25.00 Assinatura de e-mail
R$ 25.00
R$ 25.00 Edições de videos até 3 minutos
R$ 25.00
R$ 25.00 Edições de videos até + 3 minutos
R$ 25.00
R$ 25.00 Papelaria / Pasta / folha timbrada
R$ 25.00
R$ 25.00 Crachá 1
R$ 25.00
R$ 25.00 Placa/cartaz
R$ 25.00
R$ 25.00 Site - Tiago
R$ 0.00', NULL, NULL, NULL
where not exists (select 1 from public.i3_reunioes r where r.titulo = '📥 Operacoes e RH — 11/2025');

insert into public.i3_reunioes (data_reuniao, titulo, obs_rh, conclusoes, pontos_atencao, pontos_positivos, financeiro, pontos_para_ver)
select '2026-01-01'::date, '📥 Operacoes e RH — 01/2026', '🎓 Impulse Learning:
04/02', 'Contratação de gestor de tráfego
Ligar o tráfego para Impulse
Fechar mentoria comercial', NULL, NULL, NULL, 'Presente de final de ano
Pensar no encontro de março
Bottom para a Ellen (01/02)
Seguro contra cliente
Banco do Brasil fechar
Asas - forma de pgto
Melhorar a descrição do fee fixo
Falar com o Denner e fechar parceria
Não vamos para gramado summth'
where not exists (select 1 from public.i3_reunioes r where r.titulo = '📥 Operacoes e RH — 01/2026');

insert into public.i3_reunioes (data_reuniao, titulo, obs_rh, conclusoes, pontos_atencao, pontos_positivos, financeiro, pontos_para_ver)
select '2026-02-01'::date, '📥 Operacoes e RH — 02/2026', '📍 Encontro: 6/3/26
🎓 Impulse Learning:
12/03 - Atendimento', 'Contratação de gestor de tráfego
Ligar o tráfego para Impulse
Fechar mentoria comercial', NULL, NULL, NULL, 'Presente de final de ano
Pensar no encontro de março
Bottom para a Ellen (01/02)
Seguro contra cliente
Banco do Brasil fechar
Asas - forma de pgto
Melhorar a descrição do fee fixo
Falar com o Denner e fechar parceria
Não vamos para gramado summth'
where not exists (select 1 from public.i3_reunioes r where r.titulo = '📥 Operacoes e RH — 02/2026');

insert into public.i3_reunioes (data_reuniao, titulo, obs_rh, conclusoes, pontos_atencao, pontos_positivos, financeiro, pontos_para_ver)
select '2026-03-01'::date, '📥 Operacoes e RH — 03/2026', '📍 Encontro: MAIO', NULL, 'RENTALSUL - INDICAÇÃO TENAX 20%', NULL, NULL, NULL
where not exists (select 1 from public.i3_reunioes r where r.titulo = '📥 Operacoes e RH — 03/2026');

insert into public.i3_reunioes (data_reuniao, titulo, obs_rh, conclusoes, pontos_atencao, pontos_positivos, financeiro, pontos_para_ver)
select '2026-04-01'::date, '📥 Operacoes e RH — 04/2026', '📍 Encontro: 22/05', NULL, 'RENTALSUL - INDICAÇÃO TENAX 20%', NULL, NULL, NULL
where not exists (select 1 from public.i3_reunioes r where r.titulo = '📥 Operacoes e RH — 04/2026');

insert into public.i3_reunioes (data_reuniao, titulo, obs_rh, conclusoes, pontos_atencao, pontos_positivos, financeiro, pontos_para_ver)
select '2026-05-01'::date, '📥 Operacoes e RH — 05/2026', '📍 Encontro: MAIO', NULL, 'RENTALSUL - INDICAÇÃO TENAX 20%', NULL, NULL, NULL
where not exists (select 1 from public.i3_reunioes r where r.titulo = '📥 Operacoes e RH — 05/2026');

select 'I3 seed OK: '||(select count(*) from public.i3_equipe)||' no painel, 16 atas importadas' as resultado;
