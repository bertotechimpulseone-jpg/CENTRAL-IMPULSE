const fs = require("fs");
const path = require("path");
const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
  Header, Footer, AlignmentType, LevelFormat, TabStopType, TabStopPosition,
  HeadingLevel, BorderStyle, WidthType, ShadingType, VerticalAlign, PageNumber, PageBreak
} = require("docx");

// ---------- helpers ----------
const ACCENT = "16171D";   // preto/grafite da marca
const GREY = "555555";
const LINE = 300;          // ~1.25 espaçamento

function runs(input, base = {}) {
  if (typeof input === "string") return [new TextRun({ text: input, ...base })];
  // array of {t, b, i, color}
  return input.map(r => new TextRun({ text: r.t, bold: r.b, italics: r.i, color: r.color, ...base }));
}

function P(input, opts = {}) {
  const { align = AlignmentType.JUSTIFIED, after = 140, before = 0, size = 22, bold, italics, color, indent } = opts;
  return new Paragraph({
    alignment: align,
    spacing: { after, before, line: LINE },
    indent,
    children: runs(input, { size, bold, italics, color }),
  });
}

function H1(text) {
  return new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun(text)] });
}
function H2(text) {
  return new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun(text)] });
}
function quote(text) {
  return new Paragraph({
    alignment: AlignmentType.JUSTIFIED,
    spacing: { after: 140, before: 60, line: LINE },
    indent: { left: 720, right: 360 },
    border: { left: { style: BorderStyle.SINGLE, size: 18, color: ACCENT, space: 12 } },
    children: [new TextRun({ text, italics: true, size: 21, color: "333333" })],
  });
}
function bullet(input, level = 0) {
  return new Paragraph({
    numbering: { reference: "bul", level },
    alignment: AlignmentType.JUSTIFIED,
    spacing: { after: 80, line: LINE },
    children: runs(input, { size: 22 }),
  });
}

// table cell
const bd = { style: BorderStyle.SINGLE, size: 1, color: "BBBBBB" };
const borders = { top: bd, bottom: bd, left: bd, right: bd };
function cell(content, w, { head = false, shade } = {}) {
  const kids = (Array.isArray(content) ? content : [content]).map(t =>
    new Paragraph({
      spacing: { after: 0, line: LINE },
      children: [new TextRun({ text: t, bold: head, size: head ? 20 : 20, color: head ? "FFFFFF" : "222222" })],
    })
  );
  return new TableCell({
    borders,
    width: { size: w, type: WidthType.DXA },
    verticalAlign: VerticalAlign.CENTER,
    shading: head ? { fill: ACCENT, type: ShadingType.CLEAR } : (shade ? { fill: shade, type: ShadingType.CLEAR } : undefined),
    margins: { top: 70, bottom: 70, left: 110, right: 110 },
    children: kids,
  });
}
function row(cells) { return new TableRow({ children: cells }); }

const CW = 9026; // content width A4 com margens de 1"

// ---------- conteúdo ----------
const children = [];

// ===== CAPA =====
children.push(
  new Paragraph({ spacing: { before: 1000, after: 0 }, alignment: AlignmentType.CENTER,
    children: [new TextRun({ text: "RELATÓRIO DE SEGURANÇA DA INFORMAÇÃO", bold: true, size: 40, color: ACCENT })] }),
  new Paragraph({ spacing: { before: 80, after: 0 }, alignment: AlignmentType.CENTER,
    children: [new TextRun({ text: "E CONFORMIDADE LEGAL", bold: true, size: 40, color: ACCENT })] }),
  new Paragraph({ spacing: { before: 360, after: 0 }, alignment: AlignmentType.CENTER,
    children: [new TextRun({ text: "Sistema Central Impulse One", size: 30, color: "333333" })] }),
  // Bloco formal De / Para / Assunto
  new Table({
    alignment: AlignmentType.CENTER,
    width: { size: 7400, type: WidthType.DXA },
    columnWidths: [1700, 5700],
    rows: [
      new TableRow({ children: [
        new TableCell({ borders: { top: bd, bottom: bd, left: bd, right: bd }, width: { size: 1700, type: WidthType.DXA },
          shading: { fill: "F2F2F2", type: ShadingType.CLEAR }, margins: { top: 70, bottom: 70, left: 120, right: 120 },
          children: [new Paragraph({ spacing: { after: 0 }, children: [new TextRun({ text: "De:", bold: true, size: 20, color: ACCENT })] })] }),
        new TableCell({ borders: { top: bd, bottom: bd, left: bd, right: bd }, width: { size: 5700, type: WidthType.DXA },
          margins: { top: 70, bottom: 70, left: 120, right: 120 },
          children: [new Paragraph({ spacing: { after: 0 }, children: [new TextRun({ text: "O Patrício", size: 20, color: "222222" })] })] }),
      ] }),
      new TableRow({ children: [
        new TableCell({ borders: { top: bd, bottom: bd, left: bd, right: bd }, width: { size: 1700, type: WidthType.DXA },
          shading: { fill: "F2F2F2", type: ShadingType.CLEAR }, margins: { top: 70, bottom: 70, left: 120, right: 120 },
          children: [new Paragraph({ spacing: { after: 0 }, children: [new TextRun({ text: "Para:", bold: true, size: 20, color: ACCENT })] })] }),
        new TableCell({ borders: { top: bd, bottom: bd, left: bd, right: bd }, width: { size: 5700, type: WidthType.DXA },
          margins: { top: 70, bottom: 70, left: 120, right: 120 },
          children: [new Paragraph({ spacing: { after: 0 }, children: [new TextRun({ text: "Impulse One Aceleradora de Negócios", size: 20, color: "222222" })] })] }),
      ] }),
      new TableRow({ children: [
        new TableCell({ borders: { top: bd, bottom: bd, left: bd, right: bd }, width: { size: 1700, type: WidthType.DXA },
          shading: { fill: "F2F2F2", type: ShadingType.CLEAR }, margins: { top: 70, bottom: 70, left: 120, right: 120 },
          children: [new Paragraph({ spacing: { after: 0 }, children: [new TextRun({ text: "Assunto:", bold: true, size: 20, color: ACCENT })] })] }),
        new TableCell({ borders: { top: bd, bottom: bd, left: bd, right: bd }, width: { size: 5700, type: WidthType.DXA },
          margins: { top: 70, bottom: 70, left: 120, right: 120 },
          children: [new Paragraph({ spacing: { after: 0 }, children: [new TextRun({ text: "Segurança da informação e conformidade legal do sistema Central Impulse One", size: 20, color: "222222" })] })] }),
      ] }),
    ],
  }),
  new Paragraph({ spacing: { before: 500, after: 0 }, alignment: AlignmentType.CENTER,
    border: { top: { style: BorderStyle.SINGLE, size: 8, color: ACCENT, space: 6 },
              bottom: { style: BorderStyle.SINGLE, size: 8, color: ACCENT, space: 6 } },
    children: [new TextRun({ text: "  Documento técnico-jurídico de demonstração das medidas de segurança da informação e de conformidade com a legislação brasileira de proteção de dados  ", size: 20, italics: true, color: GREY })] }),
  new Paragraph({ spacing: { before: 800, after: 0 }, alignment: AlignmentType.CENTER,
    children: [new TextRun({ text: "Impulse", bold: true, size: 26, color: ACCENT })] }),
  new Paragraph({ spacing: { before: 40, after: 0 }, alignment: AlignmentType.CENTER,
    children: [new TextRun({ text: "Junho de 2026  ·  Versão 1.0", size: 20, color: GREY })] }),
  new Paragraph({ spacing: { before: 40, after: 0 }, alignment: AlignmentType.CENTER,
    children: [new TextRun({ text: "Documento confidencial", size: 18, color: GREY, italics: true })] }),
  new Paragraph({ children: [new PageBreak()] }),
);

// ===== 1. APRESENTAÇÃO =====
children.push(H1("1. Apresentação e objetivo"));
children.push(P("O presente documento tem por finalidade descrever, de forma técnica e fundamentada, as medidas de segurança da informação adotadas pelo sistema de gestão Central Impulse One, bem como demonstrar a sua aderência aos princípios e exigências da legislação brasileira de proteção de dados pessoais — em especial a Lei Geral de Proteção de Dados Pessoais (Lei nº 13.709/2018) e o Marco Civil da Internet (Lei nº 12.965/2014)."));
children.push(P("O objetivo é oferecer a clientes, parceiros e demais partes interessadas a segurança jurídica e técnica de que as informações corporativas e os dados pessoais armazenados no sistema são tratados em ambiente protegido, criptografado e em conformidade com as boas práticas de mercado e com a lei aplicável."));
children.push(P([{ t: "Importante: ", b: true }, { t: "este documento descreve a arquitetura de segurança do sistema e as garantias contratuais e certificações de seus provedores de infraestrutura. As certificações citadas foram consultadas em fontes oficiais em junho de 2026; recomenda-se confirmar a versão vigente de cada certificação e dos respectivos termos contratuais no momento da contratação." }]));

// ===== 2. SUMÁRIO EXECUTIVO =====
children.push(H1("2. Sumário executivo"));
children.push(P("O Central Impulse One é uma aplicação web (software como serviço — SaaS) sustentada por dois provedores de infraestrutura de nuvem reconhecidos internacionalmente e auditados por terceiros independentes:"));
children.push(bullet([{ t: "Vercel", b: true }, { t: " — responsável pela hospedagem e entrega da aplicação web, com certificações SOC 2 Type 2 e ISO 27001:2022 e tráfego servido exclusivamente por HTTPS/TLS;" }]));
children.push(bullet([{ t: "Supabase", b: true }, { t: " — responsável pelo banco de dados (PostgreSQL), pela autenticação dos usuários e pelo armazenamento de arquivos, com certificações SOC 2 Type II e ISO 27001, criptografia AES-256 em repouso e disponibilidade de região no Brasil (São Paulo)." }]));
children.push(P("Em síntese, o sistema é seguro porque combina, em todas as camadas, criptografia da informação (em trânsito e em repouso), autenticação robusta de identidade, controle de acesso aos dados, rotinas de backup e recuperação, proteção contra ataques de rede e infraestrutura certificada — atendendo aos princípios de segurança e de prevenção exigidos pela LGPD (art. 6º, incisos VII e VIII) e ao dever de adoção de medidas técnicas e administrativas de proteção (art. 46)."));

// ===== 3. ARQUITETURA =====
children.push(H1("3. Visão geral da arquitetura do sistema"));
children.push(P("A arquitetura do Central Impulse One foi concebida sob o princípio de segurança desde a concepção (security by design), separando claramente a camada de apresentação (aplicação web) da camada de dados (banco de dados gerenciado), e mantendo toda a comunicação entre o usuário e o sistema sob criptografia."));

children.push(H2("3.1. Camada de aplicação — Vercel"));
children.push(P("A interface do sistema é entregue ao usuário por meio da plataforma Vercel, especializada na hospedagem de aplicações web sobre uma rede de borda (edge) global e distribuída, com computação executada predominantemente sobre infraestrutura de nuvem da Amazon Web Services (AWS). Esse modelo proporciona alta disponibilidade, desempenho e isolamento do ambiente de produção."));

children.push(H2("3.2. Camada de dados, autenticação e arquivos — Supabase"));
children.push(P("As informações do sistema são armazenadas em um banco de dados PostgreSQL gerenciado pela Supabase. A mesma plataforma é responsável pela autenticação dos usuários (login com e-mail e senha) e pelo armazenamento de arquivos (documentos, briefings e anexos), organizados em compartimentos de armazenamento (buckets) segregados por finalidade."));

children.push(H2("3.3. Comunicação criptografada (HTTPS/TLS)"));
children.push(P("Toda a comunicação entre o navegador do usuário e o sistema trafega exclusivamente por HTTPS, com criptografia TLS (Transport Layer Security). Isso significa que os dados não circulam em texto aberto pela internet: são cifrados de ponta a ponta entre o dispositivo do usuário e os servidores, impedindo a interceptação por terceiros."));

// ===== 4. INFRAESTRUTURA E FORNECEDORES =====
children.push(H1("4. Infraestrutura e fornecedores de nuvem"));
children.push(P("A segurança de um sistema em nuvem depende, em grande medida, da maturidade de segurança de seus provedores de infraestrutura. Ambos os fornecedores utilizados pelo Central Impulse One mantêm programas de segurança auditados por entidades independentes e disponibilizam certificações e instrumentos contratuais de proteção de dados."));

children.push(H2("4.1. Vercel — hospedagem da aplicação"));
children.push(bullet([{ t: "Certificações: ", b: true }, { t: "atestação SOC 2 Type 2 (critérios de Segurança, Confidencialidade e Disponibilidade), certificação ISO/IEC 27001:2022 (auditada por terceiro independente) e conformidade PCI DSS v4.0." }]));
children.push(bullet([{ t: "Criptografia: ", b: true }, { t: "HTTPS obrigatório com TLS 1.2/1.3, redirecionamento automático de HTTP para HTTPS, cabeçalho HSTS e criptografia AES-256 dos dados em repouso." }]));
children.push(bullet([{ t: "Proteção de rede: ", b: true }, { t: "mitigação automática de ataques de negação de serviço (DDoS) nas camadas de rede e de aplicação, e Web Application Firewall (WAF) com regras de bloqueio, limitação de taxa e modo de defesa contra ataques." }]));
children.push(bullet([{ t: "Resiliência: ", b: true }, { t: "rede de borda global com roteamento automático para o ponto disponível mais próximo em caso de indisponibilidade regional, e rotinas de backup com replicação para recuperação de desastres." }]));
children.push(bullet([{ t: "Conformidade contratual: ", b: true }, { t: "disponibiliza Acordo de Tratamento de Dados (Data Processing Addendum — DPA) público, com Cláusulas Contratuais Padrão para transferências internacionais, em conformidade com o GDPR europeu." }]));

children.push(H2("4.2. Supabase — banco de dados, autenticação e arquivos"));
children.push(bullet([{ t: "Certificações: ", b: true }, { t: "certificada SOC 2 Type II e ISO/IEC 27001, com controles auditados por terceiros." }]));
children.push(bullet([{ t: "Criptografia: ", b: true }, { t: "todos os dados são criptografados em repouso com AES-256 (incluindo banco, índices, registros de transação, backups e arquivos do Storage) e em trânsito por TLS. Informações especialmente sensíveis recebem ainda camada adicional de criptografia em nível de aplicação." }]));
children.push(bullet([{ t: "Infraestrutura e residência de dados: ", b: true }, { t: "hospedada sobre a Amazon Web Services (AWS), com possibilidade de provisionamento na região da América do Sul — São Paulo, Brasil (sa-east-1) —, permitindo manter os dados em território nacional." }]));
children.push(bullet([{ t: "Backups e recuperação: ", b: true }, { t: "backups diários automáticos e recurso de recuperação a um ponto no tempo (Point-in-Time Recovery — PITR), conforme o plano contratado, sempre criptografados em repouso." }]));
children.push(bullet([{ t: "Conformidade contratual: ", b: true }, { t: "disponibiliza Acordo de Tratamento de Dados (DPA) formal, atuando como operador dos dados, e mantém Política de Privacidade pública." }]));

children.push(P("O quadro a seguir resume as principais garantias de cada provedor:", { before: 80 }));

// Tabela de certificações
children.push(new Table({
  width: { size: CW, type: WidthType.DXA },
  columnWidths: [1900, 2300, 4826],
  rows: [
    row([cell("Fornecedor", 1900, { head: true }), cell("Função no sistema", 2300, { head: true }), cell("Certificações e garantias de segurança", 4826, { head: true })]),
    row([
      cell("Vercel", 1900, { shade: "F2F2F2" }),
      cell("Hospedagem e entrega da aplicação web (edge)", 2300),
      cell("SOC 2 Type 2; ISO 27001:2022; PCI DSS v4.0; HTTPS/TLS obrigatório; HSTS; AES-256 em repouso; mitigação de DDoS e WAF; DPA com cláusulas contratuais padrão.", 4826),
    ]),
    row([
      cell("Supabase", 1900, { shade: "F2F2F2" }),
      cell("Banco de dados PostgreSQL, autenticação e arquivos", 2300),
      cell("SOC 2 Type II; ISO 27001; AES-256 em repouso; TLS em trânsito; backups diários e PITR; região no Brasil (São Paulo); autenticação gerenciada (senhas com hash) e DPA.", 4826),
    ]),
  ],
}));
children.push(P("", { after: 60 }));

// ===== 5. CAMADAS DE SEGURANÇA =====
children.push(H1("5. Camadas de segurança da informação"));
children.push(P("A proteção dos dados no Central Impulse One não depende de um único mecanismo, mas de múltiplas camadas complementares (defesa em profundidade), descritas a seguir."));

children.push(H2("5.1. Criptografia em trânsito"));
children.push(P("Toda a comunicação ocorre por HTTPS com TLS 1.2/1.3. As requisições em HTTP são automaticamente redirecionadas para HTTPS, e o cabeçalho de segurança HSTS instrui o navegador a utilizar somente conexões cifradas. Dessa forma, nenhum dado — credenciais, informações de clientes ou documentos — trafega de forma legível pela rede."));

children.push(H2("5.2. Criptografia em repouso"));
children.push(P("Os dados armazenados em disco são cifrados com o algoritmo AES-256, padrão de mercado para criptografia simétrica, fornecido pela infraestrutura de nuvem subjacente (AWS) e mantido ativo de forma permanente. A criptografia abrange o banco de dados, os backups e os arquivos enviados ao sistema."));

children.push(H2("5.3. Autenticação e gestão de identidade"));
children.push(P("O acesso ao sistema exige autenticação individual por e-mail e senha, gerida pelo serviço de autenticação da Supabase. As senhas nunca são armazenadas em texto aberto: são protegidas por função de hash criptográfico (bcrypt) com salt aleatório, de modo que sequer o operador da infraestrutura tem acesso à senha original. Cada sessão autenticada é representada por um token de acesso assinado criptograficamente (JSON Web Token — JWT), de curta duração e renovado automaticamente enquanto a sessão permanece ativa. A plataforma oferece, ainda, a possibilidade de autenticação multifator (MFA) para reforço das contas."));

children.push(H2("5.4. Controle de acesso aos dados"));
children.push(P("O controle de acesso apoia-se em três níveis complementares: (i) autenticação obrigatória para qualquer operação; (ii) segregação de funções na própria aplicação, com perfis de acesso distintos conforme o papel do usuário (por exemplo, restrição de informações financeiras e gerenciais a perfis de gestão); e (iii) o mecanismo nativo de Segurança em Nível de Linha (Row Level Security — RLS) do PostgreSQL, que permite restringir, no próprio banco de dados, quais registros cada usuário pode acessar. A aplicação utiliza, no lado do cliente, exclusivamente a chave pública de acesso (anon key), mantendo as credenciais privilegiadas restritas ao ambiente protegido."));

children.push(H2("5.5. Armazenamento de arquivos"));
children.push(P("Os documentos e anexos são mantidos em compartimentos de armazenamento (buckets) segregados por finalidade, sujeitos à mesma criptografia em repouso e às políticas de acesso da plataforma. A organização por finalidade reduz a superfície de exposição e facilita a governança sobre o ciclo de vida dos arquivos."));

children.push(H2("5.6. Backups e continuidade do serviço"));
children.push(P("A resiliência é assegurada por rotinas automáticas de backup do banco de dados (diárias e, conforme o plano, com recuperação a um ponto no tempo), igualmente criptografadas, e pela replicação da infraestrutura em nuvem. Esses mecanismos protegem contra perda acidental de dados e viabilizam a recuperação em caso de incidente, atendendo ao princípio da prevenção (LGPD, art. 6º, VIII)."));

children.push(H2("5.7. Proteção de rede e da aplicação"));
children.push(P("Na camada de entrega, a plataforma de hospedagem aplica mitigação automática de ataques de negação de serviço (DDoS) e dispõe de Web Application Firewall (WAF), capaz de bloquear tráfego malicioso e limitar abusos antes que alcancem a aplicação."));

// ===== 6. CONFORMIDADE LEGAL =====
children.push(H1("6. Conformidade com a legislação brasileira"));
children.push(P("A arquitetura de segurança descrita acima não é apenas uma boa prática de mercado: ela materializa deveres legais previstos no ordenamento jurídico brasileiro. Nos termos da LGPD, os dados cadastrais de clientes e colaboradores armazenados no sistema (nome, e-mail, contatos, entre outros) constituem dados pessoais (art. 5º, I), e todas as operações de coleta, armazenamento e consulta configuram tratamento (art. 5º, X)."));

children.push(H2("6.1. Papéis e responsabilidades"));
children.push(P("A empresa que utiliza o Central Impulse One e decide quais dados serão tratados e para quais finalidades é a controladora dos dados (art. 5º, VI). Os provedores de infraestrutura (Supabase e Vercel, e a AWS por detrás deles) atuam como operadores/suboperadores, tratando os dados em nome e segundo as instruções do controlador (art. 5º, VII). Essa cadeia de responsabilidade é formalizada pelos Acordos de Tratamento de Dados (DPA) disponibilizados por cada provedor."));

children.push(H2("6.2. Princípio da segurança e dever de proteção (LGPD)"));
children.push(P("O art. 6º, VII, da LGPD estabelece o princípio da segurança nos seguintes termos:"));
children.push(quote("“VII — segurança: utilização de medidas técnicas e administrativas aptas a proteger os dados pessoais de acessos não autorizados e de situações acidentais ou ilícitas de destruição, perda, alteração, comunicação ou difusão.”"));
children.push(P("Esse dever é reforçado pelo art. 46, que exige a adoção de medidas técnicas e administrativas de segurança, observadas “desde a fase de concepção do produto ou do serviço até a sua execução” (§ 2º). As medidas descritas neste documento — criptografia em trânsito e em repouso, autenticação com hash de senha, controle de acesso e backups — constituem precisamente as medidas técnicas exigidas pelo dispositivo."));
children.push(P("O art. 47, por sua vez, determina que a segurança da informação seja garantida “mesmo após o término do tratamento”, fundamentando as políticas de retenção, confidencialidade e eliminação segura de dados. E o art. 49 exige que os próprios sistemas sejam “estruturados de forma a atender aos requisitos de segurança, aos padrões de boas práticas e de governança” — requisito atendido pela escolha de provedores certificados (SOC 2 Type II e ISO 27001)."));

children.push(H2("6.3. Comunicação de incidentes e a ANPD"));
children.push(P("O art. 48 da LGPD impõe ao controlador o dever de comunicar à Autoridade Nacional de Proteção de Dados (ANPD) — autoridade competente criada pelo art. 55-A da Lei — e aos titulares a ocorrência de incidente de segurança que possa acarretar risco ou dano relevante. O monitoramento contínuo da infraestrutura e os registros de atividade (logs) das plataformas subsidiam a detecção e a resposta a eventuais incidentes, em apoio a esse dever legal."));

children.push(H2("6.4. Transferência internacional de dados (art. 33)"));
children.push(P("Por se tratar de infraestrutura em nuvem, parte do tratamento pode ocorrer em data centers localizados fora do Brasil, o que configura transferência internacional de dados, disciplinada pelo art. 33 da LGPD. Esse ponto é tratado de forma transparente neste documento:"));
children.push(bullet([{ t: "Banco de dados (Supabase): ", b: true }, { t: "pode ser provisionado na região de São Paulo (Brasil), hipótese em que os dados permanecem em território nacional, eliminando a transferência internacional quanto ao armazenamento principal." }]));
children.push(bullet([{ t: "Hospedagem da aplicação (Vercel): ", b: true }, { t: "tem processamento primário nos Estados Unidos. A licitude dessa transferência ampara-se nas garantias contratuais oferecidas pelo provedor (cláusulas contratuais para transferência internacional, integradas ao DPA), na forma admitida pelo art. 33, II." }]));
children.push(P([{ t: "Observação de conformidade: ", b: true }, { t: "a ANPD editou, em 2024, a Resolução CD/ANPD nº 19/2024, que aprova as cláusulas-padrão contratuais brasileiras para transferência internacional. Recomenda-se, na formalização dos contratos, alinhar os instrumentos dos provedores a esse marco regulatório e, quando aplicável, obter o consentimento específico e destacado do titular para o caráter internacional da operação (art. 33, VIII). A adoção da região de São Paulo para o banco de dados é a medida mais robusta para mitigar esse ponto." }]));

children.push(H2("6.5. Marco Civil da Internet e aplicação da lei brasileira"));
children.push(P("O Marco Civil da Internet (Lei nº 12.965/2014) assegura ao usuário a inviolabilidade e o sigilo de suas comunicações e dados armazenados (art. 7º), bem como o direito a informações claras sobre coleta e uso. De especial relevância, o art. 11 determina que, sempre que a coleta ou o tratamento ocorra em território nacional — ou os dados sejam de usuários no Brasil —, aplica-se obrigatoriamente a legislação brasileira, “ainda que as atividades sejam realizadas por pessoa jurídica sediada no exterior”. Ou seja: mesmo com infraestrutura internacional, o sistema e a empresa permanecem integralmente sujeitos à lei brasileira e a este regime de proteção."));

children.push(H2("6.6. Padrões técnicos de segurança (Decreto nº 8.771/2016)"));
children.push(P("Como referência de boas práticas, o art. 13 do Decreto nº 8.771/2016 — que regulamenta o Marco Civil — elenca diretrizes de segurança que encontram correspondência direta nas medidas do sistema: controle estrito de acesso com privilégios por usuário; mecanismos de autenticação (inclusive autenticação dupla); registro/inventário de acessos; e uso de criptografia para garantir a inviolabilidade dos dados. Tais diretrizes são contempladas, respectivamente, pelo controle de acesso e segregação de perfis, pela autenticação gerenciada com suporte a MFA, pelos registros de atividade das plataformas e pela criptografia TLS e AES-256."));

children.push(P("O quadro a seguir relaciona os principais dispositivos legais às medidas concretas do sistema:", { before: 80 }));

// Tabela legal
children.push(new Table({
  width: { size: CW, type: WidthType.DXA },
  columnWidths: [2600, 3213, 3213],
  rows: [
    row([cell("Dispositivo legal", 2600, { head: true }), cell("Exigência", 3213, { head: true }), cell("Como o Central Impulse One atende", 3213, { head: true })]),
    row([cell("LGPD, art. 6º, VII e VIII", 2600, { shade: "F2F2F2" }), cell("Segurança e prevenção no tratamento de dados.", 3213), cell("Criptografia em trânsito (TLS) e em repouso (AES-256), backups e monitoramento.", 3213)]),
    row([cell("LGPD, art. 46", 2600, { shade: "F2F2F2" }), cell("Medidas técnicas e administrativas, desde a concepção.", 3213), cell("Arquitetura security by design sobre provedores certificados; autenticação e controle de acesso.", 3213)]),
    row([cell("LGPD, art. 47", 2600, { shade: "F2F2F2" }), cell("Segurança mesmo após o término do tratamento.", 3213), cell("Políticas de confidencialidade, retenção e eliminação segura.", 3213)]),
    row([cell("LGPD, art. 48", 2600, { shade: "F2F2F2" }), cell("Comunicação de incidentes à ANPD e aos titulares.", 3213), cell("Monitoramento e logs das plataformas como apoio à detecção e resposta.", 3213)]),
    row([cell("LGPD, art. 49", 2600, { shade: "F2F2F2" }), cell("Sistemas estruturados conforme requisitos de segurança.", 3213), cell("Provedores com SOC 2 Type II e ISO 27001.", 3213)]),
    row([cell("LGPD, art. 33", 2600, { shade: "F2F2F2" }), cell("Transferência internacional apenas com garantias.", 3213), cell("Região Brasil (São Paulo) para o banco; cláusulas contratuais (DPA) para a hospedagem.", 3213)]),
    row([cell("Marco Civil, art. 11", 2600, { shade: "F2F2F2" }), cell("Aplicação da lei brasileira mesmo com infra no exterior.", 3213), cell("Conformidade integral com a legislação brasileira.", 3213)]),
    row([cell("Decreto 8.771/16, art. 13", 2600, { shade: "F2F2F2" }), cell("Controle de acesso, autenticação, registros e criptografia.", 3213), cell("RLS e perfis; MFA disponível; logs; TLS e AES-256.", 3213)]),
  ],
}));
children.push(P("", { after: 60 }));

// ===== 7. DOMÍNIO PRÓPRIO =====
children.push(H1("7. Hospedagem sob domínio próprio da Impulse"));
children.push(P("O sistema poderá ser disponibilizado sob domínio próprio da Impulse (por exemplo, app.impulse.com.br ou sistema.impulse.com.br), caso o domínio seja fornecido, sem prejuízo de qualquer medida de segurança aqui descrita. A plataforma de hospedagem provisiona automaticamente um certificado SSL/TLS para o domínio personalizado, após a validação dos registros de DNS, com renovação automática antes do vencimento. O tráfego entre os usuários e o sistema permanece criptografado, e a transição para o domínio próprio é transparente — reforçando, inclusive, a identidade institucional e a confiança percebida pelos usuários."));

// ===== 8. RESPONSABILIDADES E GOVERNANÇA =====
children.push(H1("8. Responsabilidades, governança e boas práticas"));
children.push(P("A segurança de um sistema de informação é uma responsabilidade compartilhada entre o provedor de infraestrutura e o controlador dos dados. Enquanto Vercel e Supabase garantem a segurança da infraestrutura (criptografia, certificações, disponibilidade e proteção de rede), cabe à Impulse, como controladora, observar as boas práticas de governança que completam o ciclo de conformidade:"));
children.push(bullet("Gestão criteriosa de credenciais e perfis de acesso, concedendo a cada usuário apenas os privilégios necessários (princípio do menor privilégio);"));
children.push(bullet("Ativação de autenticação multifator (MFA) nas contas administrativas das plataformas;"));
children.push(bullet("Manutenção de Política de Privacidade e Termos de Uso, informando titulares sobre coleta, finalidade e tratamento dos dados (Marco Civil, art. 7º, VIII);"));
children.push(bullet("Definição de política de retenção e eliminação de dados, em especial no encerramento de contratos (LGPD, art. 47);"));
children.push(bullet("Procedimento de resposta a incidentes, com fluxo de comunicação à ANPD e aos titulares (LGPD, art. 48);"));
children.push(bullet("Indicação de Encarregado pelo Tratamento de Dados (DPO) e canal de atendimento aos titulares, conforme a estrutura da empresa."));

// ===== 9. CONCLUSÃO =====
children.push(H1("9. Conclusão"));
children.push(P("O sistema Central Impulse One foi construído sobre uma base de infraestrutura segura, auditada e juridicamente amparada. A combinação de criptografia integral da informação (em trânsito e em repouso), autenticação robusta, controle de acesso, backups, proteção de rede e provedores certificados internacionalmente (SOC 2 Type II e ISO 27001) confere ao sistema um nível de segurança compatível com as exigências da Lei Geral de Proteção de Dados e do Marco Civil da Internet."));
children.push(P("Diante do exposto, conclui-se que é seguro e legalmente sustentável manter as informações corporativas e os dados pessoais sob a gestão do Central Impulse One, observadas pela controladora as boas práticas de governança indicadas neste documento. As medidas técnicas adotadas atendem ao princípio da segurança (LGPD, art. 6º, VII) e ao dever de proteção (art. 46), e a estrutura permanece integralmente submetida à legislação brasileira (Marco Civil, art. 11)."));

// ===== 10. REFERÊNCIAS =====
children.push(H1("10. Fontes oficiais consultadas"));
children.push(P("As informações técnicas e de conformidade deste documento foram consultadas, em junho de 2026, nas seguintes fontes oficiais:", { after: 100 }));
[
  "Lei nº 13.709/2018 (LGPD) — planalto.gov.br",
  "Lei nº 12.965/2014 (Marco Civil da Internet) — planalto.gov.br",
  "Decreto nº 8.771/2016 — planalto.gov.br",
  "Resolução CD/ANPD nº 19/2024 (cláusulas-padrão contratuais) — gov.br/anpd",
  "Central de Segurança e Conformidade da Vercel — vercel.com/docs/security",
  "Acordo de Tratamento de Dados (DPA) da Vercel — vercel.com/legal/dpa",
  "Central de Segurança da Supabase — supabase.com/security",
  "Documentação de regiões e backups da Supabase — supabase.com/docs",
].forEach(s => children.push(bullet(s)));

children.push(new Paragraph({ spacing: { before: 280, after: 0 },
  border: { top: { style: BorderStyle.SINGLE, size: 6, color: "BBBBBB", space: 8 } },
  children: [new TextRun({ text: "Nota metodológica: este documento descreve a arquitetura de segurança do sistema e as garantias dos provedores de infraestrutura, com base em fontes oficiais consultadas em junho de 2026. As certificações e os termos contratuais devem ser confirmados em sua versão vigente no momento da contratação. A efetividade das medidas depende, ainda, da correta configuração e da observância, pela controladora, das boas práticas de governança aqui indicadas.", italics: true, size: 18, color: GREY })] }));

// ---------- documento ----------
const doc = new Document({
  styles: {
    default: { document: { run: { font: "Arial", size: 22, color: "222222" } } },
    paragraphStyles: [
      { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 28, bold: true, font: "Arial", color: ACCENT },
        paragraph: { spacing: { before: 320, after: 160 }, outlineLevel: 0,
          border: { bottom: { style: BorderStyle.SINGLE, size: 6, color: ACCENT, space: 4 } } } },
      { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 24, bold: true, font: "Arial", color: "333333" },
        paragraph: { spacing: { before: 200, after: 100 }, outlineLevel: 1 } },
    ],
  },
  numbering: {
    config: [
      { reference: "bul", levels: [
        { level: 0, format: LevelFormat.BULLET, text: "•", alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 600, hanging: 280 } } } },
      ] },
    ],
  },
  sections: [{
    properties: {
      page: { size: { width: 11906, height: 16838 }, margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 } },
      titlePage: true,
    },
    headers: {
      first: new Header({ children: [new Paragraph({ children: [] })] }),
      default: new Header({ children: [new Paragraph({
        alignment: AlignmentType.RIGHT,
        spacing: { after: 0 },
        border: { bottom: { style: BorderStyle.SINGLE, size: 4, color: "CCCCCC", space: 4 } },
        children: [new TextRun({ text: "Relatório de Segurança e Conformidade — Central Impulse One", size: 16, color: GREY })],
      })] }),
    },
    footers: {
      first: new Footer({ children: [new Paragraph({ children: [] })] }),
      default: new Footer({ children: [new Paragraph({
        tabStops: [{ type: TabStopType.RIGHT, position: 9026 }],
        spacing: { before: 40 },
        border: { top: { style: BorderStyle.SINGLE, size: 4, color: "CCCCCC", space: 4 } },
        children: [
          new TextRun({ text: "Impulse · Documento confidencial", size: 16, color: GREY }),
          new TextRun({ text: "\tPágina ", size: 16, color: GREY }),
          new TextRun({ children: [PageNumber.CURRENT], size: 16, color: GREY }),
        ],
      })] }),
    },
    children,
  }],
});

const outDir = path.join("C:", "Users", "conta", "OneDrive", "Área de Trabalho", "IMPULSE-ONE", "documentos");
const out = path.join(outDir, "Relatorio_Seguranca_IMPULSE_ONE.docx");
Packer.toBuffer(doc).then(buffer => {
  fs.writeFileSync(out, buffer);
  console.log("OK ->", out, "(", Math.round(buffer.length / 1024), "KB )");
});
