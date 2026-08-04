-- ============================================================
-- 68 - DESLIGAMENTOS (entrevista de desligamento)
--   Aba 'Desligamento' (grupo Interno) — registro das reunioes
--   de desligamento. Restrito a gestao/lideranca (is_gestor_app).
-- Idempotente — seguro rodar mais de uma vez.
-- ============================================================

create table if not exists public.desligamentos (
  id            uuid primary key default gen_random_uuid(),
  colaborador   text not null,
  data_saida    text,
  respostas     jsonb not null default '[]'::jsonb,  -- array de 10 respostas (ordem das perguntas)
  created_by_email text,
  created_at    timestamptz not null default now()
);

grant select, insert, update, delete on public.desligamentos to authenticated;
alter table public.desligamentos enable row level security;

-- Funcao de acesso (gestao/admin/lideranca) — mesma logica da Pesquisa NR-1. Idempotente aqui pra nao depender do sql/66.
create or replace function public.is_gestor_app()
returns boolean language sql stable security definer set search_path = public as $fn$
  select
    lower(auth.jwt() ->> 'email') in (
      'vini@impulseone.com.br','vinicius@impulseone.com.br',
      'heidy@impulseone.com.br','heidi@impulseone.com.br','haisa@impulseone.com.br'
    )
    or exists (
      select 1 from public.profiles p
      where lower(p.email) = lower(auth.jwt() ->> 'email')
        and (
          lower(coalesce(p.role,'')) in ('admin','gestor')
          or lower(split_part(coalesce(p.full_name,''),' ',1)) in (
            'vinicius','vinícius','vini','heidy','heidi','heydi','heydy','haisa','haísa','haysa'
          )
        )
    );
$fn$;

drop policy if exists desligamentos_select on public.desligamentos;
create policy desligamentos_select on public.desligamentos for select to authenticated using (public.is_gestor_app());
drop policy if exists desligamentos_insert on public.desligamentos;
create policy desligamentos_insert on public.desligamentos for insert to authenticated with check (public.is_gestor_app());
drop policy if exists desligamentos_update on public.desligamentos;
create policy desligamentos_update on public.desligamentos for update to authenticated using (public.is_gestor_app()) with check (public.is_gestor_app());
drop policy if exists desligamentos_delete on public.desligamentos;
create policy desligamentos_delete on public.desligamentos for delete to authenticated using (public.is_gestor_app());

-- Seed dos 6 desligamentos existentes (idempotente por colaborador)
insert into public.desligamentos (colaborador, data_saida, respostas)
select v.colaborador, v.data_saida, v.respostas from (values
  ('ENRIQUE LOPES', '29/04/25', jsonb_build_array('Impulse não é a renda prinicipal, então procurou algo que fosse para trazer mais estabilidade', 'Bem diferente de outras empresas que já trabalhou. Gosta das reuniões de segunda-feira, sempre muito o time muito receptivo.', 'Dinamica, organização das plataformas, planejamento de aprovação (trello).', 'Não identificou nenhum desafio, comentou apenas sobre aprender a entender o cliente', 'Sim', 'Sempre viu a impulse com olhos para se ve crescer, mas no momento como nao era a renda principal nãop houve essa possibilidade', 'Sempre se sentiu valorizado, sentia que massageamos sempre seu ego kk', 'Foi muito tranquilo, sempre o time disposto a resolver o problema.', 'Sempre disponivel, mesmo nos dias corridos,  quando o lider não estava disponivel, o haniel dava suporte. Sempre tratou muito bem.', 'Só esta saindo, não por vontade, mas sim por dinheiro. Mas se vê super fazendo projetos dentro da impulse.')),
  ('BENTO', '18/07/25', jsonb_build_array('Salário maior e menos horas de trabalho', 'Unidos, parceiros, organizados, agilidade.', 'O relacionamento com o vini, nossa organização', 'Adaptação na comunicação no whats, e um "bombardeiro de tarefas" em alguns momentos', 'Recebeu todo o suporte por parte da impulse', 'Muito bom para criar sua própria confiança profissional, no outro estágio ele se sentia ansioso\quietinho,  e aqui sentiu que conseguiu se desenvolver melhor', 'Se sentiu valorizado, que cresceu profissionalmente, sentiu oque o que estava fazendo era bom e util', 'Comunicação interna otima', 'Tudo certo, se sentiu acolhido', 'Claro')),
  ('ELI', '14/07/25', jsonb_build_array('Unico fator é o financeiro, por conta qu ele vai ter um filho e o aumento de gasto', 'A melhor empresa que ele já passou durante a carreira, amou a experiencia, sem pressão, super tranquilo', 'Ambiente tranquilo, muito dialogo e aprendizado, compreensivo.', 'maior desafio foi criar copy, e montar o fluxo com a mary.', 'Com certeza', '', 'Sim', 'A unica sugestão que ele tem é sobre trabalhar em via discord, sempre em call. E sobre o tralho tem uma ferramenta (clicap) uma ferramenta sobre demanda.', 'Muito bom, a experiencia muito boa.  Smepre teve suporte', 'Super quer ter contato, mas não faria freela no momento')),
  ('Haniel', '18/08/25', jsonb_build_array('Teve diversas batalhas, teve que escolher a propria vida pra focar', 'Cultura de acolhimento, "abraçar", mas não sente que a equipe é conectada.', 'Forma como o vini colocou embaixo das assas dele, aprendeu muito com o vini', 'dificuldade na comunicação com algumas pessoas (principalmente com a sabrina)', 'sim , o suficiente para trabalhar. mas poderia melhorar se tivessemos uma assinatura de banco de imagem.', 'Sente falta de um processo de onbording', 'algumas vezez sentiu muita responsabilidade, e financeramente não reconhecido.', '', '', '')),
  ('SABRINA', '22/01/2026', jsonb_build_array('Promoção da empresa que já trabalhava', 'A Impulse é muito boa, a empresa mais humana, que tem um entendimento melhor sobre as dores do colaborador. Teve melhoras com guia da alma e wellhub.', 'A impulse confirmou que ela conseguia se auto gerenciar. Ela se dasafiou e conseguiu.', 'Não teve pois o objetivo era ser designer senior, então foi bem tranquilo.', 'Recebeu suporte e o recurso utilizado para realizar o trabalho foi o banco de imagem de cliente', '', 'Sim, principalmente pelo feedback que trazia dos clientes e das lideranças', 'Cliente que não sabe o que quer tudo é urgente. Cliente que não quer preencher briefing é dificil, pq o designer tem que se virar. Comunicação rápida e limpa é o diferencial.', 'A relação sempre foi boa e foi melhorando com o tempo. Não tinha muito contato com a equipe. Mas gostava de saber que ela era referencia para muitos colaboradores', 'Dependendo do projeto, social midea não vale a pena. Projeto de identidade visual sim!')),
  ('Gabrielle Sobral', '15/05/26', jsonb_build_array('Principal foi as condições financeiras, estava com saudade de ser designer.', 'Somos abertos a conversas, parceiros.', 'Aprendeu muito de social, atendimento ao cliente, orçanização.', 'Foi desafiador no começo, sempre vinicius muito ocupado e ela foi pegando tudo muito sozinha.', 'SIm. sem problemas', 'Acha necessário criar um plano de carreira, cultura de crescimento.', 'Sim', 'Mudar um pouco a reunião de segunda, para falar tambem como está a empresa.', 'Fui tranquiça, tivemos altos e baixos, as vezes sentia que a comunicação era mesmo rispida, direta, mas as vezes mais tranquila, de fases.', 'Não sabe como vai ficar a situação.'))
) as v(colaborador, data_saida, respostas)
where not exists (select 1 from public.desligamentos d where d.colaborador = v.colaborador);

select 'Desligamentos: tabela criada + seed dos 6 existentes (restrito a gestao)' as resultado;
