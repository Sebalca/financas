# Finanças Pessoais — plano de versões

Estado: ✅ feito · 🔜 próxima · ⬜ por fazer · 🔁 contínuo
Detalhe de cada alteração: ver `PATCH NOTES.md`.

---

## Já feito (v0.1 → v0.10c)
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
- 🔁 **Mais bancos** — à medida que chegarem extratos de exemplo (um leitor por banco, sem IA, com validação dos saldos). Já lidos: CGD (CSV), Millennium BCP (Excel, conta e cartão), BPI (Excel), cartão refeição (Excel/CSV). *Preciso de: um extrato de cada banco (CSV/Excel, ou PDF se não houver outro).*

- 🔜 **v0.8 — Validar os números do Início**
  1. ✅ (v0.8a) Painel "Como foi calculado" em cada caixa do Início: lista os movimentos que entram, os que ficam de fora e porquê (fora das contas, reembolso, entre contas, dividido).
  2. Reconciliação por conta e por mês: saldo inicial + entradas − saídas = saldo final do extrato (✓ ou ⚠ com a diferença).
  3. Verificação cruzada: Início = soma das Despesas = soma dos Extratos filtrados; Rendimentos ligados = entradas de Rendimentos.
  4. Alertas de dados em falta: meses sem extrato, recibos por ligar, movimentos por categorizar, saltos de saldo.
  5. Sessão de validação contigo com um mês real (**junho de 2026**) (conferir ao cêntimo) e registar o resultado nas decisões fixas.

- ✅ **v0.9 — Tipos de despesa, Previsões e Agregado familiar**
  1. ✅ (v0.9a) Tipos de despesa por referência (Fixas/Variáveis essenciais/não essenciais, Extras), editáveis nas Definições; agrupar Despesas por tipo; caixa no Início.
  2. ✅ (v0.9b) Previsões: últimos 3 anos (a partir do mês de início) com total e média/mês (ano atual ÷ meses passados); previsão guardada por ano, escrita como média/mês ou total do ano; ano novo copia a previsão anterior; totais por tipo.
  3. ✅ (v0.9c) Agregado no Supabase: `agregados`, `agregado_membros` (dono/editor), `agregado_convites` (por email; conta tem de existir), `agregado_dados`; RLS só para membros; apagar guarda 30 dias; reutilizável por outros sites.
  4. ✅ (v0.9d) Seletor "Pessoal / Família" na barra de cima; ao criar copia categorias e regras; gravação com número de versão + junção quando duas pessoas gravam.

- 🔄 **v0.10 — Onboarding completo + melhorias** *(v0.8g já trouxe a visita guiada por aba, Novidades e FAQs)*
  1. ✅ (v0.10a) Assistente da 1.ª vez: idioma/tema → 1.º mês do ano → 1.º extrato (ou conta de exemplo) → rever categorias → regras sugeridas → visita guiada opcional. Conta 🧪 Exemplo à parte, só no browser, apagável com um clique.
  2. ✅ (v0.10b) "Primeiros passos" no Início, dicas na 1.ª visita a cada aba, ajuda ⓘ nas caixas.
  3. ✅ (v0.10c) Telemóvel; "banco não suportado" (explicar + enviar ficheiro anonimizado pelas Sugestões).
  4. ⬜ (v0.10d) RGPD (exportar dados, apagar conta, página de privacidade) e segurança do Supabase.

- ⬜ **v1.0 — Lançamento para a família**
  - Revisão de segurança do Supabase (RLS, avisos antigos de outros sites) e da privacidade dos dados.
  - Contas separadas por pessoa (cada um vê só os seus dados); agregado familiar já na v0.9.
  - Teste no telemóvel, cópia de segurança verificada, lista de problemas conhecidos.

---

## Depois da v1.0

Ordem sugerida: do mais fácil (reaproveita o que já existe) para o mais complexo (precisa de mudanças no Supabase).

- ⬜ **v1.1 — Previsões (parte 2)** — rendimentos previstos, datas/periodicidade, saldo previsto no fim do mês/ano, avisos antes de pagamentos grandes (a parte das despesas previstas vem na v0.9b).
- ⬜ **v1.2 — Análise (Saúde financeira)** — taxa de poupança, fixas vs variáveis, fundo de emergência, evolução do saldo, comparação com o ano anterior, conselhos e relatório mensal/anual.
- ⬜ **v1.3 — Ligação ao Simulador** — usar os rendimentos reais no Simulador (Pessoas/Unipessoal) e guardar os dados do Simulador na conta.
- ⬜ **v1.4 — Aba Empresas** — contas e movimentos de empresa separados dos pessoais (mesmos extratos/regras), resultados da empresa e ligação ao que passa para a conta pessoal (salário, dividendos).
- ⬜ **v1.5 — Ligação entre contas (utilizadores)**
  - Usar regras de outros utilizadores (partilhar/importar um conjunto de regras).
  - Linhas do extrato partilhadas com outros utilizadores (ex.: despesas da casa divididas), com permissões explícitas.
  - Requer tabelas novas no Supabase e regras de acesso (RLS) — é a parte mais complexa.
- ⬜ **v1.6 — Acabamentos** — desempenho com muitos anos de dados, acessibilidade, idioma, ajuda completa, enviar sugestão, polimento geral.

## Ideias em espera
- Objetivos (aba criada na v0.9f): metas com valor e prazo ligadas a uma categoria/referência, progresso automático e quanto pôr de parte por mês.
- Faturas: ler faturas (PDF/foto), extrair loja, NIF, linhas e preços, e ligar ao movimento do extrato (aba já criada).
- Importar o extrato mensal da CGD em PDF (meses antigos sem CSV).
