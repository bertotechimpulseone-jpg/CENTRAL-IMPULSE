// Valida os blocos <script> inline do index.html: checa null-byte e compila cada bloco com new Function().
const fs = require('fs');
const path = require('path');
const file = path.join(__dirname, 'index.html');
const html = fs.readFileSync(file, 'utf8');

// 1) null-byte
const NUL = String.fromCharCode(0);
if (html.indexOf(NUL) !== -1) {
  console.error('FALHOU: null-byte encontrado no index.html (offset ' + html.indexOf(NUL) + ')');
  process.exit(1);
}

// 2) extrai blocos <script> (sem src) e compila cada um
const re = /<script\b([^>]*)>([\s\S]*?)<\/script>/gi;
let m, idx = 0, erros = 0;
while ((m = re.exec(html)) !== null) {
  const attrs = m[1] || '';
  if (/\bsrc\s*=/.test(attrs)) continue;        // script externo: pula
  if (/type\s*=\s*["']?(application\/json|text\/)/i.test(attrs)) continue; // não-JS
  idx++;
  const code = m[2];
  try {
    new Function(code);
  } catch (e) {
    erros++;
    const ate = html.slice(0, m.index).split('\n').length;
    console.error('Bloco ' + idx + ' (linha ~' + ate + '): ' + e.message);
  }
}
console.log('blocos ' + idx + ' erros ' + erros);
process.exit(erros ? 1 : 0);
