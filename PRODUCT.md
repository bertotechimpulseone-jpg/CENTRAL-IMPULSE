# Product

## Register

product

## Users

A equipe da **Impulse One**, agência de marketing em Porto Alegre/RS (~14 pessoas). Três perfis:

- **Vinícius (dono/head)** — usa o sistema o dia inteiro, no desktop e no celular, saltando entre clientes, financeiro, captações e equipe. Precisa de acesso a tudo e de visão de controle rápida.
- **Gestão (Haisa, Heidy)** — financeiro, pagamentos, feedbacks, desligamento, pesquisa NR-1.
- **Colaboradores (designers, social media, videomaker, tráfego, comercial)** — entram para tarefas pontuais: checklist do dia, captação, solicitações, ponto. Muitos usam **no celular, em campo** (captação em obra, evento, rua).
- **Clientes da agência (externos)** — não fazem login: recebem **links públicos** (aprovar calendário, pedir conteúdo, briefing de captação, vaga, pesquisa). Para eles o sistema é a cara da agência.

Contexto de uso: dia corrido de agência. Ninguém "explora" o sistema, todo mundo entra para resolver uma coisa e sair.

## Product Purpose

Substituir a colcha de planilhas, PDFs e grupos de WhatsApp por um lugar só: clientes, cronograma de conteúdo, captações, calendário de aprovação, financeiro, equipe e RH. Sucesso = a pessoa abre, resolve e fecha sem atrito, e **nada que foi escrito se perde**.

## Brand Personality

**Confiante, viva, direta.** É uma agência criativa: o sistema não pode parecer um ERP cinza. Mas é ferramenta de trabalho: a personalidade aparece no acento, no movimento e no acabamento, nunca atrapalhando a leitura do dado.

Voz da interface: português do Brasil, informal e claro, primeira pessoa do plural quando fala pela agência. Sem jargão técnico ("Salvo no seu aparelho, nada foi perdido" em vez de "erro de sincronização").

## Anti-references

- **ERP/CRM corporativo** (Totvs, SAP, Salesforce clássico): cinza, denso, frio.
- **Dashboard SaaS genérico**: número gigante + rótulo pequeno + gradiente decorativo repetido em toda seção.
- **Bootstrap/Material puro**: cara de template, sem identidade.
- Enfeite que atrapalha: glassmorphism decorativo, texto em gradiente, borda lateral colorida como acento, eyebrow em CAPS acima de toda seção.

## Design Principles

1. **O dado é o herói.** Cor e movimento servem para orientar (status, formato, prioridade), não para decorar.
2. **Nada se perde, e a pessoa sabe disso.** Estados de salvamento, fila offline e mensagem de manutenção são parte do design, não um detalhe técnico.
3. **Celular é campo, não miniatura.** Quem usa no celular está de pé, em obra, com uma mão. Alvos grandes, modais em `dvh`, nada que exija precisão.
4. **Toda tela pública é a marca.** O que o cliente da agência vê (aprovar calendário, briefing) tem padrão de acabamento mais alto que a tela interna.
5. **Acabamento acima de novidade.** Antes de inventar um componente, elevar o que já existe: hierarquia, respiro, foco, estado.

## Accessibility & Inclusion

- Alvo **WCAG 2.1 AA**: corpo ≥4.5:1, texto grande ≥3:1. Texto auxiliar (`--text-3`) precisa passar em 4.5:1 — é usado como informação, não só enfeite.
- **Foco visível** em tudo que é operável (teclado é usado no desktop o dia inteiro).
- **`prefers-reduced-motion`** obrigatório em toda animação.
- Status nunca só por cor: sempre cor + ícone/rótulo (✓ aprovado, ✎ ajuste).
- Tema claro e escuro são ambos de primeira classe (o time alterna).
