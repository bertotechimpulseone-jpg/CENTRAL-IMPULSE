insert into captacoes (client_id, type, scheduled_date, scheduled_time, address, briefing, status, priority, materials) values
  ((select id from clients where name='Aquassafe'), 'Video institucional', '2026-05-20', '10:00', 'Av. Paulista 1234 Sao Paulo SP', 'Captacao de video institucional', 'confirmada', 'high', array['Camera','Microfone','Gimbal','Tripe']),
  ((select id from clients where name='Marmitina'), 'Fotos de produtos', '2026-05-22', '14:00', 'Cozinha industrial Vila Olimpia', 'Sessao fotografica de 20 pratos', 'agendada', 'med', array['Camera','Fundo branco','Softbox']),
  ((select id from clients where name='Top Sports'), 'Reels promocional', '2026-05-25', '09:00', 'Quadra Pro Center Jardins', '5 Reels para campanha de inverno', 'agendada', 'urgent', array['Camera','Microfone','Gimbal']),
  ((select id from clients where name='Banca de Sindicos'), 'Video depoimento', '2026-05-18', '15:30', 'Sede Centro SP', 'Depoimento do diretor', 'em_andamento', 'high', array['Setup completo','Teleprompter']),
  ((select id from clients where name='Alegria Kids'), 'Bastidor escola', '2026-05-12', '10:00', 'Unidade Pinheiros', 'Captacao de bastidores', 'finalizada', 'low', array['Camera portatil']);

insert into automations (name, description, trigger, action, enabled) values
  ('Onboarding automatico', 'Cliente fechou cria pastas e envia contrato', 'Cliente fechado', 'Workspace email', true),
  ('Cobranca 3 dias antes', 'Lembrete WhatsApp antes do vencimento', 'D-3 vencimento', 'WhatsApp', true),
  ('Aniversario do cliente', 'Mensagem personalizada', 'Aniversario', 'WhatsApp', true),
  ('Conteudo aprovado', 'Cliente aprova e agenda no MLABS', 'Aprovacao', 'Agendar MLABS', true),
  ('Aviso de atraso', 'Notifica responsavel e gerente', 'Tarefa atrasada', 'Email Slack', true),
  ('Relatorio mensal', 'Gera e envia no dia 1', 'Dia 1 do mes', 'PDF envio', true),
  ('Follow-up proposta', 'D+3 apos envio', 'Proposta enviada', 'WhatsApp', false),
  ('Checklist diario', 'Gera tarefas diarias por colaborador', '06:00 todo dia', 'Criar checklist', true);

insert into commemorative_dates (date, name, region, category) values
  ('2026-01-01', 'Confraternizacao Universal', 'BR', 'nacional'),
  ('2026-04-21', 'Tiradentes', 'BR', 'nacional'),
  ('2026-05-01', 'Dia do Trabalho', 'BR', 'nacional'),
  ('2026-05-10', 'Dia das Maes', 'BR', 'comercial'),
  ('2026-06-12', 'Dia dos Namorados', 'BR', 'comercial'),
  ('2026-07-20', 'Dia do Amigo', 'BR', 'comercial'),
  ('2026-09-07', 'Independencia do Brasil', 'BR', 'nacional'),
  ('2026-10-12', 'Dia das Criancas', 'BR', 'comercial'),
  ('2026-11-15', 'Proclamacao da Republica', 'BR', 'nacional'),
  ('2026-12-25', 'Natal', 'BR', 'nacional'),
  ('2026-04-12', 'Dia da Tradicao Gaucha', 'RS', 'regional'),
  ('2026-07-25', 'Dia do Colono', 'RS', 'regional'),
  ('2026-09-14', 'Inicio Semana Farroupilha', 'RS', 'regional'),
  ('2026-09-20', 'Revolucao Farroupilha feriado RS', 'RS', 'regional'),
  ('2026-11-11', 'Dia do Gaucho', 'RS', 'regional');
