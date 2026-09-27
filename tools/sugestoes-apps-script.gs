/**
 * Finanças Pessoais — recebe as sugestões do site e escreve-as numa folha do Google Sheets.
 *
 * Como instalar (uma vez):
 *  1. Criar um Google Sheet novo (ex.: "Sugestões — Finanças Pessoais").
 *  2. Extensões › Apps Script. Apagar o código que lá está e colar este ficheiro todo. Guardar.
 *  3. Implementar › Nova implementação › tipo "Aplicação Web":
 *       - Executar como: Eu
 *       - Quem tem acesso: Qualquer pessoa
 *     Autorizar quando pedir. Copiar o URL que termina em /exec e enviá-lo para pôr no site.
 *  4. Para alterar o código depois: Implementar › Gerir implementações › editar › Versão: nova versão
 *     (assim o URL mantém-se).
 *
 * Não há credenciais aqui: o URL só permite ACRESCENTAR linhas a esta folha (não permite ler nada).
 */
const FOLHA = 'Sugestões';
const MAX_TEXTO = 4000;

function doPost(e) {
  try {
    const d = JSON.parse((e && e.postData && e.postData.contents) || '{}');
    if (d.site) return resposta({ ok: true });               // campo-armadilha para robôs: ignora em silêncio
    const texto = String(d.texto || '').trim().slice(0, MAX_TEXTO);
    if (texto.length < 3) return resposta({ ok: false, erro: 'Texto vazio' });

    // limite simples: no máximo 20 sugestões por minuto (todas as origens)
    const cache = CacheService.getScriptCache();
    const n = Number(cache.get('n') || 0);
    if (n >= 20) return resposta({ ok: false, erro: 'Demasiadas sugestões, tente daqui a um minuto' });
    cache.put('n', String(n + 1), 60);

    const ss = SpreadsheetApp.getActiveSpreadsheet();
    let sh = ss.getSheetByName(FOLHA);
    if (!sh) {
      sh = ss.insertSheet(FOLHA);
      sh.appendRow(['Data', 'Tipo', 'Sugestão', 'Email (se autorizou)', 'Separador', 'Versão', 'Browser', 'Estado']);
      sh.setFrozenRows(1);
      sh.getRange('A1:H1').setFontWeight('bold');
    }
    const limpa = v => String(v || '').replace(/^[=+\-@]/, "'$&").slice(0, 300); // evita fórmulas injetadas
    sh.appendRow([new Date(), limpa(d.tipo), texto.replace(/^[=+\-@]/, "'$&"), limpa(d.email), limpa(d.separador), limpa(d.versao), limpa(d.browser), 'Nova']);
    return resposta({ ok: true });
  } catch (err) {
    return resposta({ ok: false, erro: String(err) });
  }
}

function doGet() { return resposta({ ok: true, info: 'Sugestões — Finanças Pessoais' }); }

function resposta(o) {
  return ContentService.createTextOutput(JSON.stringify(o)).setMimeType(ContentService.MimeType.JSON);
}
