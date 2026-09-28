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
- D44 Sem subtítulo nas Finanças; a versão aparece no canto superior direito do menu da conta. O menu da conta fecha ao clicar em qualquer sítio fora dele.
- Definições: Tema e tamanho, Conta (mudar palavra-passe), Cópia de segurança (exportar/importar .json), Apagar dados (dispositivo / conta), Onboarding, Idioma, Ajuda, Enviar sugestão (os três últimos só visuais por agora).
- Login opcional; com sessão os dados sincronizam com a conta (Supabase `financas_dados`); nunca credenciais privadas no código.

- D52 Clicar na data abre um calendário: ano (‹ ›), "Ano inteiro" e os 12 meses; escolher um mês passa para o modo Mês.
- D73 O título "Finanças pessoais" (com o logo) fica só na barra de cima da página principal. O período (Mês/Ano/Intervalo, ‹ data ›, calendário), o estado "Guardado / Só neste browser" e o botão **Hoje** (vai para o mês/ano atual; no Intervalo: dia 1 deste mês até hoje; esbatido quando já está no período atual) ficam na barra de cima, entre os separadores e o menu da conta, e só aparecem no separador Finanças. Aberto sozinho (financas.html), o cabeçalho próprio continua a aparecer. (v0.8c)

- D66 🧮 "Como foi calculado": ícone pequeno no canto das caixas do Início, Despesas e Rendimentos; abre um **painel lateral à direita** com a fórmula, os movimentos que contam (a soma = valor da caixa) e os que ficaram de fora agrupados pelo motivo; clicar numa linha leva ao movimento/rendimento. (v0.8a)
- D67 O ícone 🧮 pode ser escondido em Definições › Geral › Opções (guardado no dispositivo).
- D68 Definições com menu vertical e janela de tamanho fixo (não muda ao trocar de secção); a primeira secção é "Geral" (tema, tamanho, idioma, ordem dos movimentos, opções que vamos acrescentando). (atualizada v0.8b) Logo (montanha/reflexo, fundo azul-escuro com cantos arredondados) no separador do browser e ao lado de "Finanças pessoais".

- D69 Tamanho: o padrão (100%) corresponde a 90% real, em computador e telemóvel; opções 80% · 90% · 100% · 110% · 120%. Tamanhos antigos guardados voltam ao padrão.
- D70 Ordem dos movimentos nos Extratos escolhida em Definições › Geral (mais recentes primeiro por defeito).
- D71 Janela "Reembolso": "Mostrar todas" lista as saídas até à data do reembolso, da mais recente para a mais antiga; o botão "Posteriores" (à esquerda da pesquisa) mostra as saídas depois dessa data.
- D72 Janela Dividir: valor da 1.ª linha fixo a cinzento; valores das outras linhas e observações a branco.

**Extratos**
- D01 CGD (CSV) e cartão refeição (Excel/CSV genérico, conta "Cartão refeição") lidos sem IA.
- D02 "Compra" (e prefixos tipo "Pagamento:") sai do início da descrição e vai para Detalhes — em todas as contas.
- D04 Reimportar nunca duplica (chave pela descrição original).
- D05 **Por categorizar** = falta a categoria **ou** a referência.
- D07 Barra de pesquisa/filtros e títulos da tabela sempre visíveis; filtro de Referência que segue a Categoria.
- D08 Dropdowns dos filtros (Categoria, Referência…) com largura fixa.
- D09 Botão "✕ Limpar filtros".
- D08b Tabela de movimentos com larguras de coluna fixas.
- D08c Títulos das colunas dentro da barra fixa (junto à pesquisa e filtros), sempre alinhados com as colunas; a barra de scroll vertical fica sempre reservada para a largura não mudar ao filtrar.
- D46 Valores com milhares sempre separados por espaço (1 234,56 €), em todo o site.
- D45 Ao atualizar a página mantém-se a aba, período, filtros, pesquisa, vistas e posição (só enquanto o separador do browser está aberto).
- Detalhes sem "CGD:"; movimentos ligados mostram só o 🔗 nos Detalhes.
- Combos Categoria/Referência com largura fixa e seta à direita.
- Movimentos à mão = conta 💵 Dinheiro com saldo próprio.
- Regras: "contém" / "tem a palavra" / "começa por"; a primeira que corresponde ganha; nunca mexem nos movimentos classificados à mão.

- D51 A janela Pessoas tem uma caixa de pesquisa fixa no topo que filtra as duas listas.

- D74 Filtro Entradas/Saídas com caixa branca e destacado a azul quando está ativo (como os outros filtros).
- D76 Janela Regras com a aba "⭐ Regras especiais": lista de regras com **nome** (editável), **tipo** e referências; ＋ Nova regra especial, 🗑 apagar, ＋/✕ referências. Tipos: **📌 Ao escolher estas referências** (não pede para criar regra e as regras automáticas não as usam — é o mesmo que o 📌 do modo Editar das Despesas) e **↪ Ao mudar a partir destas referências** (ao mudar a categoria/referência de uma linha que tinha uma delas, não pede para criar regra; a linha fica classificada à mão). (atualizada v0.8d)
- D77 Regras especiais criadas por defeito: "Só este movimento" (📌, com as referências já marcadas) e "Transferências" (↪, Por tratar › Transferência / Transferência rec / Transferência pag).

- D79 Sugestões (Definições › Enviar sugestão): tipo (Ideia/Problema/Outro), texto, email só se o utilizador marcar; vão para um Google Sheet através de uma Aplicação Web do Apps Script (`tools/sugestoes-apps-script.gs`). O URL /exec só permite acrescentar linhas (não é credencial); campo-armadilha anti-robôs e limite por minuto.

**Despesas**
- D10 Fora das contas (tabela de baixo): **Banco, Por tratar, Investimentos, Empresas, Rendimentos, Poupanças**.
- D06 Trocas entre contas, levantamentos, depósitos e Poupanças não contam como entrada/saída.
- D12 Referências com ✓ "Só este movimento" não sugerem regra e as regras não as usam.
- D13 Vista Mês (previsto vs real) e vista Ano (grelha 12 meses + Total + Média/mês + Previsto ano), em duas tabelas com títulos.
- D75 Linhas divididas: a **Descrição** de cada linha escreve-se na janela Dividir (aparece como ↳ descrição); as **Observações** escrevem-se na tabela, como nas outras linhas. (v0.8c)
- D18 Dividir movimento (✂): a linha do banco mantém-se e mostra "✂ Dividido em N" com sub-linhas; a soma das partes tem de dar o valor original; todas as contas usam as partes; as regras não mexem em movimentos divididos.
- D48 Ao dividir, a 1.ª linha tem o valor fechado = valor original − as outras linhas (não se edita nem se apaga). Se as outras linhas passarem o original, a 1.ª fica negativa (vermelho), aparece um aviso e não deixa guardar; fora disso não há texto de soma.
- D53 Janela Dividir: título com descrição · data · valor em destaque; explicação só no ⓘ ao lado do ✕; "＋ Linha" por baixo da coluna do valor.
- D54 Numa entrada dividida, cada linha pode ser reembolso de uma despesa: ↩ à direita de cada linha na janela Dividir e nas sub-linhas da tabela.
- D62 Extratos: sem o texto "Suportados…" na importação; no fundo da tabela só uma barra cinzenta fina (sem total); nas linhas divididas as Observações escrevem-se na própria linha; sem texto de exemplo nas observações da janela Dividir.
- D63 Filtros Categoria, Referência, Quem é e Banco com multiseleção (caixas de escolha, largura fixa); o Tipo continua simples.
- D55 Os botões do fim da linha do extrato têm lugares fixos, pela ordem ↩ reembolso, ✂ dividir, ✏ editar, 🗑 apagar, encostados à direita; quando um não se aplica, o lugar fica vazio. (atualizada v0.7r — antes ↩ ✏ ✂ 🗑)
- D56 Filtros dos Extratos: pesquisa, Tipo (entradas/saídas), Categoria, Referência, Quem é, Banco.
- D57 Um só botão "⚙ Regras e pessoas" (janela com as abas Regras | Pessoas) e um só "⇅ Importar/Exportar" (menu por baixo do botão: Exportar movimentos | Importações feitas). (atualizada v0.7t)
- D58 Movimentos apagados: a chave fica para sempre (não voltam a entrar ao reimportar); os dados completos dos últimos 50 ficam em ＋ Movimento › Movimentos eliminados, onde se podem repor. Exceção: os de uma importação removida (ou "Apagar todos") podem ser reimportados.
- D59 As janelas fecham ao clicar fora, mas não quando se carrega dentro e se larga fora (em todas as páginas).
- D60 Dividir: a explicação aparece numa etiqueta ao clicar no ⓘ (título "Como funciona" ao passar o rato), não dentro da janela.
- D49 As sub-linhas de um movimento dividido estão minimizadas por defeito (▸ mostra, ▾ esconde).
- D50 O reembolso (↩) pode ligar a uma linha de um movimento dividido; a ligação abre o movimento com as linhas visíveis.
- D47 A pesquisa dos Extratos aceita datas (dd/mm, dd/mm/aaaa, mm/aaaa) e procura na data mov. ou data valor, em todos os períodos.
- D19 Movimento marcado como reembolso mostra só "↩ Reembolso de …" nos Detalhes.
- D78 Um reembolso ligado mostra na Descrição "↩ nome da despesa original" (a descrição do extrato fica no tooltip) e a pesquisa encontra-o pelos dois nomes. (v0.8e)
- D20b Janela do reembolso: mostra em destaque descrição, valor, data e quem; por defeito as saídas (todas as categorias) do próprio dia ou do anterior mais próximo, com valor maior que o reembolso; "Mostrar todas" com pesquisa; despesa sem categoria → escolher categoria/referência na hora (aplica-se às duas).
- D17 Despesas: **Saídas** (antes "Real") = saídas − reembolsos; nas linhas chama-se **Total** (colunas Entradas e Saídas ao lado). (atualizada v0.7s)
- D61 Despesas, vista Mês: categorias abertas por defeito (lembra as que se fecham); colunas Referência | Previsto/mês | Média mensal (total dos últimos 12 meses ÷ meses com movimentos) | Entradas | Saídas | Total | Diferença; caixas como no Início (explicação só ao passar o rato); linhas mais baixas.
- D16 Nos Extratos, entradas têm o botão ↩ para escolher a despesa original (fica com a mesma categoria/referência e ligação ↩).
- D14 Vista Ano, tabela "Não entram nas contas": uma linha por categoria com o saldo (entradas − saídas) por mês, Total e Média/mês; sem coluna "Entradas ano".
- Modo "✏ Editar" (nomes, ordem ↑↓, apagar, adicionar); "Abrir todas / Fechar todas".

**Rendimentos**
- D20 Cada rendimento liga-se sozinho ao movimento de entrada com o mesmo valor (−10 a +20 dias) e passa para a categoria Rendimentos.
- D22 A transferência procura-se no banco; o subsídio de refeição só na conta Cartão refeição.
- D21 Um só botão "＋ Adicionar rendimento" (azul), dentro da caixa Resumo anual, com menu: 📎 Carregar recibo (PDF) em cima e ✏ Adicionar manualmente; só o resumo anual (sem tabelas recorrentes/pontuais). (atualizada v0.7t)
- D65 Caixas da aba Rendimentos como no Início (título/valor centrados, explicação só ao passar o rato).
- Resumo anual: colunas Ordenado, Subs. Natal/Férias, Prémios/gratif., Outros rend., Subs. cartão, Bruto, IRS, SS, Outros desc., Líquido; meses fecham/abrem; linha do mês só mostra o que falta ligar; larguras fixas; filtro por entidade.
- Recibos: duplicados pelo n.º do recibo; só os valores ficam guardados (não o PDF).

**Início**
- D30 Caixas "Despesas por categoria" (clicável → Extratos filtrados) e "Rendimentos".
- D64 Início: 4 caixas na mesma linha — Despesas por categoria, Despesas por referência, Rendimentos e Rendimentos por tipo. As de rendimentos vêm do **extrato** (entradas da categoria Rendimentos): Rendimentos por entidade, Por tipo pela referência (Salário, Prémios, Subsídios…); o que está ligado a um recibo aparece com ✓ e cor cheia, o resto esbatido "por confirmar". (v0.7t)
- D37 As 4 caixas do Início têm título e valor maiores e centrados; o texto explicativo só aparece ao passar o rato.
- D38 Clicar em Entradas/Saídas do Início abre os Extratos com o filtro Só entradas/Só saídas.
- D31 "Por categorizar" mostra só as descrições mais frequentes (⚡ criar regra); "Categorizar →" abre os Extratos filtrados.
- D36 "Por categorizar" mostra todas as descrições (com scroll), não só as 10 primeiras.
- D34 No Início (totais, gráfico por mês, despesas por categoria/referência) as categorias fora das contas não contam — nem saídas nem entradas — **exceto as entradas de Rendimentos** (salário, etc.).
- D15 Entrada numa categoria de despesa = **reembolso**: abate à despesa dessa categoria/referência e não conta como entrada. Entradas = Rendimentos + por categorizar.
- D32 Caixa "Despesas por referência" (entre as despesas por categoria e os rendimentos), clicável → Extratos com categoria e referência.
- D33 "Entradas e saídas por mês": sempre os 12 meses do ano do período, mais largo que o "Saldo por banco"; opção Detalhado (cores por categoria / entidade).
- Poupanças: aparecem como "Poupanças - referência" em "Saldo por banco" e abrem os Extratos filtrados.

---

## Histórico

### v0.8f — 28/09/2026
- Sugestões ativas: o formulário envia para o Google Sheet (URL da Aplicação Web do Apps Script configurado).

### v0.8e — 27/09/2026
- Extratos: reembolsos ligados mostram o nome da despesa original na Descrição.
- Sugestões: formulário ativo em Definições › Enviar sugestão, pronto para enviar para um Google Sheet (falta o URL do Apps Script).

### v0.8d — 27/09/2026
- Regras especiais passam a ter nome e tipo (lista de regras). Criadas: "Só este movimento" (ao escolher) e "Transferências" (ao mudar a partir de Transferência / rec / pag não pede regra).

### v0.8c — 27/09/2026
- Barra de cima: fica só um "Finanças pessoais"; o período, o estado de gravação e o novo botão **Hoje** passam para a barra (só no separador Finanças).
- Extratos: filtro Entradas/Saídas branco e destacado a azul quando ativo.
- Linhas divididas: Descrição na janela Dividir, Observações na tabela (o texto que já existia passa para Descrição).
- Regras: nova aba "⭐ Regras especiais" (referências "Só este movimento").

### v0.8b — 27/09/2026
- Definições: volta o menu vertical; janela com tamanho fixo; Idioma passa para Geral; opção de ordem dos movimentos do extrato.
- Tamanho: novo 100% = 90% real (padrão); opções 80–120%.
- Reembolso: título "Reembolso"; "Mostrar todas" da data para trás; botão "Posteriores".
- Dividir: 1.ª linha cinzenta, outras linhas e observações a branco.

### v0.8a — 27/09/2026 (v0.8 — Validar os números do Início, passo 1)
- 🧮 "Como foi calculado" nas caixas do Início (Entradas, Saídas, Saldo, Taxa de poupança), Despesas (Previsto, Saídas, Diferença) e Rendimentos (Líquido, Ordenado, Prémios, IRS): painel lateral com fórmula, o que conta e o que fica de fora (e porquê).
- Definições: abas horizontais, "Geral" com tema, tamanho e a opção de mostrar/esconder o 🧮.
- Logo novo: ícone da página (favicon) e ao lado de "Finanças pessoais" (página principal e Finanças).
- Mês escolhido para a sessão de validação: **junho de 2026**.

### v0.7t — 27/09/2026
- Início: caixa Rendimentos passa a usar as entradas do extrato (✓ = confirmado com recibo; "por confirmar" esbatido); nova caixa Rendimentos por tipo (referência); 4 caixas na mesma linha.
- Rendimentos: caixas como no Início; "＋ Adicionar rendimento" dentro do Resumo anual com menu (Carregar recibo | Adicionar manualmente); sai a caixa "Adicionar rendimentos".
- Extratos: Importar/Exportar passa a menu por baixo do botão (igual ao de Rendimentos).

### v0.7s — 27/09/2026
- Despesas: linhas mais baixas; caixas como no Início; "Real" → "Saídas"; vista Mês com categorias abertas por defeito e colunas Previsto/mês, Média mensal (12 meses), Entradas, Saídas, Total, Diferença (sai "Previsto período" e "Execução").
- Extratos: sem "Suportados…"; fundo da tabela só com barra cinzenta; observações editáveis nas linhas divididas; sem exemplo no Dividir; filtros com multiseleção (menos o Tipo).

### v0.7r — 27/09/2026
- README reescrito: objetivo, arquitetura, como funciona cada aba, dados/sincronização, segurança e processo de desenvolvimento.
- Extratos: botões da linha pela ordem ↩ ✂ ✏ 🗑, encostados à direita; filtro Tipo passa para o lugar do Banco (Banco vai para o fim).
- "⚙ Regras e pessoas": um botão, janela com duas abas. "⇅ Importar/Exportar": um botão, janela para escolher.
- ＋ Movimento: aba "Movimentos eliminados" para repor os últimos 50 apagados; apagados deixam de voltar ao reimportar (antes voltavam).
- Dividir: ⓘ mostra a explicação numa etiqueta.
- Janelas (Finanças, Simulador e página principal): carregar dentro e largar fora já não fecha.

### v0.7q — 27/09/2026
- Dividir: sem o texto "bate certo"; "＋ Linha" por baixo do valor; título maior e explicação no ⓘ; 1.ª linha negativa + aviso se as outras passarem o original.
- Reembolso de linhas repartidas (entradas divididas): ↩ em cada linha da janela Dividir e nas sub-linhas da tabela, com a ligação "↩ Reembolso de …".
- Extratos: botões do fim da linha em posições fixas (coluna um pouco mais larga).

### v0.7p — 27/09/2026
- Extratos: pesquisa por data (16/09, 16/09/2026 ou 09/2026) na caixa de pesquisa — data mov. ou data valor, em todos os períodos.
- Dividir: a 1.ª linha fica com o valor fechado (original − outras linhas); linhas novas começam a 0.
- Linhas divididas minimizadas por defeito, com ▸/▾ para mostrar/esconder.
- Reembolso ↩ pode escolher uma linha de um movimento dividido.
- Pessoas: caixa de pesquisa fixa no topo.
- Calendário ao clicar na data (canto superior direito) para escolher qualquer mês ou ano.

### v0.7o — 26/09/2026
- Extratos: a largura da página já não muda ao filtrar (espaço da barra de scroll sempre reservado).
- Extratos: os títulos das colunas passam para a barra fixa da pesquisa/filtros — deixam de "abanar" ao fazer scroll; acompanham o scroll horizontal.

### v0.7n — 26/09/2026
- Início: caixas maiores e centradas, explicação só ao passar o rato; Entradas/Saídas clicáveis → Extratos filtrados.
- Extratos: colunas com largura fixa.
- Reembolso: cabeçalho com descrição/valor/data/quem em destaque; sugestões do próprio dia (ou anterior) com valor maior; "Mostrar todas" com pesquisa; categorizar a despesa na hora se não tiver categoria.
- Milhares sempre com espaço (1 234,56 €) nas Finanças e no Simulador.
- Ao atualizar a página fica tudo como estava (aba, período, filtros, posição).

### v0.7m — 26/09/2026
- Extratos: botão ✂ para dividir um movimento em várias linhas (categoria, referência, observações); a soma tem de dar o valor original; sub-linhas por baixo da linha do banco; Início e Despesas usam as partes.
- Reembolso: nos Detalhes fica só a ligação "↩ Reembolso de …".
- Início: "Por categorizar" mostra todas as descrições; a caixa Entradas indica quanto ficou de fora (fora das contas/reembolsos).
- Menu da conta: fecha ao clicar na página; versão no canto superior direito; interruptor do modo escuro alinhado. Sai o subtítulo das Finanças.

### v0.7l — 26/09/2026
- Reembolsos: uma entrada com categoria de despesa abate a essa despesa (ex.: almoço 100 € − 80 € devolvidos = 20 €) e não conta como entrada.
- Despesas: Real = saídas − reembolsos, com indicador "x € − y € reemb."; vista Ano também líquida.
- Início: Entradas = Rendimentos + por categorizar; Saídas já descontam reembolsos (totais, gráfico, despesas por categoria/referência, previsto vs real).
- Extratos: botão ↩ nas entradas para escolher a despesa original ("↩ Reembolso de …" nos Detalhes, clicável).

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
