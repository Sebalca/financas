# PATCH NOTES — Finanças Pessoais

Numeração: **versões** do plano (`v0.5`, `v0.6`, … ver `ROADMAP.md`) e **alterações pedidas entre versões** com letra (`v0.7a`, `v0.7b`, …).
A versão atual aparece no topo do site (ao lado do subtítulo) e está em `APP_VERSAO` no `public/financas.html`.

---

## Decisões fixas (não contrariar sem avisar)

Regras que o Sebastião pediu explicitamente. Antes de qualquer alteração ou nova versão, confirmar que nada aqui é contrariado; se for preciso, **avisar primeiro e pedir confirmação**. Cada decisão com código `Dxx` tem teste em `tests/regressao.cjs`.

**Forma de trabalhar**
- Fazer perguntas antes de alterações ou de uma nova versão.
- Registar cada alteração neste ficheiro e subir a letra da versão.

**Geral / página principal**
- D40 Separadores por esta ordem: **Finanças**, Simulador Salarial, Bíblia financeira, Stock casa (os externos embutidos, com "↗ Abrir numa nova aba").
- D41 Sites externos nunca recebem a sessão nem o tema.
- D42 Menu no canto direito (avatar ▾ / ☰): Entrar/criar conta, Definições, Plano, Onboarding, Modo escuro, Ajuda, Enviar sugestão, Terminar sessão. Site a 85% em ecrãs largos (ajustável nas Definições); largura total da janela.
- D43 Onboarding aparece sozinho no 1.º login depois de criar a conta; pode ser relançado no menu e nas Definições.
- Definições: Tema e tamanho, Conta (mudar palavra-passe), Cópia de segurança (exportar/importar .json), Apagar dados (dispositivo / conta), Onboarding, Idioma, Ajuda, Enviar sugestão (os três últimos só visuais por agora).
- Login opcional; com sessão os dados sincronizam com a conta (Supabase `financas_dados`); nunca credenciais privadas no código.

**Extratos**
- D01 CGD (CSV) e cartão refeição (Excel/CSV genérico, conta "Cartão refeição") lidos sem IA.
- D02 "Compra" (e prefixos tipo "Pagamento:") sai do início da descrição e vai para Detalhes — em todas as contas.
- D04 Reimportar nunca duplica (chave pela descrição original).
- D05 **Por categorizar** = falta a categoria **ou** a referência.
- D07 Barra de pesquisa/filtros e títulos da tabela sempre visíveis; filtro de Referência que segue a Categoria.
- D08 Dropdowns dos filtros (Categoria, Referência…) com largura fixa.
- D09 Botão "✕ Limpar filtros".
- Detalhes sem "CGD:"; movimentos ligados mostram só o 🔗 nos Detalhes.
- Combos Categoria/Referência com largura fixa e seta à direita.
- Movimentos à mão = conta 💵 Dinheiro com saldo próprio.
- Regras: "contém" / "tem a palavra" / "começa por"; a primeira que corresponde ganha; nunca mexem nos movimentos classificados à mão.

**Despesas**
- D10 Fora das contas (tabela de baixo): **Banco, Por tratar, Investimentos, Empresas, Rendimentos, Poupanças**.
- D06 Trocas entre contas, levantamentos, depósitos e Poupanças não contam como entrada/saída.
- D12 Referências com ✓ "Só este movimento" não sugerem regra e as regras não as usam.
- D13 Vista Mês (previsto vs real) e vista Ano (grelha 12 meses + Total + Média/mês + Previsto ano), em duas tabelas com títulos.
- D14 Vista Ano, tabela "Não entram nas contas": uma linha por categoria com o saldo (entradas − saídas) por mês, Total e Média/mês; sem coluna "Entradas ano".
- Modo "✏ Editar" (nomes, ordem ↑↓, apagar, adicionar); "Abrir todas / Fechar todas".

**Rendimentos**
- D20 Cada rendimento liga-se sozinho ao movimento de entrada com o mesmo valor (−10 a +20 dias) e passa para a categoria Rendimentos.
- D22 A transferência procura-se no banco; o subsídio de refeição só na conta Cartão refeição.
- D21 Um só botão "＋ Adicionar rendimento" (+ "Carregar recibo (PDF)"); só o resumo anual (sem tabelas recorrentes/pontuais).
- Resumo anual: colunas Ordenado, Subs. Natal/Férias, Prémios/gratif., Outros rend., Subs. cartão, Bruto, IRS, SS, Outros desc., Líquido; meses fecham/abrem; linha do mês só mostra o que falta ligar; larguras fixas; filtro por entidade.
- Recibos: duplicados pelo n.º do recibo; só os valores ficam guardados (não o PDF).

**Início**
- D30 Caixas "Despesas por categoria" (clicável → Extratos filtrados) e "Rendimentos" (por entidade/tipo, líquido; clicável).
- D31 "Por categorizar" mostra só as descrições mais frequentes (⚡ criar regra); "Categorizar →" abre os Extratos filtrados.
- D34 No Início (totais, gráfico por mês, despesas por categoria/referência) as categorias fora das contas não contam — nem saídas nem entradas — **exceto as entradas de Rendimentos** (salário, etc.).
- D32 Caixa "Despesas por referência" (entre as despesas por categoria e os rendimentos), clicável → Extratos com categoria e referência.
- D33 "Entradas e saídas por mês": sempre os 12 meses do ano do período, mais largo que o "Saldo por banco"; opção Detalhado (cores por categoria / entidade).
- Poupanças: aparecem como "Poupanças - referência" em "Saldo por banco" e abrem os Extratos filtrados.

---

## Histórico

### v0.7k — 26/09/2026
- Início: entradas das categorias fora das contas também deixam de contar, exceto Rendimentos (D34 atualizada, confirmado).
- Despesas (vista Ano): "Não entram nas contas" passa a mostrar uma linha por categoria com entradas − saídas; sai a coluna "Entradas ano".

### v0.7j — 26/09/2026
- Início: saídas das categorias fora das contas (Banco, Por tratar, Investimentos, Empresas, Rendimentos, Poupanças) deixam de aparecer nas caixas Saídas/Saldo/Taxa de poupança, no gráfico por mês e nas despesas por categoria/referência.

### v0.7i — 26/09/2026
- Menu no canto direito (avatar ▾): Definições, Plano, Onboarding, Modo escuro, Ajuda, Enviar sugestão, Entrar/Terminar sessão — **substitui o botão de tema da barra (D42 alterada, confirmado)**.
- Definições: tema e tamanho, conta (palavra-passe), cópia de segurança, apagar dados, onboarding, idioma/ajuda/sugestão (visuais).
- Plano: Grátis (atual) + Pro/Família "em breve".
- Onboarding em 6 passos, automático no 1.º login após criar conta.
- Extratos: dropdowns dos filtros com largura fixa; "✕ Limpar filtros".
- Início: nova caixa "Despesas por referência"; "Por categorizar" só com as mais frequentes (**D31 alterada, confirmado**); Poupanças como "Poupanças - referência" e clicáveis; gráfico mais largo e baixo, sempre o ano todo, com opção Detalhado.

### v0.7h — 26/09/2026
- Criado este ficheiro (histórico reconstruído a partir dos commits) e a secção "Decisões fixas".
- Testes de regressão `tests/regressao.cjs` com dados fictícios (`tests/fixtures`).
- `CLAUDE.md` com o processo obrigatório para alterações.
- Versão visível no topo do site.

### v0.7g — 26/09/2026
- Finanças passa a ser o primeiro separador.
- Início: clicar numa categoria de despesa (ou entidade de rendimento) abre a lista filtrada.
- Extratos: filtro por Referência.
- Despesas: Empresas fora das contas; secções com títulos e afastadas; vista Ano com Média/mês; ✓ "Só este movimento" nas referências.
- Novas abas (só explicação): Faturas e Saúde financeira.

### v0.7f — 26/09/2026
- Início: "Por categorizar" com vistas Extrato / Mais frequentes (⚡ criar regra com escolha de categoria e referência).
- Início: caixa Rendimentos (por entidade / por tipo, líquido).

### v0.7e — 26/09/2026
- "Compra" retirado do início da descrição em todas as contas (também os já importados).

### v0.7d — 25/09/2026
- Extratos: filtros fixos; "Por categorizar" = sem categoria ou sem referência.
- Despesas: vista Ano (grelha 12 meses), modo Editar (ordem ↑↓), abrir/fechar todas, categorias fora das contas em baixo.
- Categoria Poupanças com saldo no Início; "Categorizar →" abre o filtro; rendimentos com um só botão.

### v0.7c — 25/09/2026
- Recibos do mesmo mês aceites (duplicados pelo n.º do recibo); subsídio de Natal/férias com coluna própria.

### v0.7b — 25/09/2026
- Rendimentos só no resumo anual (ordenado vs prémios separados, larguras fixas); barra para adicionar.
- Separadores externos Bíblia financeira e Stock casa.

### v0.7a — 25/09/2026
- 🔗 clicáveis entre rendimentos e movimentos; resumo anual com meses que abrem e filtro por entidade.
- "Compra:" do cartão para os Detalhes; títulos da tabela de movimentos fixos; aba Previsões (estrutura).

### v0.7 — 25/09/2026
- Rendimentos: recibos de vencimento em PDF (sem IA), recorrentes/pontuais, ligação automática ao extrato, resumo anual.
- Leitor do cartão refeição (Excel/CSV); categoria Rendimentos.

### v0.6 — 24/09/2026
- Movimentos à mão (conta Dinheiro), edição em massa, modo escuro, zoom 85%.

### v0.5a — 24/09/2026
- Importar numa só faixa; janelas com header fixo e ✕; largura total; detalhes sem "CGD:"; setas das combos à direita.

### v0.5 — 24/09/2026
- Dados guardados na conta (Supabase) e sincronizados entre dispositivos.

### v0.4a — 24/09/2026
- Regras de categorização, coluna Observações, Pessoas (quem é).

### v0.4 — 24/09/2026
- Importação do CSV da CGD sem IA.

### v0.3 — 24/09/2026
- Layout das abas Início, Extratos, Rendimentos, Despesas; deploy no Cloudflare.

### v0.2 — 24/09/2026
- Login opcional com as contas da plataforma; tabela `financas_dados`.

### v0.1 — 24/09/2026
- Separadores Simulador Salarial + Finanças.
