-- ============================================================
-- CRONOGRAMA JUNHO 2026 — dados reais da planilha
-- ============================================================
-- Popula a tabela cronograma com os dados do mês de junho/2026.
-- Faz UPSERT (insere se não existe, atualiza se já existe).
-- O índice único (client_id, year, month) garante uma linha só por mês/cliente.
--
-- Status usados:
-- 'agendado-mlabs' / 'agendado-meta' / 'aguardando-aprov' /
-- 'trello-vini' / 'mlabs-vini' / 'desenvolvimento' / 'cal-pronto' /
-- 'apenas-trafego' / 'planejado' / 'cancelado'
-- ============================================================

-- ===== AGENDADOS (verde forte) =====

-- Aquassafe: 10 conteúdos, Letícia, Agendado MLABS, Instagram, $178 tráfego
insert into cronograma (client_id, year, month, produced, target, designer, status, observations)
select id, 2026, 6, 0, 10, 'Letícia', 'agendado-mlabs', '$178 no tráfego · Instagram'
  from clients where name = 'Aquassafe'
on conflict (client_id, year, month) do update set
  target = excluded.target, designer = excluded.designer,
  status = excluded.status, observations = excluded.observations;

-- ITD: 8 conteúdos, Éllen, Agendado Meta
insert into cronograma (client_id, year, month, produced, target, designer, status)
select id, 2026, 6, 0, 8, 'Éllen', 'agendado-meta'
  from clients where name = 'ITD'
on conflict (client_id, year, month) do update set
  target = excluded.target, designer = excluded.designer, status = excluded.status;

-- Steel Desk: 8 conteúdos, Éllen + André(TP), Agendado MLABS, reativada
insert into cronograma (client_id, year, month, produced, target, designer, traffic_manager, has_traffic, status, observations)
select id, 2026, 6, 0, 8, 'Éllen', 'André', true, 'agendado-mlabs', 'reativada sexta 15/05 · $300'
  from clients where name = 'Steel Desk'
on conflict (client_id, year, month) do update set
  target = excluded.target, designer = excluded.designer,
  traffic_manager = excluded.traffic_manager, has_traffic = excluded.has_traffic,
  status = excluded.status, observations = excluded.observations;

-- ===== AGUARDANDO APROVAÇÃO (verde claro) =====

-- Weco: 10 conteúdos, Éllen + André(TP), Aguardando aprovação
insert into cronograma (client_id, year, month, produced, target, designer, traffic_manager, has_traffic, status, observations)
select id, 2026, 6, 0, 10, 'Éllen', 'André', true, 'aguardando-aprov', '$300 meta $500 google'
  from clients where name = 'Weco'
on conflict (client_id, year, month) do update set
  target = excluded.target, designer = excluded.designer,
  traffic_manager = excluded.traffic_manager, has_traffic = excluded.has_traffic,
  status = excluded.status, observations = excluded.observations;

-- Natacenter: Julia + André(TP), Aguardando aprovação, Instagram
insert into cronograma (client_id, year, month, produced, target, designer, traffic_manager, has_traffic, status, observations)
select id, 2026, 6, 0, 0, 'Julia', 'André', true, 'aguardando-aprov', 'Instagram'
  from clients where name = 'Natacenter'
on conflict (client_id, year, month) do update set
  designer = excluded.designer,
  traffic_manager = excluded.traffic_manager, has_traffic = excluded.has_traffic,
  status = excluded.status, observations = excluded.observations;

-- Marmitina: 10 conteúdos, Henrique + André(TP), Aguardando aprovação, Instagram
insert into cronograma (client_id, year, month, produced, target, designer, traffic_manager, has_traffic, status, observations)
select id, 2026, 6, 0, 10, 'Henrique', 'André', true, 'aguardando-aprov', 'Instagram'
  from clients where name = 'Marmitina'
on conflict (client_id, year, month) do update set
  target = excluded.target, designer = excluded.designer,
  traffic_manager = excluded.traffic_manager, has_traffic = excluded.has_traffic,
  status = excluded.status, observations = excluded.observations;

-- Pro4saúde: Henrique, Aguardando aprovação
insert into cronograma (client_id, year, month, produced, target, designer, status)
select id, 2026, 6, 0, 0, 'Henrique', 'aguardando-aprov'
  from clients where name = 'Pro4saúde'
on conflict (client_id, year, month) do update set
  designer = excluded.designer, status = excluded.status;

-- ===== TRELLO VINI (roxo) =====

-- Termodron: 10 conteúdos, Éllen, Trello Vini
insert into cronograma (client_id, year, month, produced, target, designer, status)
select id, 2026, 6, 0, 10, 'Éllen', 'trello-vini'
  from clients where name = 'Termodron'
on conflict (client_id, year, month) do update set
  target = excluded.target, designer = excluded.designer, status = excluded.status;

-- Concept: Éllen + André(TP), Trello Vini, investimento $450
insert into cronograma (client_id, year, month, produced, target, designer, traffic_manager, has_traffic, status, observations)
select id, 2026, 6, 0, 0, 'Éllen', 'André', true, 'trello-vini', 'investimento tráfego $450'
  from clients where name = 'Concept'
on conflict (client_id, year, month) do update set
  designer = excluded.designer,
  traffic_manager = excluded.traffic_manager, has_traffic = excluded.has_traffic,
  status = excluded.status, observations = excluded.observations;

-- ===== DESENVOLVIMENTO (amarelo) =====

-- Santuse: 8 conteúdos, Henrique, Desenvolvimento, prazo 19/05
insert into cronograma (client_id, year, month, produced, target, designer, status, deadline)
select id, 2026, 6, 0, 8, 'Henrique', 'desenvolvimento', '2026-05-19'
  from clients where name = 'Santuse'
on conflict (client_id, year, month) do update set
  target = excluded.target, designer = excluded.designer,
  status = excluded.status, deadline = excluded.deadline;

-- Precisa Serviços: 10, Letícia + André(TP), Desenvolvimento, prazo 18/05, Instagram, $500 tráfego
insert into cronograma (client_id, year, month, produced, target, designer, traffic_manager, has_traffic, status, deadline, observations)
select id, 2026, 6, 0, 10, 'Letícia', 'André', true, 'desenvolvimento', '2026-05-18', 'Instagram · investimento tráfego $500'
  from clients where name = 'Precisa Serviços'
on conflict (client_id, year, month) do update set
  target = excluded.target, designer = excluded.designer,
  traffic_manager = excluded.traffic_manager, has_traffic = excluded.has_traffic,
  status = excluded.status, deadline = excluded.deadline, observations = excluded.observations;

-- Qualific: 10, Letícia, Desenvolvimento, prazo 25/05, Instagram
insert into cronograma (client_id, year, month, produced, target, designer, status, deadline, observations)
select id, 2026, 6, 0, 10, 'Letícia', 'desenvolvimento', '2026-05-25', 'Instagram'
  from clients where name = 'Qualific'
on conflict (client_id, year, month) do update set
  target = excluded.target, designer = excluded.designer,
  status = excluded.status, deadline = excluded.deadline, observations = excluded.observations;

-- Banca de Síndicos: 10, Julia + André(TP), MLABS Vini, prazo 22/05, Instagram
insert into cronograma (client_id, year, month, produced, target, designer, traffic_manager, has_traffic, status, deadline, observations)
select id, 2026, 6, 0, 10, 'Julia', 'André', true, 'mlabs-vini', '2026-05-22', 'Instagram'
  from clients where name = 'Banca de Síndicos'
on conflict (client_id, year, month) do update set
  target = excluded.target, designer = excluded.designer,
  traffic_manager = excluded.traffic_manager, has_traffic = excluded.has_traffic,
  status = excluded.status, deadline = excluded.deadline, observations = excluded.observations;

-- Dener: 10, Éllen, Desenvolvimento, prazo 25/05
insert into cronograma (client_id, year, month, produced, target, designer, status, deadline)
select id, 2026, 6, 0, 10, 'Éllen', 'desenvolvimento', '2026-05-25'
  from clients where name = 'Dener'
on conflict (client_id, year, month) do update set
  target = excluded.target, designer = excluded.designer,
  status = excluded.status, deadline = excluded.deadline;

-- Alegria Kids: 10, Julia + André(TP), Desenvolvimento, prazo 22/05, OBS: 500
insert into cronograma (client_id, year, month, produced, target, designer, traffic_manager, has_traffic, status, deadline, observations)
select id, 2026, 6, 0, 10, 'Julia', 'André', true, 'desenvolvimento', '2026-05-22', 'Instagram · 500'
  from clients where name = 'Alegria Kids'
on conflict (client_id, year, month) do update set
  target = excluded.target, designer = excluded.designer,
  traffic_manager = excluded.traffic_manager, has_traffic = excluded.has_traffic,
  status = excluded.status, deadline = excluded.deadline, observations = excluded.observations;

-- Rentalsul: 10, Henrique, Desenvolvimento, prazo 26/05
insert into cronograma (client_id, year, month, produced, target, designer, status, deadline)
select id, 2026, 6, 0, 10, 'Henrique', 'desenvolvimento', '2026-05-26'
  from clients where name = 'Rentalsul'
on conflict (client_id, year, month) do update set
  target = excluded.target, designer = excluded.designer,
  status = excluded.status, deadline = excluded.deadline;

-- ===== CAL PRONTO (cinza) =====

-- Sócias: Julia, Cal Pronto, prazo 22/05, Instagram
insert into cronograma (client_id, year, month, produced, target, designer, status, deadline, observations)
select id, 2026, 6, 0, 0, 'Julia', 'cal-pronto', '2026-05-22', 'Instagram · começar'
  from clients where name = 'Sócias'
on conflict (client_id, year, month) do update set
  designer = excluded.designer,
  status = excluded.status, deadline = excluded.deadline, observations = excluded.observations;

-- ===== PLANEJADOS / SEM STATUS =====

-- Top Sports: 15 conteúdos, Éllen, sem status definido ainda
insert into cronograma (client_id, year, month, produced, target, designer, status)
select id, 2026, 6, 0, 15, 'Éllen', 'planejado'
  from clients where name = 'Top Sports'
on conflict (client_id, year, month) do update set
  target = excluded.target, designer = excluded.designer, status = excluded.status;

-- Franci: captação
insert into cronograma (client_id, year, month, produced, target, status, observations)
select id, 2026, 6, 0, 0, 'planejado', 'captação'
  from clients where name = 'Franci'
on conflict (client_id, year, month) do update set
  status = excluded.status, observations = excluded.observations;

-- iGet: Julia, aguardando vídeos do evento
insert into cronograma (client_id, year, month, produced, target, designer, status, observations)
select id, 2026, 6, 0, 0, 'Julia', 'planejado', 'aguardando os vídeos do evento'
  from clients where name = 'iGet'
on conflict (client_id, year, month) do update set
  designer = excluded.designer, status = excluded.status, observations = excluded.observations;

-- Eucassel: Julia + André(TP) — APENAS TRÁFEGO PAGO
insert into cronograma (client_id, year, month, produced, target, designer, traffic_manager, has_traffic, status, observations)
select id, 2026, 6, 0, 0, 'Julia', 'André', true, 'apenas-trafego', '$100 meta $500 google'
  from clients where name = 'Eucassel'
on conflict (client_id, year, month) do update set
  designer = excluded.designer,
  traffic_manager = excluded.traffic_manager, has_traffic = excluded.has_traffic,
  status = excluded.status, observations = excluded.observations;

-- Confirma quantas linhas foram criadas em junho/2026
select count(*) as total_linhas_junho from cronograma where year=2026 and month=6;
