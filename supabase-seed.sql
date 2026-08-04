-- ============================================================
-- IMPULSE ONE — Seed inicial
-- ============================================================
-- Execute APÓS o supabase-schema.sql e APÓS criar os 9 usuários
-- via Authentication → Users → Add user (email/senha)
-- ============================================================
-- IMPORTANTE: você precisa criar os usuários no Auth ANTES
-- e depois substituir os UUIDs abaixo pelos IDs reais retornados.
-- Para pegar o UUID de cada usuário: SELECT id, email FROM auth.users;
-- ============================================================

-- ============================================================
-- 1) Profiles dos 9 colaboradores
-- ============================================================
-- IMPORTANTE: substitua os 'AUTH_USER_UUID_X' pelos UUIDs reais
-- gerados no Supabase Auth para cada email.
-- Você pode rodar este script com placeholders e depois fazer:
--   UPDATE profiles SET id = 'real-uuid' WHERE full_name = 'Éllen Costa';

-- Por enquanto, criando profiles SEM vincular ao auth.users
-- (você pode vincular depois ou criar usuários via dashboard).

-- Limpe primeiro se já tiver dados de teste
-- truncate profiles cascade;

insert into profiles (id, full_name, role, position, avatar_color, initials, phone, cpf, salary, contract_start, vacation_used, productivity)
values
  (uuid_generate_v4(), 'Éllen Costa', 'gestor', 'Gerente de Contas', '#0ea5e9', 'E', '(11) 99876-5432', '123.456.789-01', 6500, '2023-03-15', 0, 92),
  (uuid_generate_v4(), 'Gabi Mendes', 'colaborador', 'Estrategista', '#ec4899', 'G', '(11) 99765-4321', '234.567.890-12', 5800, '2023-08-20', 15, 90),
  (uuid_generate_v4(), 'Julia Ferreira', 'colaborador', 'Social Media Senior', '#7c3aed', 'J', '(11) 99654-3210', '345.678.901-23', 5200, '2024-01-10', 0, 95),
  (uuid_generate_v4(), 'Letícia Souza', 'colaborador', 'Tráfego Pago', '#f59e0b', 'L', '(11) 99543-2109', '456.789.012-34', 5500, '2024-04-22', 10, 88),
  (uuid_generate_v4(), 'Henrique Lima', 'colaborador', 'Designer Senior', '#10b981', 'H', '(11) 99432-1098', '567.890.123-45', 5400, '2023-06-05', 30, 86),
  (uuid_generate_v4(), 'Haisa Rocha', 'colaborador', 'Videomaker', '#ef4444', 'H', '(11) 99321-0987', '678.901.234-56', 4900, '2024-09-12', 0, 84),
  (uuid_generate_v4(), 'Heidy Alves', 'gestor', 'Coordenadora Criativa', '#06b6d4', 'H', '(11) 99210-9876', '789.012.345-67', 6200, '2023-11-01', 0, 91),
  (uuid_generate_v4(), 'Vinicius Pereira', 'colaborador', 'Editor de Vídeo', '#a855f7', 'V', '(11) 99109-8765', '890.123.456-78', 4700, '2024-02-15', 5, 87),
  (uuid_generate_v4(), 'Fran Oliveira', 'colaborador', 'Social Media', '#f97316', 'F', '(11) 99098-7654', '901.234.567-89', 4500, '2024-07-08', 0, 89);

-- ============================================================
-- 2) Clientes — 21 da Impulse One
-- ============================================================
-- Owner_id: pegamos o profile da Éllen como exemplo, depois você ajusta
do $$
declare ellen_id uuid; gabi_id uuid; julia_id uuid; leticia_id uuid;
  henrique_id uuid; haisa_id uuid; heidy_id uuid; vinicius_id uuid; fran_id uuid;
begin
  select id into ellen_id from profiles where full_name = 'Éllen Costa' limit 1;
  select id into gabi_id from profiles where full_name = 'Gabi Mendes' limit 1;
  select id into julia_id from profiles where full_name = 'Julia Ferreira' limit 1;
  select id into leticia_id from profiles where full_name = 'Letícia Souza' limit 1;
  select id into henrique_id from profiles where full_name = 'Henrique Lima' limit 1;
  select id into haisa_id from profiles where full_name = 'Haisa Rocha' limit 1;
  select id into heidy_id from profiles where full_name = 'Heidy Alves' limit 1;
  select id into vinicius_id from profiles where full_name = 'Vinicius Pereira' limit 1;
  select id into fran_id from profiles where full_name = 'Fran Oliveira' limit 1;

  insert into clients (name, segment, color, initials, mrr, status, owner_id, phone, email, instagram, website, plan_name, plan_value, designer_id, traffic_manager_id, services)
  values
    ('Alegria Kids','Educação infantil','#14b8a6','AK',2600,'active',henrique_id,'(11) 99000-0001','contato@alegriakids.com.br','@alegriakids','alegriakids.com.br','Crescimento',3200,henrique_id,leticia_id,array['gestao_social','design','trafego']),
    ('Aquassafe','Tecnologia hídrica','#0ea5e9','AQ',3800,'active',ellen_id,'(11) 99000-0002','contato@aquassafe.com.br','@aquassafe','aquassafe.com.br','Premium',5500,heidy_id,leticia_id,array['gestao_social','design','trafego','videos','captacao']),
    ('Banca de Síndicos','Condomínios','#84cc16','BS',1800,'active',gabi_id,'(11) 99000-0003','contato@bancadesindicos.com.br','@bancadesindicos','bancadesindicos.com.br','Essencial',1800,henrique_id,leticia_id,array['gestao_social','design']),
    ('Concept','Construção','#ef4444','CO',6700,'onboarding',haisa_id,'(11) 99000-0004','contato@concept.com.br','@concept','concept.com.br','Enterprise',8900,heidy_id,leticia_id,array['gestao_social','design','trafego','videos','captacao','branding','campanhas','consultoria']),
    ('Dener','Indústria','#8b5cf6','DE',3300,'onboarding',julia_id,'(11) 99000-0005','contato@dener.com.br','@dener','dener.com.br','Crescimento',3200,henrique_id,leticia_id,array['gestao_social','design','trafego']),
    ('Eucassel','Indústria','#ea580c','EU',4900,'active',julia_id,'(11) 99000-0006','contato@eucassel.com.br','@eucassel','eucassel.com.br','Premium',5500,heidy_id,leticia_id,array['gestao_social','design','trafego','videos','captacao']),
    ('Franci','Beleza','#eab308','FR',2200,'paused',ellen_id,'(11) 99000-0007','contato@franci.com.br','@franci','franci.com.br','Essencial',1800,henrique_id,null,array['gestao_social','design']),
    ('iGet','Tecnologia','#06b6d4','IG',5800,'active',gabi_id,'(11) 99000-0008','contato@iget.com.br','@iget','iget.com.br','Enterprise',8900,heidy_id,leticia_id,array['gestao_social','design','trafego','videos','captacao','branding','campanhas','consultoria']),
    ('ITD','Tecnologia','#7c3aed','IT',4200,'active',gabi_id,'(11) 99000-0009','contato@itd.com.br','@itd','itd.com.br','Crescimento',3200,henrique_id,leticia_id,array['gestao_social','design','trafego']),
    ('Marmitina','Alimentação','#f43f5e','MA',2400,'active',ellen_id,'(11) 99000-0010','contato@marmitina.com.br','@marmitina','marmitina.com.br','Premium',5500,heidy_id,leticia_id,array['gestao_social','design','trafego','videos','captacao']),
    ('Natacenter','Esporte aquático','#8b5cf6','NA',2800,'active',leticia_id,'(11) 99000-0011','contato@natacenter.com.br','@natacenter','natacenter.com.br','Crescimento',3200,henrique_id,leticia_id,array['gestao_social','design','trafego']),
    ('Precisa Serviços','Serviços B2B','#a855f7','PS',3500,'active',vinicius_id,'(11) 99000-0012','contato@precisaservicos.com.br','@precisaservicos','precisaservicos.com.br','Crescimento',3200,henrique_id,leticia_id,array['gestao_social','design','trafego']),
    ('Pro4saúde','Saúde ocupacional','#0891b2','P4',4400,'active',vinicius_id,'(11) 99000-0013','contato@pro4saude.com.br','@pro4saude','pro4saude.com.br','Premium',5500,heidy_id,leticia_id,array['gestao_social','design','trafego','videos','captacao']),
    ('Qualific','Auditoria','#84cc16','QU',4100,'active',fran_id,'(11) 99000-0014','contato@qualific.com.br','@qualific','qualific.com.br','Crescimento',3200,henrique_id,leticia_id,array['gestao_social','design','trafego']),
    ('Rentalsul','Locação','#22c55e','RE',5200,'active',heidy_id,'(11) 99000-0015','contato@rentalsul.com.br','@rentalsul','rentalsul.com.br','Premium',5500,heidy_id,leticia_id,array['gestao_social','design','trafego','videos','captacao']),
    ('Santuse','Saúde','#06b6d4','SA',2900,'active',heidy_id,'(11) 99000-0016','contato@santuse.com.br','@santuse','santuse.com.br','Essencial',1800,henrique_id,null,array['gestao_social','design']),
    ('Sócias','Cosméticos','#f43f5e','SO',3100,'active',haisa_id,'(11) 99000-0017','contato@socias.com.br','@socias','socias.com.br','Crescimento',3200,henrique_id,leticia_id,array['gestao_social','design','trafego']),
    ('Steel Desk','Mobiliário corporativo','#ec4899','SD',5500,'late',julia_id,'(11) 99000-0018','contato@steeldesk.com.br','@steeldesk','steeldesk.com.br','Premium',5500,heidy_id,leticia_id,array['gestao_social','design','trafego','videos','captacao']),
    ('Termodron','Engenharia','#f59e0b','TE',4800,'active',henrique_id,'(11) 99000-0019','contato@termodron.com.br','@termodron','termodron.com.br','Crescimento',3200,henrique_id,leticia_id,array['gestao_social','design','trafego']),
    ('Top Sports','Esporte','#06b6d4','TS',3700,'active',fran_id,'(11) 99000-0020','contato@topsports.com.br','@topsports','topsports.com.br','Premium',5500,heidy_id,leticia_id,array['gestao_social','design','trafego','videos','captacao']),
    ('Weco','Indústria','#3b82f6','WE',3200,'active',leticia_id,'(11) 99000-0021','contato@weco.com.br','@weco','weco.com.br','Crescimento',3200,henrique_id,leticia_id,array['gestao_social','design','trafego']);
end $$;

-- ============================================================
-- 3) Cronograma — gerar 12 meses para cada cliente
-- ============================================================
do $$
declare cli record; m int; pl text; pl_value numeric;
begin
  for cli in select id, plan_name, plan_value, designer_id, traffic_manager_id from clients loop
    for m in 1..12 loop
      insert into cronograma (client_id, year, month, produced, target, has_traffic, designer_id, traffic_manager_id, status, deadline)
      values (
        cli.id, 2026, m,
        case when m < 5 then 8 + (m * 2) when m = 5 then 5 + (random()*5)::int else 0 end,
        case when cli.plan_name = 'Essencial' then 8 when cli.plan_name = 'Crescimento' then 12 when cli.plan_name = 'Premium' then 16 else 20 end,
        cli.plan_name in ('Crescimento','Premium','Enterprise'),
        cli.designer_id,
        cli.traffic_manager_id,
        case when m < 5 then 'concluido' when m = 5 then (array['em-dia','em-andamento','em-andamento','atrasado'])[1 + (random()*3)::int] else 'planejado' end,
        ('2026-' || lpad(m::text,2,'0') || '-' || lpad((15 + (random()*14)::int)::text,2,'0'))::date
      );
    end loop;
  end loop;
end $$;

-- ============================================================
-- 4) Captações
-- ============================================================
do $$
declare aq uuid; ma uuid; ts uuid; bs uuid; ak uuid; haisa uuid; vinicius uuid;
begin
  select id into aq from clients where name = 'Aquassafe' limit 1;
  select id into ma from clients where name = 'Marmitina' limit 1;
  select id into ts from clients where name = 'Top Sports' limit 1;
  select id into bs from clients where name = 'Banca de Síndicos' limit 1;
  select id into ak from clients where name = 'Alegria Kids' limit 1;
  select id into haisa from profiles where full_name = 'Haisa Rocha' limit 1;
  select id into vinicius from profiles where full_name = 'Vinicius Pereira' limit 1;

  insert into captacoes (client_id, type, responsible_id, scheduled_date, scheduled_time, address, briefing, status, priority, materials)
  values
    (aq, 'Vídeo institucional', haisa, '2026-05-20', '10:00', 'Av. Paulista, 1234 — São Paulo/SP', 'Captação de vídeo institucional + entrevista com diretor', 'confirmada', 'high', array['Câmera principal','Microfone lapela','Gimbal','Tripé','Iluminação portátil']),
    (ma, 'Fotos de produtos', vinicius, '2026-05-22', '14:00', 'Cozinha industrial — Vila Olímpia', 'Sessão fotográfica de 20 pratos para cardápio digital', 'agendada', 'med', array['Câmera + 50mm','Fundo branco','Iluminação softbox']),
    (ts, 'Reels promocional', haisa, '2026-05-25', '09:00', 'Quadra Pro Center — Jardins', '5 Reels para campanha de inverno', 'agendada', 'urgent', array['Câmera + estabilizador','Microfone direcional','Gimbal','Cartões SD']),
    (bs, 'Vídeo depoimento', vinicius, '2026-05-18', '15:30', 'Sede — Centro/SP', 'Depoimento do diretor + B-roll', 'em_andamento', 'high', array['Setup completo','Teleprompter','Iluminação 3 pontos']),
    (ak, 'Bastidor escola', vinicius, '2026-05-12', '10:00', 'Unidade Pinheiros', 'Captação de bastidores das aulas', 'finalizada', 'low', array['Câmera portátil']);
end $$;

-- ============================================================
-- 5) Automações ativas
-- ============================================================
insert into automations (name, description, trigger, action, enabled)
values
  ('Onboarding automático', 'Cliente fechou → Cria pastas, envia contrato, agenda kickoff', 'Cliente fechado', 'Workspace + email', true),
  ('Cobrança 3 dias antes', 'Lembrete WhatsApp antes do vencimento', 'D-3 vencimento', 'WhatsApp', true),
  ('Aniversário do cliente', 'Mensagem personalizada', 'Aniversário', 'WhatsApp', true),
  ('Conteúdo aprovado → Agendar', 'Quando cliente aprova, agenda no MLABS', 'Aprovação', 'Agendar MLABS', true),
  ('Aviso de atraso', 'Notifica responsável e gerente', 'Tarefa atrasada', 'Email + Slack', true),
  ('Relatório mensal', 'Gera e envia no dia 1', 'Dia 1 do mês', 'PDF + envio', true),
  ('Follow-up proposta', 'D+3 após envio', 'Proposta enviada', 'WhatsApp', false),
  ('Checklist diário', 'Gera tarefas diárias por colaborador', '06:00 todo dia', 'Criar checklist', true);

-- ============================================================
-- 6) Datas comemorativas (BR + RS)
-- ============================================================
insert into commemorative_dates (date, name, region, category) values
  ('2026-01-01', 'Confraternização Universal', 'BR', 'nacional'),
  ('2026-04-21', 'Tiradentes', 'BR', 'nacional'),
  ('2026-05-01', 'Dia do Trabalho', 'BR', 'nacional'),
  ('2026-05-10', 'Dia das Mães', 'BR', 'comercial'),
  ('2026-06-12', 'Dia dos Namorados', 'BR', 'comercial'),
  ('2026-07-20', 'Dia do Amigo', 'BR', 'comercial'),
  ('2026-09-07', 'Independência do Brasil', 'BR', 'nacional'),
  ('2026-10-12', 'Dia das Crianças', 'BR', 'comercial'),
  ('2026-11-15', 'Proclamação da República', 'BR', 'nacional'),
  ('2026-12-25', 'Natal', 'BR', 'nacional'),
  -- RS
  ('2026-04-12', 'Dia da Tradição Gaúcha', 'RS', 'regional'),
  ('2026-04-25', 'Dia do Pelotense', 'RS', 'regional'),
  ('2026-07-25', 'Dia do Colono', 'RS', 'regional'),
  ('2026-09-14', 'Início Semana Farroupilha', 'RS', 'regional'),
  ('2026-09-20', 'Revolução Farroupilha (feriado RS)', 'RS', 'regional'),
  ('2026-09-30', 'São Jerônimo (padroeiro RS)', 'RS', 'regional'),
  ('2026-11-11', 'Dia do Gaúcho', 'RS', 'regional');

-- ============================================================
-- DONE! Dados iniciais populados.
-- Verifique no Table Editor do Supabase se tudo aparece.
-- ============================================================
