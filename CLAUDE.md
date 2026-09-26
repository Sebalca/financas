# Instruções para o Claude — repositório `financas`

Site: financas.frisk.pt (Cloudflare Workers, assets em `public/`; cada push para `main` publica).
Responder sempre em português de Portugal, de forma concisa.

## Processo obrigatório em cada alteração

1. **Perguntar antes** de alterar ou começar uma versão (o Sebastião prefere clarificar primeiro).
2. **Ler `PATCH NOTES.md` → "Decisões fixas"** e confirmar que o pedido não contraria nenhuma.
   Se contrariar (ou uma versão nova do `ROADMAP.md` o fizer), **avisar e pedir confirmação antes de mexer**; se ele confirmar, atualizar a decisão.
3. Implementar.
4. **Correr os testes**: `NODE_PATH=$(npm root -g) node tests/regressao.cjs` — tem de dar 0 falhas.
   Uma falha = uma decisão fixa quebrada: corrigir, ou avisar se a mudança foi pedida (e então atualizar o teste e a decisão).
5. **Registar** no `PATCH NOTES.md` (nova entrada no topo do Histórico):
   - alteração pedida entre versões → letra seguinte (`v0.7h` → `v0.7i`);
   - nova versão do roadmap → `v0.8`, `v0.9`… (e marcar no `ROADMAP.md`).
   Se o pedido criar uma regra nova ("quero sempre…", "nunca…"), acrescentá-la às Decisões fixas e, se possível, um teste.
6. Atualizar `APP_VERSAO` em `public/financas.html`.
7. Commit + push para `main` (`git fetch && git rebase origin/main` antes); verificar o site publicado.

## Regras
- Nunca pôr no repositório extratos, recibos ou outros dados reais — os testes usam só `tests/fixtures` (fictícios).
- Nunca credenciais privadas no código (só a chave pública do Supabase, via `plataforma-core`).
- Dados do utilizador só dele (RLS em `financas_dados`); sites externos nunca recebem sessão.
