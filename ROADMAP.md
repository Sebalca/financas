# Finanças Pessoais — plano de versões

Estado: ✅ feito · 🔜 próxima · ⬜ por fazer

## Já feito
- ✅ **v0.1** Separadores (Simulador Salarial + Finanças) e publicação em `financas.frisk.pt` (Cloudflare Workers).
- ✅ **v0.2** Login opcional com as contas partilhadas da plataforma (`plataforma-core/auth.js`) e tabela `financas_dados` no Supabase.
- ✅ **v0.3** Layout das abas Início, Extratos, Rendimentos e Despesas; filtro global de período.
- ✅ **v0.4** Importação do CSV da CGD sem IA (validação de saldos, sem duplicados); categorias e referências do utilizador; regras automáticas (pré-definidas, editor, a partir de um movimento); coluna Observações; Pessoas (quem é) por identificadores TFI/TRF/MB WAY; previsto vs real.
- ✅ **v0.5 — Guardar na conta**
  1. Sincronizar movimentos, categorias, regras, pessoas e previstos com `financas_dados`.
  2. Ao entrar pela primeira vez, os dados do browser passam para a conta (ou juntam-se aos que lá estiverem).
  3. Conflitos entre dispositivos: fica a versão mais recente; cada movimento guarda a sua última edição; movimentos apagados não reaparecem.

## Próximas versões
- ✅ **v0.6 — Extratos mais completos**
  4. Movimentos à mão na conta 💵 Dinheiro, com saldo próprio (levantamentos entram, depósitos saem); linha marcada na tabela e editável (✏).
  5. Edição em massa: selecionar vários e mudar categoria/referência, quem é, observações, ou apagar.
  - Extra: modo claro/escuro (botão ao lado do email) e zoom a 85% no computador.
- 🔜 **v0.6.x — Outros bancos** (à medida que chegam os extratos)
  7. Leitores para outros bancos.
- ⬜ **Para mais tarde**
  6. Dividir um movimento por várias categorias.
  8. Importar o extrato mensal da CGD em PDF (meses antigos sem CSV).
- ✅ **v0.7 — Rendimentos**
  9. Recorrentes (uma linha por recibo) e pontuais, com adicionar/editar/apagar à mão.
  10. Leitura de recibos de vencimento em PDF sem IA (formato DUALPERI; pdf.js no browser, só os valores ficam guardados).
  11. Ligação automática ao movimento de entrada com o mesmo valor (transferência no banco, subsídio no cartão refeição) → categoria Rendimentos; escolha manual em ✏.
  12. Resumo anual por mês (bruto, subsídio em cartão, IRS, SS, outros descontos, líquido).
  - Extra: leitor genérico Excel/CSV (cartão refeição), com reordenação pelos saldos; categoria Rendimentos (fora das despesas).
  - Ajustes: 🔗 clicáveis (rendimento ↔ movimento), resumo anual com meses que abrem e filtro por entidade, "Compra:" passa para os detalhes, títulos da tabela de movimentos fixos, aba Previsões (estrutura).
- ⬜ **v0.8 — Início e análises**
  13. Previsto vs real por categoria e por mês, com alertas de desvio.
  14. Evolução do saldo e comparação com o mesmo mês do ano anterior.
  15. Relatório mensal/anual para imprimir ou exportar.
- ⬜ **v0.9 — Ligação ao Simulador**
  16. Usar os rendimentos reais no Simulador (Pessoas / Unipessoal).
  17. Guardar também os dados do Simulador na conta.
- ⬜ **v1.0 — Acabamentos**
  18. Otimização para telemóvel (tabelas em cartões, importar pela câmara/ficheiros do telefone).
  19. Cópia de segurança: exportar/importar tudo num ficheiro.
  20. Revisão de segurança do Supabase (incluindo avisos antigos de outros sites).

## O que é preciso da tua parte
- Extratos de exemplo de outros bancos (v0.6).
- Um recibo de vencimento em PDF (v0.7).
