const AdmZip = require("adm-zip");
const path = require("path");
const f = path.join("C:", "Users", "conta", "OneDrive", "Área de Trabalho", "IMPULSE-ONE", "documentos", "Relatorio_Seguranca_IMPULSE_ONE.docx");
const zip = new AdmZip(f);
const entries = zip.getEntries().map(e => e.entryName);
const required = ["[Content_Types].xml", "_rels/.rels", "word/document.xml"];
const missing = required.filter(r => !entries.includes(r));
console.log("Partes obrigatórias presentes:", missing.length === 0 ? "SIM" : ("FALTANDO: " + missing.join(", ")));
console.log("Total de partes no pacote:", entries.length);

const xml = zip.readAsText("word/document.xml");
// well-formedness básico
const opens = (xml.match(/<w:p[ >]/g) || []).length;
const tbls = (xml.match(/<w:tbl>/g) || []).length;
const tblsC = (xml.match(/<\/w:tbl>/g) || []).length;
console.log("Parágrafos (<w:p>):", opens);
console.log("Tabelas:", tbls, "abrem /", tblsC, "fecham ->", tbls === tblsC ? "OK" : "DESBALANCEADO");
console.log("Começa com <?xml:", xml.startsWith("<?xml"));
console.log("Fecha </w:document>:", xml.trimEnd().endsWith("</w:document>"));

// extrai texto pra conferir acentuação e seções-chave
const text = xml.replace(/<[^>]+>/g, "").replace(/&#x([0-9A-Fa-f]+);/g, (m, h) => String.fromCodePoint(parseInt(h, 16)));
const marcos = [
  "RELATÓRIO DE SEGURANÇA",
  "Lei nº 13.709/2018",
  "Transferência internacional",
  "São Paulo",
  "AES-256",
  "Row Level Security",
  "Resolução CD/ANPD nº 19/2024",
  "domínio próprio da Impulse",
  "art. 6º, VII",
  "Conclusão",
];
console.log("\n— Marcos de conteúdo —");
marcos.forEach(m => console.log((text.includes(m) ? "✓" : "✗ FALTA") + "  " + m));
console.log("\nTamanho do texto extraído:", text.length, "caracteres");
