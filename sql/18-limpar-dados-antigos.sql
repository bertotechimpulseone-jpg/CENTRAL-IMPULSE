-- ============================================================
-- LIMPEZA DE DADOS ANTIGOS (opcional - rode no Supabase SQL Editor)
-- ============================================================
-- Use este script se ainda aparecerem CAPTAÇÕES, PRAZOS ou
-- outros dados que voce nao reconhece como reais.
--
-- ATENCAO: este script APAGA tudo. Se voce ja adicionou dados
-- reais, NAO rode estas linhas — comente as que nao quer rodar.
-- ============================================================

-- Limpa todas as captacoes (use se ainda aparecerem fakes)
delete from captacoes;

-- Limpa cronograma (zera prazos/produzido/meta de todos os meses)
-- Isso vai sumir com banners de "prazos HOJE" / "amanha"
update cronograma set
  produced = 0,
  target = 0,
  has_traffic = false,
  status = 'planejado',
  deadline = null,
  observations = null;

-- (Opcional) Limpa tarefas, reunioes, leads, orcamentos, etc.
-- Descomente apenas as que voce realmente quer apagar:
-- delete from tasks;
-- delete from meetings;
-- delete from leads;
-- delete from budgets;
-- delete from automations;
-- delete from feedbacks;
-- delete from time_clock;          -- ATENCAO: apaga pontos batidos!
-- delete from transactions;
-- delete from commemorative_dates;

-- Confirma quanto sobrou em cada tabela:
select 'captacoes' as tabela, count(*) as total from captacoes
union all
select 'cronograma com deadline' as tabela, count(*) as total from cronograma where deadline is not null;
