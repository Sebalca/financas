# Finanças Pessoais — plano de versões

Estado: ✅ feito · 🔜 próxima · ⬜ por fazer · 🔁 contínuo
Detalhe de cada alteração: ver `PATCH NOTES.md`.

---

## Já feito (v0.1 → v0.8b)
- ✅ **v0.1–v0.3** Separadores, publicação em `financas.frisk.pt`, login opcional com as contas da plataforma, layout das abas.
- ✅ **v0.4** Importação do CSV da CGD sem IA; categorias/referências; regras automáticas; Observações; Pessoas (quem é).
- ✅ **v0.5** Dados guardados na conta (Supabase) e sincronizados entre dispositivos.
- ✅ **v0.6** Movimentos em dinheiro, edição em massa, modo escuro, zoom.
- ✅ **v0.7** Rendimentos: recibos em PDF, ligação ao extrato, resumo anual; cartão refeição (Excel/CSV).
- ✅ **v0.7a–t** Ajustes: despesas por ano e modo Editar, reembolsos, dividir movimentos, menu da conta (definições, plano, onboarding básico, cópia de segurança), Início com mais caixas, filtros e títulos fixos, estado ao atualizar…

---

## Até à v1.0 — uso pessoal e família próxima

Ordem sugerida: primeiro garantir que os números estão certos (é a base de tudo), depois melhorar o que se usa todos os dias, e por fim o onboarding — que só vale a pena escrever quando o resto estiver estável.

- 🔁 **Pequenas alterações e correções** — ao longo de todas as versões (v0.8a, v0.8b…), sempre que aparecerem.
- 🔁 **Mais bancos** — à medida que chegarem extratos de exemplo (um leitor por banco, sem IA, com validação dos saldos). *Preciso de: um extrato de cada banco (CSV/Excel, ou PDF se não houver outro).*

- 🔜 **v0.8 — Validar os números do Início**
  1. ✅ (v0.8a) Painel "Como foi calculado" em cada caixa do Início: lista os movimentos que entram, os que ficam de fora e porquê (fora das contas, reembolso, entre contas, dividido).
  2. Reconciliação por conta e por mês: saldo inicial + entradas − saídas = saldo final do extrato (✓ ou ⚠ com a diferença).
  3. Verificação cruzada: Início = soma das Despesas = soma dos Extratos filtrados; Rendimentos ligados = entradas de Rendimentos.
  4. Alertas de dados em falta: meses sem extrato, recibos por ligar, movimentos por categorizar, saltos de saldo.
  5. Sessão de validação contigo com um mês real (**junho de 2026**) (conferir ao cêntimo) e registar o resultado nas decisões fixas.

- ⬜ **v0.9 — Melhorar a aba Despesas** *(definir contigo no início: o que falta hoje)*
  - Ideias: comparar com o mês anterior / média, top referências, fixas vs variáveis, previsto por mês (não só mensal × 12), alertas de desvio, gráfico por categoria ao longo do ano.

- ⬜ **v0.10 — Onboarding completo**
  - Passos com destaque nos botões reais, configuração inicial (banco, primeiro extrato, categorias base, primeiras regras), lista de tarefas com progresso, dicas na primeira visita a cada aba, dados de exemplo para experimentar.

- ⬜ **v1.0 — Lançamento para a família**
  - Revisão de segurança do Supabase (RLS, avisos antigos de outros sites) e da privacidade dos dados.
  - Contas separadas por pessoa (cada um vê só os seus dados); convite simples.
  - Teste no telemóvel, cópia de segurança verificada, lista de problemas conhecidos.

---

## Depois da v1.0

Ordem sugerida: do mais fácil (reaproveita o que já existe) para o mais complexo (precisa de mudanças no Supabase).

- ⬜ **v1.1 — Previsões** — despesas e rendimentos previstos (valor, data ou periodicidade), saldo previsto no fim do mês/ano, avisos antes de pagamentos grandes. Reaproveita o "previsto" das Despesas.
- ⬜ **v1.2 — Análise (Saúde financeira)** — taxa de poupança, fixas vs variáveis, fundo de emergência, evolução do saldo, comparação com o ano anterior, conselhos e relatório mensal/anual.
- ⬜ **v1.3 — Ligação ao Simulador** — usar os rendimentos reais no Simulador (Pessoas/Unipessoal) e guardar os dados do Simulador na conta.
- ⬜ **v1.4 — Aba Empresas** — contas e movimentos de empresa separados dos pessoais (mesmos extratos/regras), resultados da empresa e ligação ao que passa para a conta pessoal (salário, dividendos).
- ⬜ **v1.5 — Ligação entre contas (utilizadores)**
  - Usar regras de outros utilizadores (partilhar/importar um conjunto de regras).
  - Linhas do extrato partilhadas com outros utilizadores (ex.: despesas da casa divididas), com permissões explícitas.
  - Requer tabelas novas no Supabase e regras de acesso (RLS) — é a parte mais complexa.
- ⬜ **v1.6 — Acabamentos** — desempenho com muitos anos de dados, acessibilidade, idioma, ajuda completa, enviar sugestão, polimento geral.

## Ideias em espera
- Faturas: ler faturas (PDF/foto), extrair loja, NIF, linhas e preços, e ligar ao movimento do extrato (aba já criada).
- Importar o extrato mensal da CGD em PDF (meses antigos sem CSV).
