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

- D80 **Novidades**: numa versão nova (e não na primeira visita) aparece uma janela com "✨ Novas funcionalidades" e "🔧 Alterações" de todas as versões desde a última vista, resumida numa página sem scroll (máx. 7 por grupo, "+ N outras"). A última versão vista fica na conta (financas_dados, chave `novidades`) ou, sem sessão, no browser. Reabre-se no menu › Novidades. As notas estão em `NOVIDADES` (index.html) e são atualizadas a cada versão.
- D43 **Visita guiada** (antes "Onboarding"): destaca os botões reais, mudando de aba sozinha, com um balão por passo (Seguinte/Anterior/Sair, teclas ← → Esc), organizada por aba (Barra e menu, Início, Extratos, Rendimentos, Despesas). A completa mostra tudo seguido; em Definições › Visita guiada escolhe-se a completa ou só uma página. Abre sozinha no primeiro login após criar conta. (atualizada v0.8g)
- D82 **FAQs** (antes "Ajuda"): pesquisa, filtro por labels, perguntas e respostas; com sessão, o utilizador pergunta e vê "As minhas perguntas" (a aguardar/respondida). Admins do site (tabela `site_admins`) têm a aba "🛠 Gerir": responder e publicar, pôr labels, ignorar, apagar e criar FAQs. Dados em `faq_perguntas` (Supabase, RLS; máx. 10 perguntas/dia por utilizador).

- D86 Sinais para o admin do site (só quem está em `site_admins`): número de perguntas novas (FAQs) e de sugestões por ler, no avatar do canto superior direito e nas opções FAQs / Enviar sugestão. Atualizam ao abrir o site. As sugestões ficam também no Supabase (`sugestoes`, `por_ler = true`); ao abrir "Enviar sugestão" o admin vê as recebidas e passam a lidas (sinal limpa). O sinal das perguntas desaparece quando são respondidas/ignoradas.
- D89 Todas as sugestões ficam no Supabase (e também no Google Sheet). Em "Enviar sugestão" há a aba **📥 Recebidas**, que só os admins do site veem: lista (filtro por tipo, mostrar mais, apagar). Ao abrir essa aba, as sugestões passam a lidas e o sinal limpa. (v0.8i)
- D79 (atualizada v0.8h) Ao carregar em Enviar, a sugestão aparece logo como enviada (o envio para o Sheet e para o Supabase segue em segundo plano).
- D43b Visita guiada sem as etiquetas das abas no balão.
- D87 A visita guiada completa começa por escolher o **idioma** (por agora só português) e o **tema** (automático/claro/escuro), e só depois o "Bem-vindo"; o texto dos balões tem mais espaço entre linhas.

**Extratos**
- D01 CGD (CSV) e cartão refeição (Excel/CSV genérico, conta "Cartão refeição") lidos sem IA.
- D02 "Compra" (e prefixos tipo "Pagamento:") sai do início da descrição e vai para Detalhes — em todas as contas.
- D04 Reimportar nunca duplica (chave pela descrição original).
- D05 **Por categorizar** = falta a categoria **ou** a referência.
- D07 Barra de pesquisa/filtros e títulos da tabela sempre visíveis; filtro de Referência que segue a Categoria.
- D08 Dropdowns dos filtros (Categoria, Referência…) com largura fixa.
- D09 Botão "✕ Limpar filtros".
- D08b Tabela de movimentos com larguras de coluna fixas. Colunas: Data (mov.) · Descrição · Valor · Categoria · Referência · Detalhes · Observações · Quem é · Banco · ações; sem "Data valor" nem "Saldo" (aparecem ao passar o rato na data e no valor). (atualizada v0.8l)
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

- D83 Extratos: mostram 100 linhas de cada vez; ao chegar ao fundo juntam mais 100 (também há o botão "Mostrar mais"). Totais, filtros e "selecionar tudo" contam todas as linhas; ir para um movimento mostra as linhas necessárias.
- D88 Ao sair dos Extratos, a tabela volta às 100 primeiras linhas (não fica com as linhas abertas antes).
- D84 Só se desenha a aba aberta; as outras desenham-se quando se abrem.

- D90 Millennium BCP (Excel "Saldos e movimentos", detetado sozinho): conta à ordem → "Millennium" (com o n.º da conta, saldos validados e saldo final = saldo contabilístico); conta cartão → "Millennium Cartão" (sem saldo; montantes com o sinal trocado para compras ficarem negativas). Prefixos limpos: "COMPRA 1234 X" → "X" (Detalhes "Compra · cartão 1234"), "CRED" → Crédito, "DD" → Débito direto, "TRF P/ X" / "TRF. P/O X" → "TRF X" (transferência enviada/recebida, mantém Pessoas), "LEV ATM" → Levantamento.
- D91 Regras base: "PAGAMENTO CARTAO" e "VIS PAGAMENTO" → Banco › Troca entre contas (o pagamento do cartão não conta duas vezes); "LEV ATM" → Banco › Levantamentos. Acrescentadas uma vez a quem já tinha regras.
- D92 Movimentos iguais (mesma data, descrição e valor) no mesmo ficheiro são todos importados (contas sem saldo): o 2.º, 3.º… ficam com um n.º de repetição na chave; reimportar não os duplica.
- D93 BPI (Excel do BPI Net "Extracto movimentos", detetado sozinho): conta "BPI" com o n.º da conta, saldos validados e saldo final = saldo contabilístico. Prefixos limpos: "DD/MM COMPRA ELEC 1234567/NN X" → "X" (Detalhes "Compra DD/MM · cartão 1234567"), "LEV. ATM ELEC" → "LEV ATM local" (Levantamento), "TRF (CR) SEPA+ … DE X" → "TRF X" (recebida), "DD X" → Débito direto.

**Despesas**
- D10 Fora das contas (tabela de baixo): **Banco, Por tratar, Investimentos, Empresas, Rendimentos, Poupanças**.
- D06 Trocas entre contas, levantamentos, depósitos e Poupanças não contam como entrada/saída.
- D12 Referências com ✓ "Só este movimento" não sugerem regra e as regras não as usam.
- D13 Despesas numa **grelha única de 12 meses** (igual em Mês e Ano): o ano começa no mês escolhido em Definições › Geral (Janeiro por defeito) e contém o período escolhido, cujo mês fica destacado. Linhas: categoria (cinzenta, soma; abre/fecha, aberta por defeito) e referências; colunas: 12 meses (saídas − reembolsos), Total, Média (total ÷ meses com movimentos) e Previsão (mensal, **só de leitura** — edita-se na aba Previsões). Por baixo, a mesma grelha para as categorias fora das contas (entradas − saídas, coluna Previsão vazia), **alinhada** com a de cima. O modo Editar **não mostra valores**: só nome, ordem, cor e apagar da categoria; referências com ordem, apagar, "📌 Só este movimento" e "↪ Ao mudar a partir desta". (atualizada v0.8m)
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
- D19 Movimento marcado como reembolso mostra só "↩ <descrição da despesa>" nos Detalhes (sem "Reembolso de"); ao passar o rato mostra a data da despesa. (atualizada v0.10j)
- D78 Um reembolso ligado mostra na Descrição "↩ nome da despesa original" (a descrição do extrato fica no tooltip) e a pesquisa encontra-o pelos dois nomes. (v0.8e)
- D20b Janela do reembolso: mostra em destaque descrição, valor, data e quem; por defeito as saídas (todas as categorias) do próprio dia ou do anterior mais próximo, com valor maior que o reembolso; "Mostrar todas" com pesquisa; despesa sem categoria → escolher categoria/referência na hora (aplica-se às duas).
- D17 Despesas: **Saídas** (antes "Real") = saídas − reembolsos; nas linhas chama-se **Total** (colunas Entradas e Saídas ao lado). (atualizada v0.7s)
- D61 Na grelha das Despesas: valor do mês a vermelho quando passa a previsão da referência; clicar num valor (mês ou Total) abre uma **mini janela** com os movimentos desse valor (data, descrição, valor); clicar num movimento leva-o aos Extratos e "Ver todos nos Extratos" abre os Extratos filtrados (mês, ou ano no Total); "Só com valores" esconde linhas sem movimentos nem previsão; caixas de cima como no Início. (atualizada v0.10k)
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
- D64 Início: por omissão 4 caixas estreitas seguidas (numa linha no ecrã largo) — Despesas por categoria, Despesas por referência, Rendimentos e Rendimentos por tipo. As de rendimentos vêm do **extrato** (entradas da categoria Rendimentos): Rendimentos por entidade, Por tipo pela referência (Salário, Prémios, Subsídios…); o que está ligado a um recibo aparece com ✓ e cor cheia, o resto esbatido "por confirmar". (v0.7t; atualizada v0.10s: a disposição pode ser mudada em ✏ Editar, D127)
- D37 As 4 caixas do Início têm título e valor maiores e centrados; o texto explicativo só aparece ao passar o rato.
- D38 Clicar em Entradas/Saídas do Início abre os Extratos com o filtro Só entradas/Só saídas.
- D31 "Por categorizar" mostra só as descrições mais frequentes (⚡ criar regra); "Categorizar →" abre os Extratos filtrados.
- D36 "Por categorizar" mostra todas as descrições (com scroll), não só as 10 primeiras.
- D34 No Início (totais, gráfico por mês, despesas por categoria/referência) as categorias fora das contas não contam — nem saídas nem entradas — **exceto as entradas de Rendimentos** (salário, etc.).
- D15 Entrada numa categoria de despesa = **reembolso**: abate à despesa dessa categoria/referência e não conta como entrada. Entradas = Rendimentos + por categorizar.
- D32 Caixa "Despesas por referência" (entre as despesas por categoria e os rendimentos), clicável → Extratos com categoria e referência.
- D33 "Entradas e saídas por mês": sempre os 12 meses do ano do período, mais largo que o "Saldo por banco"; opção Detalhado (cores por categoria / entidade).
- D95 O "ano" começa no primeiro mês escolhido em Definições › Geral e dura 12 meses (ex.: "Set 2026 – Ago 2027"): período Ano, contas e gráficos do Início, grelha das Despesas; "Hoje" vai para o ano que contém hoje; ‹ › andam um ano.
- D96 Cores das categorias **e das referências**: escolhidas no Editar das Despesas (paleta de cores leves, aplicadas com transparência). A cor da referência tem prioridade sobre a da categoria nos Extratos e nos gráficos; com "Pintar só nos Extratos" não pinta a linha nas Despesas. Os gráficos usam sempre as cores escolhidas. Em Definições › Geral: "Pintar as linhas nas Despesas" e "Extratos: pintar a" [caixa da categoria | linha inteira | não pintar] — só uma. (atualizada v0.9f) Previsões mensais escrevem-se na aba Previsões. Extratos: descrição numa só linha (… e texto completo no tooltip), centrada na vertical.
- D97 **Tipos de despesa** (5 base: Fixas essenciais, Fixas não essenciais, Variáveis essenciais, Variáveis não essenciais, Extras) guardados nos dados (`tiposDesp`, sincronizam). Cada referência das categorias que entram nas contas tem um tipo (`refTipo['cat›ref']`), escolhido em Despesas › Editar (com "Aplicar a todas" por categoria); as referências base vêm com tipo sugerido. Os tipos gerem-se em Definições › Tipos de despesa (criar, nome, cor, ordem, apagar — ao apagar um tipo em uso pergunta para que tipo passam as referências). Grelha das Despesas agrupa por Categoria ou Tipo; Início tem "Despesas por tipo".
- D98 Privacidade com agregado (v0.9c+): a conta pessoal continua só do próprio; um agregado é uma conta separada, só dos membros que aceitaram o convite; nada passa da pessoal para o agregado, exceto a cópia de categorias e regras ao criá-lo.
- D100 **Previsões por ano** (`prevAno[ano inicial]['cat›ref']` = média mensal; o ano começa no mês das Definições). A aba mostra, por referência, total e média/mês dos 3 anos até ao ano escolhido (anos anteriores ÷ 12; ano atual ÷ meses já passados) e a previsão como Média/mês ⇄ Total ano. Um ano sem previsão própria usa a do último ano anterior e fica copiada ao editar. Despesas e Início usam a previsão do ano do período.
- D101 **Agregado** (Supabase, `supabase/004_agregados.sql`; tabelas de plataforma com `site_id`): o dono cria o agregado (nome à escolha; 1 por dono e site) e convida **pelo email** — se não existir conta com esse email aparece um alerta (no futuro: enviar email); se existir, a pessoa vê ao entrar uma mensagem para aceitar/recusar. Papéis dono/editor. O dono muda o nome, cancela convites, remove membros e apaga o agregado; um membro pode sair. **Apagar guarda 30 dias** (só o dono vê e pode restaurar) e depois apaga de vez com os dados. Tudo por funções `security definer`; RLS só para membros; máx. 20 convites/dia.
- D102 **Seletor 👤 Pessoal / 👪 Agregado** no meio da barra de cima, só no separador Finanças e só para quem tem ou está num agregado. Cada contexto tem dados totalmente separados (pessoal em `financas_dados`, agregado em `agregado_dados`; cópia local por contexto). Um agregado novo começa com as categorias, tipos, cores e regras da conta pessoal (sem movimentos nem pessoas). A escolha fica guardada no browser; se deixar de ser membro volta a Pessoal. No agregado, as alterações dos outros aparecem a cada 30 s ou ao voltar à página; gravações simultâneas juntam-se.
- D104 Início: cada gráfico circular tem o seu botão € / %. "Previsto vs real": barra que enche com o real e uma linha no previsto; vermelha quando passa. Ao passar de Ano para Mês abre o mês atual se estiver nesse ano, senão o último mês escolhido. No Editar das Despesas o cabeçalho com Concluir fica fixo. Aba Objetivos existe (em desenvolvimento).
- D105 **Estatísticas de uso**: só com sessão iniciada, guardadas em `site_eventos` (plataforma, por site) com o utilizador — sessão, ping a cada minuto com a página visível (tempo no site), separador e abas, importar (banco, linhas) e importação/exportação falhada (extensão e motivo), categorizar, regras, dividir, previsões, agregado, exportar, cópias, sugestões, perguntas e erros de JavaScript. **Nunca** valores, descrições de movimentos nem nomes de ficheiros. Ninguém lê a tabela diretamente; a página `admin.html` (menu da conta › Estatísticas, só admins) mostra os totais via `admin_stats`, com emails. Apagam-se ao fim de 12 meses. Visitantes anónimos: Umami (sem cookies; `UMAMI_ID` em index.html). Definições › Conta explica o que é recolhido.
- Poupanças: aparecem como "Poupanças - referência" em "Saldo por banco" e abrem os Extratos filtrados.
- D106 **Assistente da 1.ª vez** (configuração inicial, abre sozinho na 1.ª entrada e em Definições › Visita guiada › Configuração inicial): idioma/tema → bem-vindo → 1.º mês do ano → 1.º extrato *ou* conta de exemplo → rever categorias (só se tiram as sem movimentos e que não são do sistema) → regras sugeridas (descrições mais frequentes por categorizar, criadas só as marcadas) → visita guiada opcional. A configuração vai **sempre para a conta pessoal**. A **conta 🧪 Exemplo** tem movimentos fictícios gerados no browser, fica **só neste browser** (nunca vai para a conta nem para o Supabase), aparece no seletor de contas com uma faixa a avisar e apaga-se com um clique; usa as categorias e regras da conta pessoal.
- D107 **Primeiros passos, dicas e ajuda**: caixa "🚀 Primeiros passos" no Início (importar, categorizar ≥ 90%, criar regra, escrever o previsto, adicionar rendimento, visita guiada) com progresso; some quando está tudo feito, com "Esconder" (fica na conta) e não aparece nos agregados. **Dicas** (1–3 bolhas nos botões reais) só na **1.ª visita** a Extratos, Rendimentos, Despesas e Previsões, só para quem fez a configuração inicial ou pediu em Definições; "Não mostrar dicas" desliga-as; nunca por cima da visita guiada. **ⓘ** nas caixas (texto em `INF`) e nas colunas com explicação (`th[title]`), com balão ao clicar (telemóvel). Definições › Visita guiada tem "Configuração inicial" e "Mostrar as dicas outra vez".
- D108 **Banco não suportado**: quando um extrato falha, explica que bancos são lidos e oferece "📨 Enviar amostra anónima" (também no assistente). A amostra é feita **no browser**: só as primeiras linhas, datas mantidas, letras → X, algarismos ao acaso, cabeçalho das colunas com as palavras; abre Enviar sugestão (tipo Problema) já preenchida para a pessoa **ver e editar antes de enviar**. O ficheiro nunca sai do browser.
- D109 **Telemóvel** (≤ 760 px): barra de cima em duas linhas (separadores + menu; contas + período), sem deslocamento horizontal; nos Extratos (≤ 640 px) cada movimento é um cartão (data, descrição, valor, categoria/referência, observações/quem, ações) e os filtros não ficam presos; faixa do exemplo numa linha.
- D110 **RGPD (só Finanças)** (atualizada v0.10e): Definições › Conta tem "Exportar os meus dados" (`financas_exportar`: só os dados das Finanças — email, `financas_dados`, preferências do site, agregados das Finanças com dados, convites, sugestões, perguntas e estatísticas do site) e "Apagar os meus dados das Finanças" (`financas_apagar_dados`, confirmação escrevendo o email; **a conta de login continua**; sai dos agregados, os de que é dono passam ao membro mais antigo ou apagam-se se for o único). Os textos falam só das Finanças, nunca dos outros sites. Página `privacidade.html` curta (o que se guarda, o que não, quem vê, onde, prazos, direitos), ligada na conta, no login e em "Dados de uso". Qualquer novo dado guardado tem de entrar na exportação e na página.
- D111 **Segurança Supabase**: funções de trigger sem execute pela API; funções com `search_path` fixo; funções que dizem respeito a quem tem sessão só para `authenticated`. Exceções de propósito para `anon`: `parkncharge.is_admin`, `e_admin_site` (políticas de leitura pública) e `promo_is_allowed` (antes do login). Novas funções `security definer` sempre com `set search_path = ''`, revoke de `public, anon` e verificação de `auth.uid()`.
- D112 **É preciso conta** (v0.10e): sem sessão a página principal só mostra o ecrã "Entrar / Criar conta" (sem ligação ao serviço de contas, explica e não deixa usar); `financas.html` aberto sozinho vai para `index.html#financas`. Os testes automáticos usam `?teste=1` para saltar isto. A conta 🧪 Exemplo continua (com sessão). Substitui o uso "só neste browser" sem conta (D73: o estado continua a existir mas já não se usa sem sessão).
- D113 **Ajuda ⓘ** pode ser escondida em Definições › Geral (`fp_inf`). **Pesquisa dos Extratos** com texto fica azul. **Criar regra**: "Cancelar" repõe a categoria/referência que o movimento tinha antes da mudança (só quando a janela abre por mudar a categoria). **Previsto vs real**: a escala vai até 110% do previsto, para o traço do previsto ficar dentro da barra.
- D114 **Perfil financeiro** (Definições › 🧾 Perfil financeiro): tudo opcional — data de nascimento, estado civil, tributação (só se casado/união de facto), situação profissional, anos de descontos, região fiscal, habitação, incapacidade **só como sim/não ≥ 60%** (nunca detalhes de saúde) e dependentes (ano de nascimento de cada um). Privado: guardado em `user_site_data` (site `financas`, chave `perfil`, RLS só do próprio), nunca nos agregados; entra na exportação e apaga-se com os dados das Finanças; descrito na página de privacidade.
- D115 **Agregado** com botões a roxo (#7b1fa2, a cor do agregado no seletor). **Previsões**: títulos das colunas numa barra fixa que acompanha o scroll (como nos Extratos); nos anos anteriores, Média/mês antes do Total. **Extrato não reconhecido** (banco sem leitor próprio): tenta ler as colunas de data, descrição e valor; se conseguir importa e avisa "Banco não reconhecido — confira e envie-nos um exemplo"; se não, "Extrato não reconhecido — envie-nos um exemplo"; em ambos com o botão da amostra anónima (D108).
- D116 **Login**: 👁 mostra/esconde a palavra-passe (login, nova palavra-passe e Definições › Conta). "Esqueceu-se da palavra-passe?" usa o email escrito e envia um link (`resetPasswordForEmail`, volta a este site); a resposta nunca diz se a conta existe. Ao voltar pelo link (evento `PASSWORD_RECOVERY`) abre a janela "Nova palavra-passe" (duas vezes, mín. 6). Os emails precisam de SMTP próprio no Supabase e do site nas Redirect URLs.
- D117 **Recibos**: além do modelo antigo, lê o modelo **PRIMAVERA** (colunas Remunerações | Descontos, valores com espaço nos milhares "1 020,00", linha "Total" e "Total Pago ( EUR )", NIF da empresa no cabeçalho) e só dá "totais conferem" se o total das remunerações e o total pago baterem. **Recibo não reconhecido** (ou totais que não conferem): explica e oferece "📨 Enviar recibo tipo (anónimo)" — feito no browser: palavras típicas do recibo, códigos (R01, D02) e datas mantidos; nomes, empresas e outros textos → X; algarismos ao acaso; abre a sugestão para a pessoa ver antes de enviar. O PDF nunca sai do browser.
- D118 **Recibos (mais modelos)**: modelo "RECIBO DE REMUNERAÇÕES" (Cód. | Remunerações | Tempos | Valor unitário | Valor remuneração; Descontos | Incidências | Valor do desconto; Valor ilíquido / Descontos / Valor líquido a receber; mês "Março / 25"). Original e duplicado **um por cima do outro** → usa só o de cima; lado a lado só quando "Duplicado" está à altura de "Original". PRIMAVERA: linhas com valor 0,00 na coluna Faltas não contam e a descrição é lida mesmo desalinhada do título.
- D119 **Previsto vs real** (Início): o traço do previsto fica sempre no mesmo sítio (≈91% da barra) em todas as linhas; a barra é real ÷ previsto até ao traço, **azul** até ao previsto e **vermelha** quando o ultrapassa (passa o traço); sem previsto, barra cinzenta cheia. **Reembolso**: pesquisa sempre visível (descrição, valor, categoria, referência, quem é); "＋ Sugerir mais" junta as saídas de valor **igual ou maior** de mais um mês para trás a cada clique. **Ir para a despesa** (↩ nos Detalhes): fica logo abaixo das barras fixas e aparece "↩ Voltar ao reembolso" (20 s), que repõe filtros, período e a linha. Mensagens de importação de extratos e recibos com "✕ Limpar". **Agregado**: com um agregado escolhido, os botões/destaques das Finanças e da barra de cima ficam roxos (#7b1fa2).
- D120 **Ir para a despesa** mantém a vista: em Ano fica Ano (no ano da despesa); em Intervalo fica se a data cabe; senão vai para o mês. O botão "↩ Voltar ao reembolso" aparece também a partir das linhas de um movimento dividido (e as linhas divididas mostram "↩ descrição" com a data ao passar o rato). A **janela do reembolso** tem altura fixa (a lista desliza por dentro).
- D121 **Reembolso ligado (↩) conta na data da despesa original** — também cada linha de um movimento dividido — em todas as contas: Início (caixas, gráficos, previsto vs real, 🧮), Despesas (grelha, médias, mini janela), Previsões (anos anteriores, "média do ano anterior"). Nos Extratos e no saldo por banco o movimento fica na data real em que o dinheiro entrou. Reembolsos sem ligação contam na data em que entraram. (Internamente `expandeC` desloca `dm` e guarda a data real em `dm0`; a chave do movimento usa sempre a data real.)
- D122 **Extratos e movimentos divididos**: os filtros de categoria/referência e a pesquisa de texto olham para **cada linha** do movimento dividido (descrição, categoria, referência, observações e a despesa do reembolso); o movimento aparece aberto só com as linhas que batem e os totais do cabeçalho contam só essas linhas. Se a pesquisa bater na descrição do próprio movimento, mostra todas as linhas. **Mini janela das Despesas**: a data é a do extrato (a conta continua na data da despesa, D121; ↩ e explicação ao passar o rato); clicar num reembolso abre o movimento (antes dava "Movimento não encontrado").
- D123 **"Quem é" nos Extratos só de leitura**: preenche-se só pelas regras de Pessoas (⚙ Regras e pessoas); na lista e na edição em massa não se escreve (os movimentos em dinheiro adicionados à mão continuam a ter o campo). **Despesas**: títulos da grelha numa barra fixa que acompanha o scroll (como nas Previsões). **Mini janela**: coluna "Quem é" (numa linha de movimento dividido, o do movimento original).
- D124 **Rendimentos e extrato**: as entradas dos Extratos na categoria Rendimentos que **não estão ligadas** a um recibo/rendimento aparecem no Resumo anual (etiqueta "extrato", "⚠ recibo por ligar", clicável para o movimento) e contam no **Líquido** (não no bruto, IRS, SS nem ordenado). Quando um recibo/rendimento as liga (🔗), a linha do extrato sai e fica a do recibo. Filtros no Resumo anual: **Origem** (todas / com recibo ou rendimento / só extrato) e **Ligação** (ligados e por ligar / só ligados / só por ligar), além da entidade.
- D125 **Mês de conta**: cada movimento conta num mês (Início, Despesas, Previsões, Rendimentos do extrato) que pode não ser o da data do banco; nos Extratos e saldos fica sempre a data real. Por ordem: (1) **à mão** — clicar na **data** nos Extratos ou na mini janela das Despesas abre a janela do mês (mês do pagamento, o anterior e o seguinte, com ‹ › para andar mais meses; "Repor automático"); as datas de movimentos que contam noutro mês aparecem **a cor** (sem ícone; o mês está no texto ao passar o rato); na mini janela, clicar no resto da linha vai para o movimento; (2) **reembolso ligado** → mês da despesa (D121); (3) **ligado a um recibo** → mês do recibo; em **Dividir movimento** cada linha tem à esquerda o seu mês de conta (vazio = o do pagamento); (4) **dia de corte da referência** em Despesas › ✏ Editar (até o dia X → mês anterior; a partir do dia Y → mês seguinte). Nas Despesas, ⚠ numa referência mensal com 2+ pagamentos num mês e nenhum num mês ao lado — pode desligar-se em Definições › Geral. Vale igual para os agregados. (atualizada v0.10r)
- D127 **Início personalizável** (✏ Editar): cada caixa pode ser escondida/mostrada (＋ nas "Caixas escondidas"), mudada de ordem (arrastar pela pega ⠿, ou ◀ ▶) e ser **estreita** (¼) ou **larga** (½); no telemóvel ocupa sempre a largura toda. Os KPIs e os Primeiros passos ficam fixos no topo. A disposição e as escolhas dos gráficos ficam **na conta de cada pessoa** (`user_site_data`, site `financas`, chave `inicio`; cópia em `fp_inicio` no browser) — iguais em todos os dispositivos e nos agregados, cada membro com a sua. "↺ Repor" volta à disposição de origem. Caixas **Despesas por categoria / por referência por mês**: linhas dos 12 meses do ano (saídas − reembolsos, com o mês de conta, D121/D125), uma por categoria/referência escolhida (sem escolha: as 3 maiores do ano), o **previsto** por mês a tracejado da mesma cor; meses futuros sem ponto.
- D128 **Data do pagamento vs mês a que se refere**: nos **Extratos** o movimento aparece na data do banco (quando foi pago); a janela do mês de conta diz "Refere-se a <mês> · pago a <data>". Nos **Rendimentos** cada linha fica no mês a que se refere e a coluna **Data** (a seguir ao Mês) mostra quando foi pago (data do extrato; nos recibos, a dos movimentos ligados) — a cor quando foi pago noutro mês. Os títulos da tabela do Resumo anual ficam fixos ao descer. **🏢 Entidades**: o utilizador dá um nome a cada entidade encontrada (recibos e extrato); as que têm o mesmo nome juntam-se nas linhas e no filtro dos Rendimentos (`DB.entNome`; os nomes originais não mudam; só nos Rendimentos).
- D129 **Empresas** (v0.11): uma empresa é uma conta de Finanças separada, como o agregado (mesmas tabelas `agregados`/`agregado_dados` com `tipo = 'empresa'`, convites e regras de acesso do D98). A secção **Definições › 🏢 Empresas** e o botão **🏢 Empresas** (com a lista das empresas) no seletor do topo só aparecem a quem pode criar empresas ou é membro de alguma. **Criar empresas** exige a permissão `criar_empresa` na tabela `permissoes` (verificada no servidor por `empresa_criar`; para já só o Sebastião; para abrir a todos insere-se uma linha com `user_id` nulo). No contexto de uma empresa tudo fica **amarelo torrado** (#b45309; escuro #f0b347). Empresa nova começa com **categorias e regras de empresa** (Fornecedores, Pessoal, Instalações, Serviços, Viaturas, Impostos, Financiamento, Banco, Sócios, Por tratar, Rendimentos); "Sócios" fica fora das contas. O agregado continua limitado a 1 por pessoa; empresas até 20.

---

## Histórico

### v0.11 — 06/10/2026
- Empresas (base da v1.4 adiantada): contas de empresa partilháveis por convite, botão 🏢 Empresas no seletor, cor amarelo torrado, categorias de empresa; permissão para criar no Supabase (`007_empresas.sql`, aplicada) (D129).

### v0.10t — 06/10/2026
- Rendimentos: coluna Data (quando foi pago), linhas no mês a que se referem, títulos fixos e 🏢 Entidades para dar nomes e juntar entidades (D128).
- Mês de conta: a janela diz "Refere-se a … · pago a …".
- Backup semanal automático (GitHub + Supabase) no repositório privado `backups`.

### v0.10s — 04/10/2026
- Início: botão ✏ Editar para esconder/mostrar, arrastar e alargar/estreitar as caixas, guardado na conta de cada pessoa (D127; D64 atualizada).
- Novas caixas: Despesas por categoria e por referência, em linhas pelos meses do ano, com o previsto a tracejado.
- Versão v0.10r guardada no GitHub no ramo `backup/v0.10r`.

### v0.10r — 04/10/2026
- Mês de conta: janela com 3 meses e setas ‹ ›; mês de conta por linha ao dividir um movimento (D125 atualizada).

### v0.10q — 04/10/2026
- Mês de conta: clicar na data (Extratos e mini janela) em vez do ícone 📅; datas que contam noutro mês a cor; opção para esconder os avisos ⚠ das Despesas (D125 atualizada).

### v0.10p — 04/10/2026
- Mês de conta: à mão, pelo recibo, por dia de corte da referência, aviso de pagamentos duplicados (D125). Coluna Data dos Extratos um pouco mais larga para o 📅.

### v0.10o — 03/10/2026
- Rendimentos do extrato sem recibo na aba Rendimentos, com filtros de origem e ligação (D124).

### v0.10n — 03/10/2026
- Despesas com títulos fixos, "Quem é" na mini janela, "Quem é" só de leitura nos Extratos (D123).

### v0.10m — 03/10/2026
- Filtros e pesquisa nos movimentos divididos; mini janela com a data do extrato e ligação certa dos reembolsos (D122).

### v0.10l — 03/10/2026
- Reembolsos ligados contam na data da despesa original (D121); na mini janela das Despesas aparecem com ↩ e a data real ao passar o rato.

### v0.10k — 03/10/2026
- Despesas: mini janela com os movimentos de cada valor (D61 atualizada).
- Reembolso: vista Ano mantida, voltar também a partir de linhas divididas, data nas linhas divididas, janela de tamanho fixo (D120).

### v0.10j — 03/10/2026
- Previsto vs real com traço fixo, reembolso (sugerir mais, pesquisa, voltar, texto e data), limpar mensagens de importação, roxo no agregado (D119, D19 atualizada).
- Texto antigo "Em breve: seletor Pessoal / Família" trocado por como usar o seletor.

### v0.10i — 02/10/2026
- Recibos: modelo "RECIBO DE REMUNERAÇÕES", cópias empilhadas e PRIMAVERA com faltas (D118). Testes com recibos fictícios.

### v0.10h — 02/10/2026
- Recibos PRIMAVERA e recibo tipo anónimo quando não é reconhecido (D117). Teste com recibo fictício (itens gerados no teste, sem PDF real no repositório).

### v0.10g — 02/10/2026
- Login: mostrar/esconder a palavra-passe, recuperar a palavra-passe por email, janela da nova palavra-passe (D116). Texto da janela de entrar sem "outros sites" nem "só neste dispositivo".

### v0.10f — 02/10/2026
- Perfil financeiro (D114).
- Agregado a roxo, Previsões com títulos fixos e Média/mês primeiro, extrato não reconhecido (D115).
- A altura da barra fixa das Finanças atualiza-se sozinha (faixa do exemplo), para os títulos fixos não ficarem tapados.

### v0.10e — 01/10/2026
- É preciso conta para usar as Finanças (D112): ecrã de entrar/criar conta; `financas.html` sozinho redireciona.
- RGPD só das Finanças (D110 atualizada): `financas_exportar` aplicada; `financas_apagar_dados` em `supabase/006_rgpd_seguranca.sql` para correr no editor SQL (substitui `apagar_minha_conta`, que já não é para aplicar).
- Privacidade: sem referências à plataforma, ao uso sem conta, às regras por linha e à CNPD; "Os seus dados: os seus extratos são guardados mas estão protegidos e não são vistos por ninguém."
- Opção para esconder a ajuda ⓘ, pesquisa azul com texto, Cancelar ao criar regra, traço do previsto dentro da barra (D113).

### v0.10d — 01/10/2026 (fecha a v0.10)
- RGPD (D110): exportar os meus dados, apagar a minha conta, página de privacidade (`privacidade.html`).
- Segurança (D111): migração `seguranca_v010d` (revoke em funções de trigger e de verificação, search_path fixo, política das partilhas só com sessão); `minha_conta_exportar` aplicada. `apagar_minha_conta` está em `supabase/006_rgpd_seguranca.sql` para correr no editor SQL (até lá o botão explica que se pede pelas Sugestões).

### v0.10c — 01/10/2026 (v0.10 — passo 3)
- Telemóvel (D109): barra de cima em duas linhas, movimentos dos Extratos em cartões, "Escolher extrato(s)" em vez de "Arraste", filtros não presos, faixa do exemplo compacta.
- Banco não suportado (D108): explicação + amostra anónima enviada pelas Sugestões (`fpAmostra`, `FPSug.amostra`).

### v0.10b — 01/10/2026 (v0.10 — Onboarding, passo 2)
- Primeiros passos no Início, dicas na 1.ª visita a cada aba e ajuda ⓘ (D107).
- Definições › Visita guiada: repetir a configuração inicial e voltar a mostrar as dicas/primeiros passos.
- A visita guiada completa marca o passo "Fazer a visita guiada".

### v0.10a — 01/10/2026 (v0.10 — Onboarding, passo 1)
- Assistente da 1.ª vez (D106) substitui a visita automática para contas novas: 1.º mês do ano, primeiro extrato (com bancos suportados e como exportar), rever categorias, regras sugeridas com categoria proposta, e no fim a visita guiada opcional.
- Conta 🧪 Exemplo (contexto `x`, chave `financas_v1_ex`): 3 meses de movimentos fictícios, sem sincronizar; seletor mostra-a; faixa com "Voltar ao Pessoal" / "Apagar exemplo".
- `importar()` devolve o resultado (usado pelo assistente); `fpCfg` (importar, categorias, regras sugeridas) e `fpCtx.exemplo/apagaEx/temEx`.
- As Finanças só usam o cliente Supabase da página principal quando já tem `auth` (evita erro com a página ainda a carregar).

### v0.9h — 01/10/2026
- Estatísticas: filtro por site passa a filtrar as contas (caixas, contas novas, percurso e tabela) às que usam esse site; coluna "Mov. agregado".
- Umami ligada (Website ID em `UMAMI_ID`).

### v0.9g — 01/10/2026
- Estatísticas de uso (D105): tabela `site_eventos` + funções de admin no Supabase; registo de eventos na página principal (FPTrack) e nas Finanças; página `admin.html` com caixas, gráficos (ativos/tempo por dia, contas novas), percurso, abas, funcionalidades, utilizadores (email), falhas de importação e erros.
- Umami preparado (falta o Website ID). Item "📊 Estatísticas (admin)" no menu da conta para admins.

### v0.9f — 29/09/2026
- Cor por referência com "Pintar só nos Extratos" (D96 atualizada); Definições: "Extratos: pintar a" (combo) e sai a opção dos gráficos.
- Início: € / % nos donuts; Previsto vs real com linha do previsto (D104).
- Ano → Mês abre o mês atual/último escolhido; Concluir fixo no Editar; aba Objetivos (em desenvolvimento).

### v0.9e — 29/09/2026
- Corrigido: Definições › Agregado familiar mostrava "Entre na sua conta" com sessão iniciada — a sessão chegava antes de o módulo do agregado existir. Agora o módulo apanha a sessão já existente (ao iniciar e ao abrir a secção).

### v0.9d — 29/09/2026 (fecha a v0.9)
- Seletor Pessoal / Agregado na barra (D102); troca grava antes o que falta enviar, carrega a cópia local do outro contexto e sincroniza.
- Agregado novo: cópia de categorias, tipos, cores e regras da conta pessoal.
- Com o seletor visível, o estado "Guardado na conta" da barra esconde-se em ecrãs < 1750 px (falta espaço).

### v0.9c — 29/09/2026
- Supabase: `agregados`, `agregado_membros`, `agregado_convites`, `agregado_dados` + funções (criar, renomear, convidar, cancelar convite, responder, sair, remover, apagar/restaurar, meus_agregados, meus_convites); RLS testada com dois utilizadores (sem acesso antes de aceitar, sem acesso aos dados pessoais, dono/membro).
- Definições › 👪 Agregado familiar e janela de convite ao entrar (D101).
- A leitura dos dados pessoais filtra também por `user_id` (defesa extra).

### v0.9b — 29/09/2026
- Aba Previsões (D100): 3 anos de histórico por referência (total e média/mês), previsão por ano como média/mês ou total do ano, ‹ › por ano, ↺ média do ano anterior (linha ou todas), limpar ano, "Só com valores", totais por tipo.
- As previsões antigas (mensais, sem ano) passam para o ano atual.

### v0.9a — 29/09/2026 (v0.9 — Tipos de despesa, Previsões e Agregado familiar, passo 1)
- Tipos de despesa por referência (D97): coluna no Despesas › Editar com "Aplicar a todas", Definições › Tipos de despesa, grelha agrupável por Tipo, caixa "Despesas por tipo" no Início.
- Mudar o nome de uma categoria mantém a cor e os tipos (a cor perdia-se desde a v0.8m).
- Plano da v0.9 combinado: 0.9a tipos · 0.9b Previsões (3 anos, previsão por ano, média ⇄ total) · 0.9c agregado no Supabase · 0.9d seletor Pessoal/Família. Regra de privacidade do agregado registada (D98).

### v0.8m — 29/09/2026
- Ano segue o primeiro mês das Definições ("Set 2026 – Ago 2027") no período, contas e gráficos do Início (D95).
- Cores por categoria (Despesas › Editar) e opções em Definições › Geral: gráficos, linhas das Despesas, caixa/linha nos Extratos (D96).
- Despesas: previsão só de leitura (edita-se na nova aba Previsões); Total clicável → Extratos do ano; tabela de baixo alinhada; Editar sem valores, com "Só este movimento" e "Ao mudar a partir desta".
- Extratos: descrição numa linha; corrigida a largura da coluna Descrição (desde a v0.8l ficava estreita).

### v0.8l — 28/09/2026
- Extratos: saem as colunas "Data valor" e "Saldo" (ficam no tooltip da data e do valor).
- Despesas: grelha de 12 meses (substitui as vistas Mês/Ano) com Total, Média e Previsão; categorias abrem/fecham; acima da previsão a vermelho; clique → Extratos.
- Definições › Geral: primeiro mês do ano nas Despesas.

### v0.8k — 28/09/2026
- Novo banco: BPI (Excel do BPI Net).

### v0.8j — 28/09/2026
- Novo banco: Millennium BCP (Excel) — conta à ordem e conta cartão de crédito.
- Regras base para o pagamento do cartão (entre contas) e levantamentos ATM.
- Movimentos iguais no mesmo dia em contas sem saldo já não se perdem.

### v0.8i — 28/09/2026
- Sugestões: aba "📥 Recebidas" (só admin) em Enviar sugestão; todas guardadas no Supabase.
- Extratos: ao sair da aba volta às 100 primeiras linhas.
- Visita guiada: começa pelo idioma e pelo tema; texto mais espaçado.

### v0.8h — 28/09/2026
- Sinais de perguntas novas e sugestões por ler (só admin), no avatar e no menu; sugestões copiadas para o Supabase (`sugestoes`).
- Sugestão aparece logo como enviada.
- Visita guiada sem etiquetas das abas.
- Extratos mais rápidos: 100 linhas de cada vez e só se desenha a aba aberta (5000 movimentos: de ~6 s para ~0,1 s).

### v0.8g — 28/09/2026
- Janela de Novidades por versão (novas funcionalidades / alterações).
- Visita guiada nos botões reais, aba a aba; completa ou só de uma página (Definições › Visita guiada).
- FAQs com pesquisa, labels, perguntas dos utilizadores e aba de gestão para admins (Supabase: `site_admins`, `faq_perguntas`).

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
