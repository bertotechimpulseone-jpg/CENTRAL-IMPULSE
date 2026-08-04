# IMPULSE ONE — Sistema de Gestão de Agência

**Versão:** 3.85 · maio/2026
**Tipo:** Web app responsivo (desktop + mobile) · Single Page Application
**Stack:** HTML5 · JavaScript Vanilla · Supabase (Postgres + Auth + Storage + Realtime) · Vercel · jsPDF · Chart.js
**Acesso:** impulse-one.vercel.app · multi-usuário com login individual

---

## 🎯 O que é o IMPULSE ONE

Sistema operacional completo desenvolvido sob medida para a operação de uma agência de marketing digital. Unifica em uma única plataforma todas as áreas críticas do negócio: comercial, captação audiovisual, cronograma de conteúdo, financeiro, gestão de equipe, controle de ponto, relacionamento com cliente, precificação inteligente e governança societária.

Diferente de soluções genéricas (Asana, monday, Trello, RD), o IMPULSE ONE foi construído **a partir dos fluxos reais** da agência — cada tela atende a um processo específico que já existia em planilhas, WhatsApp ou cabeça das pessoas.

---

## 📦 Funcionalidades atuais (entregues em produção)

### 1. Dashboard inteligente
- Saudação personalizada com nome do usuário
- Banner de **prazos urgentes** (HOJE e D-1) no topo de todas as páginas
- **Notificações de feriados** D-7 e D-1
- Widget flutuante de **Lembretes pessoais** (individual por colaborador)
- Sininho com badge de contagem
- Visão objetiva: a primeira tela ao logar é a mais útil pro perfil de cada um

### 2. CRM de Clientes
- Cards visuais com logo do cliente (upload), iniciais, segmento, status (Ativo/Cancelado)
- Cliente exclusivo (sem fluxo CRM, só pra orçamento avulso)
- Modal completo com 7 abas:
  - **Visão Geral:** quick actions (WhatsApp, Instagram, Drive, Meet, MLABS, Site, Criativos, Relatórios, Contrato), informações de contato editáveis inline, CNPJ, início do contrato, segmento, owner interno
  - **Plano & Serviços:** plano contratado, valor (visível só pra admin financeiro), designer dedicado, contract_start, renovation_date
  - **Cronograma:** atalho pro cronograma do mês
  - **Jornada:** checklist editável de etapas do onboarding
  - **Briefing:** formulário público compartilhável (cliente preenche sem login)
  - **Antes da Impulse:** histórico pré-contrato
  - **Histórico:** timeline completo
- **Mensagens prontas pra WhatsApp** (cobrança, aprovação, reunião, material, follow-up, aniversário, pós-reunião)
- **Acessos (logins/senhas)** das plataformas do cliente — criptografados, restritos
- **Gerenciador de Links** pra contratos múltiplos (aditivos)
- **Upload de logo** do cliente com fallback pra iniciais
- **Ocultar/restaurar** clientes da lista principal

### 3. Cronograma operacional
- **Planilha mensal** (Jan a Dez) por cliente com estatísticas em tempo real
- **Status customizados** com cores fortes:
  - Apenas Tráfego · Agendado MLABS · Agendado Meta · Aguardando Aprovação · Trello Vini · MLABS Vini · Desenvolvimento · Cal Pronto · Cancelado
- Campos por linha: produzidos/meta com barra de progresso, tráfego pago (com gestor), designer, POP (1/2/3), prazo com badge HOJE/atrasado/em Xd, observações
- **Ordenação automática** por status (mais urgente no topo)
- Filtros por status + busca livre + clientes ocultos
- **Banner pulsante** de prazos urgentes no topo
- **Persistência local + Supabase** (não perde dados se ficar offline)
- **Coluna de cliente fixa** no mobile com cor do status, scroll horizontal touch

### 4. Captação audiovisual
- **3 visualizações:** Lista, Calendário, Kanban
- Status: agendada · confirmada · em andamento · finalizada · cancelada
- Upload de **briefing PDF/Word** (Storage Supabase com fallback base64)
- **Link público da captação** (cliente acessa sem login pra ver detalhes)
- **Auto-preencher telefone** ao selecionar responsável (Yas/Vini/Gael)
- **Apelidos aceitos** (Gabriel = Gael, Yas = Yasmin)
- **Prazo +15 dias automático** pra entrega após captação
- Cards de captações passadas em cinza (destaque pras próximas)
- Filtro automático por responsável (colaborador comum vê só as dele; Gabi e admins veem todas)
- Modal com botão de compartilhar link

### 5. Comercial
- **Pipeline de leads** com kanban
- **Orçamento profissional:**
  - Cliente do CRM ou inserção manual
  - Itens editáveis inline
  - Desconto percentual (até 10% livre · acima exige senha de aprovação)
  - PDF com logo da Impulse, dados do cliente, itens, totais formatados
  - Forma de pagamento, prazo, observações livres
  - Histórico de orçamentos salvos
  - Envio direto via WhatsApp
- **💲 Precificação (DRE):**
  - **Base de cálculo bloqueada** com senha "abundancia" — esconde custos da equipe
  - Configuração: Pessoas custo · Custo fixo+variável · Clientes ativos · Horas/mês · Valor hora calculado
  - **18 produtos padrão** editáveis (Plano Pulse, Impulse+, Captação, Ficha Google, Tráfego, Design, Fotografia, Consultoria, E-book, Post, Carrossel, Site, etc)
  - **3 faixas de margem** (M 70%, G 100%, GG 200%) configuráveis
  - Cálculo automático: custo × (1 + margem) com arredondamento elegante (final 9 ou 90)
  - Override manual por preço (mantém auto-calc visível)
  - **Fluxo dinâmico:** seleciona produtos → escolhe faixa M/G/GG → adiciona serviço custom → gera orçamento → vai pra Comercial → adiciona cliente e gera PDF
- **Upsell & Projeções** com clientes ativos
- **Histórico de orçamentos** filtrável (ano/mês/status/cliente) com gráfico

### 6. Operacional / Checklist diário
- Lista de tarefas por colaborador, ordenadas por pendentes primeiro
- Hora prevista + hora de conclusão
- Edição inline (clica no item)
- Cliente vinculado
- Prioridade visual

### 7. Calendário corporativo
- **Feriados completos:** nacionais + RS + Porto Alegre + móveis (Páscoa, Carnaval, Corpus Christi via algoritmo Meeus/Jones/Butcher) + Dia das Mães/Pais
- **Aniversários da equipe** com idade
- **Admissões** com tempo de empresa
- **Férias programadas** em barra contínua
- **Captações** marcadas no calendário
- **Prazos de entrega** com cor de urgência
- **Eventos manuais** (reuniões, treinamentos, prazos, tarefas, outros) com cor, local, link, descrição, notificação
- **Visão mobile dedicada:** lista vertical com dia da semana
- **Tudo clicável** — abre modal apropriado por tipo
- Notificações D-7 e D-1 de feriados no dashboard

### 8. Tráfego Pago
- Campanhas por cliente com investimento, resultado, CPA, status
- **Gráfico Investimento × Resultados separado por plataforma:**
  - Meta/Facebook/Instagram → azul `#1877f2`
  - Google/YouTube → vermelho `#ea4335`
  - TikTok → preto
  - LinkedIn → azul corporativo `#0a66c2`
  - Outros → cinza
- Lista filtra automaticamente clientes com campanha ativa
- Detalhe por cliente com tabela completa

### 9. Reuniões
- Agendamento com link Google Meet
- Tipo + plataforma + participantes
- Notas e ata pós-reunião
- Cliente vinculado opcional
- Lembrete automático (D-1 ou X minutos antes)

### 10. I3 — Combinados dos Sócios (admin only)
- **Atas mensais** das reuniões de sócios
- **Impulse Learning semanal:** quem é o responsável da semana, tema, data, observações
- **Encontros presenciais mensais** com criação automática no calendário
- 4 seções editáveis por ata: Obs RH · Conclusões/Plano de Ação · Pontos de Atenção · Pontos para Analisar
- Cards colapsáveis · futuras primeiro · passadas em cinza
- Botão **🧹 Limpar órfãos** detecta e remove eventos da agenda sem reunião vinculada
- Dia da semana exibido em todas as datas

### 11. Equipe
- Cards de colaboradores ordenados alfabeticamente
- **Perfil completo:** salário (oculto pra não-admin), férias (total/usadas), CPF/CNPJ alternável, chave PIX, banco, tipo de contrato (CLT/PJ/MEI/Estágio/Freelance), endereço, telefone, email, aniversário, admissão, próxima avaliação, áreas a desenvolver, pontos fortes
- **Programar férias** com modal multi-período e validação de 30 dias
- Histórico de férias por ano
- **Excluir colaborador** com proteção (se tem dados vinculados, oferece apenas remover da lista de férias)
- **Restaurar colaborador excluído** via modal com seleção
- Documentos por perfil (upload Storage)

### 12. Feedback
- Por colaborador, agrupado por período (Q1/Q2/Q3/Q4)
- Score 0-10 + texto
- Autor visível
- Ordem alfabética e filtro de excluídos

### 13. Ponto (estagiários + admins)
- **Folha eletrônica** com horário oficial de Brasília
- Entrada · Início intervalo · Fim intervalo · Saída
- **Login individual** com senha do colaborador
- Stats por dia/semana/mês
- Lista de quem bateu hoje
- Filtros: mês, ano, colaborador
- Exportação PDF e Excel
- **Restrito a estagiários** (CLT/PJ não veem o menu)
- Edição manual pra correções (só admin)

### 14. Pagamentos
- **Fixos mensais:** aluguel, salários, assinaturas — editáveis, com status pago/pendente por mês
- **Variáveis por colaborador:** descrição, valor, status, data
- **Filtro de mês + colaborador**
- **Admin financeiro** (Vini, Ederson, Heidy, Haisa) vê tudo
- **Colaborador comum** vê apenas os próprios (proteção forçada)
- **Caso especial André:** UI dedicada por cliente com valor padrão R$ 350 (editável por cliente)
- Total fixos + variáveis no header
- Histórico mensal completo

### 15. Financeiro (só gestor)
- Despesas e entradas categorizadas

### 16. Arquivos
- Documentos centralizados

### 17. Usuários (admin only)
- Criar / editar / excluir colaboradores
- **Permissões granulares** (lista de 20 páginas com checkbox)
- **Trocar senha** de qualquer usuário (RPC SQL com admin override)
- Editar nome, email, cargo

### 18. Configurações
- **Identidade visual:** upload de logo da agência (sync com sidebar + PDF de orçamento)
- Tema claro/escuro

### 19. Relacionamento (CRM operacional)
- **Timeline de contatos** por cliente
- Tipos: WhatsApp · Ligação · Reunião · Email · Presencial · Feedback · Suporte · Aprovação
- Modal de novo contato com responsável, resumo, próxima ação, próxima data, observações internas
- **Saúde dos clientes** (dias sem contato, badge crítico)
- Gráficos de evolução
- Box de próximo contato no header

### 20. Parcerias
- Lista de parcerias com cliente, valor investido, valor de retorno manual, ROI calculado
- Tabela de resultados ao longo do tempo
- Total agregado

### 21. Almoço (whitelist Fran/Haisa/Heidy/Vini)
- Controle mensal: equipe interna + outros convidados
- Stats: total no mês · por colab · custo total
- Ranking visual de almoços por pessoa
- Filtro por mês
- Cada registro: data, hora, nome, custo (opcional), observações

### 22. Lembretes (individuais)
- Widget flutuante no canto inferior direito
- Filtrado por `profile_id` do usuário logado (privacidade)
- Modal com descrição + data + hora + checkbox concluído
- Status temporal visual: atrasado (vermelho) · hoje (laranja) · amanhã · em Xd
- Editar clicando · excluir com confirmação

---

## 🔧 Sistemas transversais (em todas as telas)

- **Autenticação Supabase** com email/senha, sessão persistente
- **Row Level Security (RLS)** em todas as tabelas
- **Realtime sync** — alterações de outros usuários aparecem ao vivo
- **Auto-save universal** — todos os campos editáveis salvam sozinhos
- **Cache localStorage** pra resiliência offline
- **Persistência de página** ao recarregar (volta na aba onde estava)
- **Botão voltar** no mobile com histórico de 20 páginas
- **Botão refresh** no mobile (recarrega dados sem F5 do navegador)
- **Confirmação "apagar"** universal: 37+ exclusões exigem digitar a palavra
- **Senha "abundancia"** para ações restritas (base DRE, descontos > 10%)
- **Apelidos da equipe** (10+ grupos: yas/yasmin, vini/vinicius, gabriel/gael, heidi/heidy, haisa/haysa, andre/andré, leticia/letícia, ederson/eder, gabi/gabriela)
- **Auto-merge de duplicatas** de profiles
- **Sistema de roles:** admin · gestor · colaborador · admin financeiro · estagiário
- **Whitelist por nome** pra admins (Vini, Ederson, Heidy, Haisa)
- **Mobile responsivo total** com touch targets Apple HIG (44px+)
- **PDF generation** com jsPDF (logo customizado, itens, totais)
- **Excel export** pra ponto
- **Detecção de tipo de PDF** automática (PNG/JPG)
- **Gráficos** com Chart.js
- **Sistema de "última atualização" automático** em todas as tabelas (trigger SQL)

---

## 📊 Dados gerenciados (29 tabelas no Supabase)

`clients` · `profiles` · `captacoes` · `cronograma` · `cronograma_obs` · `app_settings` · `client_accesses` · `client_briefings` · `link_groups` · `links` · `journey_steps` · `feedbacks` · `meetings` · `eventos_calendario` · `ferias_programadas` · `lembretes` · `trafego_campanhas` · `client_relationships` · `parcerias` · `parcerias_resultados` · `pagamentos_fixos` · `colaborador_pagamentos` · `tasks` · `ponto_logs` · `budgets` · `budget_services` · `budget_clients` · `i3_reunioes` · `i3_learning` · `precificacao_config` · `precificacao_produtos` · `controle_almoco` · `transactions` · `colaboradores_excluidos`

---

## 🚀 Roadmap — Adições futuras (oportunidade de venda)

### Fase 1 — Integrações de produtividade (1-3 meses)

**WhatsApp Business API**
- Envio automático de cobranças
- Aviso de vencimento D-7 e D-1
- Resposta automática a perguntas frequentes
- Confirmação de captação 24h antes
- Envio de PDFs (orçamentos, relatórios) direto pelo sistema

**Google Calendar (sync bidirecional)**
- Captações + reuniões aparecem na agenda pessoal
- Eventos do Google aparecem no calendário corporativo
- Disponibilidade automática pra agendar

**Receita Federal (consulta CNPJ)**
- Auto-completar dados do cliente ao digitar CNPJ
- Validação automática de situação cadastral
- Alerta se cliente cair pra "inapta" ou "baixada"

**Asaas / Stripe**
- Cobrança recorrente automática
- Boleto / PIX / cartão direto pelo sistema
- Conciliação automática

### Fase 2 — Inteligência artificial (3-6 meses)

**Assistente de copy** (GPT-4 / Claude API)
- Gera legendas pra Instagram baseado no briefing
- Reescreve email pro cliente em 3 tons diferentes
- Cria roteiro de captação a partir de uma ideia
- Sugere ajustes ao receber feedback de cliente

**Relatórios narrativos automáticos**
- Final do mês: IA escreve relatório do cliente com base nos dados de tráfego, agendamentos, aprovações
- Comparativo mês a mês com insights
- Exportação como PDF formatado

**Análise preditiva**
- **Churn prediction:** identifica clientes com risco de cancelar (poucos contatos + atrasos + sem aprovação)
- **Upsell scoring:** quais clientes têm mais chance de aceitar Plano Pulse → Impulse+
- **Detecção de prazos em risco** com sugestão de ação

### Fase 3 — Mobile nativo (3-6 meses)

**App iOS + Android (React Native ou PWA)**
- Push notifications de prazos urgentes
- Modo offline com sync ao reconectar
- Câmera direta pra captação (fotos vão pro Drive do cliente)
- Geolocalização pra ponto (estagiário bate ponto no local certo)
- Ler QR Code pra check-in em captações
- Modo "atendimento em campo" com tudo do cliente offline

### Fase 4 — Time tracking integrado (1-2 meses)

**Pomodoro + horas por cliente**
- Cronômetro nativo (25/5)
- Cada sessão é vinculada a um cliente + tarefa
- Relatório semanal: horas reais vs. horas vendidas (Precificação)
- Alerta se cliente está consumindo mais que o plano (oportunidade de upsell)

### Fase 5 — Portal do cliente (2-3 meses)

**Cliente acessa com login próprio**
- Aprovar criativos da semana com 1 clique
- Comentar inline em cada peça
- Ver histórico de aprovações
- Acompanhar campanhas de tráfego em tempo real
- Pagar fatura
- Solicitar reuniões sem WhatsApp

**Pesquisa de satisfação automática mensal**
- NPS automático
- Feedback estruturado vai pro Relacionamento

### Fase 6 — Marketplace + SaaS multi-tenant (6+ meses)

**Vender o IMPULSE ONE como SaaS pra outras agências**
- Tenant isolation completo
- Cada agência tem subdomain (`xagencia.impulseone.com.br`)
- Faturamento R$ 99-299/usuário/mês por tier
- Onboarding automatizado em 5 minutos
- White-label opcional (agência usa marca própria)
- Marketplace de templates (orçamento, briefing, contrato)

### Fase 7 — Outras possibilidades

**Faturamento + NFe**
- Geração automática de notas fiscais
- Integração com contador (export pra Domínio, Onvio, Contabilizei)
- Conciliação bancária via Open Banking

**Gamificação**
- Pontos por entregar no prazo, atender bem, fechar venda
- Ranking mensal de colaboradores
- Conquistas/badges

**Wiki interna**
- POPs documentados
- Vídeos da Impulse Learning organizados em playlist
- Quiz pós-treinamento

**Segurança avançada**
- 2FA via SMS ou app
- Audit log completo (quem mudou o quê e quando)
- Backup diário com versionamento (rollback)
- Criptografia de campos sensíveis (CPF, senhas de cliente)

**Integrações de design**
- Figma embed (preview de criativos no sistema)
- Canva (importar designs sem trocar de aba)
- Adobe Creative Cloud (links profissionais)

**Integrações de mídia**
- Meta Ads API (importar campanhas, criar campanhas a partir do orçamento)
- Google Ads API (idem)
- TikTok Ads API
- LinkedIn Ads API
- Métricas em tempo real direto no Tráfego Pago

---

## 💼 Diferenciais para venda

### Versus soluções genéricas (Asana, monday, Trello, ClickUp)

- **Construído pra agência de marketing** — não é template adaptado, é fluxo nativo
- **Cronograma com status de produção** (Agendado MLABS, Cal Pronto, Apenas Tráfego) — soluções genéricas não têm esse vocabulário
- **Captação audiovisual nativa** — Asana não tem ideia do que é captação, briefing, prazo de entrega
- **Precificação DRE integrada** — calculadora de margem por hora trabalhada com 3 faixas (M/G/GG)
- **Ponto eletrônico CLT** integrado (pra estagiários)
- **Briefing público** — link compartilhável que cliente preenche sem login
- **PDF de orçamento profissional** com logo, sem precisar de Canva/InDesign

### Versus CRMs (RD Station, HubSpot, Pipedrive)

- **Operação fim-a-fim** — não termina na venda; segue com cronograma, captação, ponto, financeiro
- **Pagamento de colaboradores** integrado (não só recebíveis de cliente)
- **Relacionamento operacional** (não só comercial) — registra WhatsApp, aprovação, suporte
- **Custo previsível** — não cobra por contato (RD/HubSpot cobram a fortuna após X contatos)

### Versus financeiros (Conta Azul, Omie)

- **Não é só financeiro** — é o sistema operacional inteiro
- **Pagamento variável por cliente** (caso André R$ 350/cliente) — solução nativa, sem gambiarra
- **DRE de precificação** integrado (custo real → valor de venda)

### Argumentos comerciais

1. **Reduz uso de 8-12 ferramentas em 1**
   - Substitui: Asana + Trello + Google Calendar + RD Station + ContaAzul + Notion (wiki) + planilha de pagamento + planilha de precificação + sistema de ponto + WhatsApp Web (manual)

2. **Aumenta produtividade da equipe em 25-40%**
   - Tudo num só lugar = menos abrir abas
   - Auto-save = nada se perde
   - Realtime = informação fluindo

3. **Aumenta margem da agência em 10-20%**
   - Precificação correta (baseada em hora real)
   - Detecção de upsell
   - Identificação de clientes não rentáveis
   - Cobrança automática (reduz inadimplência)

4. **Reduz erros e retrabalho**
   - Briefing único, padronizado, do cliente
   - Aprovação rastreável
   - Histórico de tudo

5. **Profissionaliza a operação**
   - PDF com logo, contrato com link, briefing público
   - Cliente vê uma agência organizada, vira referência

---

## 💰 Sugestão de precificação

### Modelo 1: Implantação + Mensalidade

| Item | Valor | Observação |
|---|---|---|
| **Setup inicial** | R$ 8.000 – R$ 15.000 | Configuração, importação de dados, treinamento da equipe |
| **Mensalidade básica** | R$ 600 / mês | Até 5 usuários, todas as funcionalidades atuais (v3.85) |
| **Usuário adicional** | R$ 80 / mês | A partir do 6º usuário |
| **Suporte premium** | R$ 400 / mês | WhatsApp dedicado, atendimento em até 2h em horário comercial |

### Modelo 2: Anuidade (desconto pra fidelizar)

| Plano | Valor | Inclui |
|---|---|---|
| **Pulse** | R$ 6.000 / ano | Até 3 usuários, sistema básico |
| **Impulse** | R$ 12.000 / ano | Até 10 usuários, sistema completo |
| **Impulse +** | R$ 24.000 / ano | Até 25 usuários, suporte premium, customizações leves |
| **Enterprise** | Sob consulta | Multi-tenant, white-label, integrações específicas |

### Modelo 3: SaaS por tier (futuro multi-tenant)

| Tier | Usuários | Valor mensal | Anuidade |
|---|---|---|---|
| **Starter** | 1-3 | R$ 199 | R$ 1.990 (2 meses grátis) |
| **Pro** | 4-10 | R$ 499 | R$ 4.990 |
| **Business** | 11-25 | R$ 999 | R$ 9.990 |
| **Enterprise** | 25+ | Sob consulta | — |

### Customizações (caso a caso)

| Item | Faixa |
|---|---|
| Integração WhatsApp Business API | R$ 3.000 – R$ 6.000 |
| Integração Google Calendar | R$ 1.500 – R$ 3.000 |
| Integração Meta Ads / Google Ads | R$ 5.000 – R$ 10.000 |
| App mobile nativo (iOS + Android) | R$ 15.000 – R$ 40.000 |
| Portal do cliente | R$ 8.000 – R$ 15.000 |
| Assistente IA pra copy | R$ 6.000 – R$ 12.000 |
| Branding/white-label | R$ 4.000 – R$ 8.000 |

---

## 🎯 Como apresentar pro cliente

### Pitch de 30 segundos
> "Sabe quando você tem 10 abas abertas, 3 grupos de WhatsApp, uma planilha de cronograma e um caderno do lado pra anotar? O IMPULSE ONE é uma única tela que substitui tudo isso. Foi feito DENTRO de uma agência, pra uma agência. Não é Asana adaptado — é cronograma de produção, briefing público pro cliente preencher, ponto eletrônico pros estagiários, captação audiovisual com link compartilhável, e precificação que calcula margem por hora trabalhada. Tudo num lugar, no celular ou no computador, com dados em tempo real."

### Demonstração ideal (15 min)
1. **Login e dashboard** — saudação personalizada, prazos urgentes em destaque
2. **Cliente → Visão Geral** — quick actions de WhatsApp + Drive + briefing público
3. **Cronograma** — planilha mensal com cores fortes por status, prazos batendo
4. **Captação → Calendário** — captações próximas em destaque, passadas em cinza
5. **Precificação** — base bloqueada com senha, tabela de produtos, criar orçamento dinâmico
6. **Orçamento → PDF** — gera PDF profissional com logo na hora
7. **Mobile** — celular com tabela cronograma scrollável + botão voltar/refresh

### Objeções comuns e respostas

**"Posso fazer no monday/Asana"**
> O monday é genérico — você gasta 3 meses configurando uma estrutura que aqui já vem pronta pro fluxo de agência. Aqui você importa seus clientes e em 1 hora a agência inteira tá usando.

**"E se vocês quebrarem?"**
> Os dados são do cliente, ficam no Supabase (Postgres padrão). Exportação completa a qualquer momento. Sistema open-stack (HTML/JS) — qualquer dev pega de pé.

**"É caro"**
> Compare com a soma de 8 ferramentas (Asana R$50, ContaAzul R$300, Notion R$50/usuário, RD R$800, sistema de ponto R$200, Canva R$50, etc) + horas-equipe perdidas trocando de aba. Custa menos e entrega mais.

---

## 📁 Arquivos do projeto

- `index.html` — Aplicação inteira (HTML + CSS + JS em arquivo único, ~1.1MB)
- `sql/` — Migrations Supabase numeradas (00 a 53)
- `vercel.json` — Configuração de deploy
- `CLAUDE_MEMORY.md` — Memória técnica (padrões de bug, decisões de arquitetura)
- `IMPULSE_ONE_DESCRICAO_COMPLETA.md` — Este documento

---

## 📞 Suporte e evolução

Sistema em desenvolvimento ativo, com mais de **300 features e correções entregues** nos últimos meses. Roadmap claro de evolução. Equipe técnica disponível pra customizações e integrações sob demanda.

**Desenvolvido por:** Vinícius / Impulse One Studio · Porto Alegre/RS
