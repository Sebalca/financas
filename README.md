# Finanças Pessoais — financas.frisk.pt

## Objetivo

Um site para **controlar as finanças pessoais e da família** a partir dos extratos bancários, sem ter de escrever movimentos à mão nem entregar dados a terceiros:

- importar os extratos dos bancos (CSV/Excel) e os recibos de vencimento (PDF);
- classificar cada movimento por **categoria › referência** (automaticamente, com regras);
- saber **quanto entra, quanto sai, onde se gasta e quanto se poupa**, por mês e por ano;
- ter os números certos: reembolsos abatem às despesas, transferências entre contas não contam, movimentos divididos contam por partes;
- mais tarde: previsões, análise da saúde financeira, ligação ao simulador salarial e partilha entre membros da família.

O site faz parte de uma **plataforma de vários sites `*.frisk.pt`** que partilham a mesma infraestrutura (GitHub + Supabase + Cloudflare) e o mesmo sistema de contas: um utilizador cria a conta uma vez e usa-a em todos os sites. Os dados de cada site ficam separados e cada utilizador só vê os seus.

Plano de versões: [ROADMAP.md](ROADMAP.md) · Histórico e regras que não se podem quebrar: [PATCH NOTES.md](PATCH%20NOTES.md).

---

## Como está construído

| Peça | Para quê |
|---|---|
| **HTML + CSS + JavaScript puro** | Cada ferramenta é **um único ficheiro HTML** (sem framework nem build). Abre-se diretamente no browser e funciona offline. |
| **GitHub** (`Sebalca/financas`) | Código e versões. Cada `push` para `main` publica o site. |
| **Cloudflare Workers** (assets estáticos) | Serve a pasta `public/` em `financas.frisk.pt` (DNS, SSL, CDN). Configuração em `wrangler.jsonc`. |
| **Supabase** (projeto da plataforma) | Contas (login) e base de dados PostgreSQL onde ficam os dados de quem tem sessão. |
| **plataforma-core** (`auth.js`) | Módulo partilhado por todos os sites: cliente Supabase com a chave **pública** e janela de login. |

### Ficheiros

```
public/
  index.html               página principal: separadores, conta, menu, definições, onboarding
  financas.html            a aplicação de finanças (Início, Extratos, Rendimentos, Despesas…)
  simulador-salarial.html  simulador salarial PT 2026 (Pessoas, Empresas, Unipessoal, Esquema)
  lib/                     pdf.js 3.11 e SheetJS 0.18.5 (alojados aqui; só carregam quando necessários)
supabase/001_financas_dados.sql   tabela e regras de acesso (RLS)
tests/regressao.cjs               testes automáticos (Playwright)
tests/fixtures/                   extratos FICTÍCIOS usados nos testes
tools/sugestoes-apps-script.gs    código do Google Apps Script que recebe as sugestões (Google Sheet)
CLAUDE.md                         processo obrigatório para cada alteração
PATCH NOTES.md                    decisões fixas + histórico de versões
ROADMAP.md                        plano de versões
```

### Página principal (`index.html`)
- **Separadores** definidos na lista `SEPARADORES`: Finanças, Simulador Salarial (ficheiros próprios, em `iframe`) e sites externos (Bíblia financeira, Stock casa).
  - Link direto: `index.html#financas`, `#simulador`…
  - Os sites externos têm `data-ext` e **nunca recebem a sessão nem o tema**.
- **Conta**: botão Entrar / avatar ▾ com menu (Definições, Plano, Visita guiada, Novidades, modo escuro, FAQs, Enviar sugestão, Terminar sessão) e a versão no canto.
- **Definições** (menu vertical): Geral (tema, tamanho 80–120% com padrão = 90% real, idioma, ordem dos movimentos, opção do ícone 🧮), cópia de segurança (exportar/importar ficheiro), apagar dados, conta, onboarding, ajuda.
- **Visita guiada**: destaca os botões reais aba a aba (completa ou só de uma página, em Definições › Visita guiada); abre sozinha no primeiro login depois de criar conta.
- **Novidades**: janela com as novas funcionalidades e alterações quando há uma versão nova (lista `NOVIDADES` em index.html; última versão vista na conta ou no browser).
- **FAQs**: pesquisa, labels, perguntas dos utilizadores e gestão para admins (Supabase `faq_perguntas` + `site_admins`, ver `supabase/002_faq_e_admins.sql`).
- Tema e zoom passam para os separadores internos por `postMessage` (`fp-tema`, `fp-zoom`).

Para acrescentar um separador: criar o HTML em `public/` e juntar `{id:'novo', nome:'Nome', ficheiro:'novo.html'}` (ou `url:` para um site externo) a `SEPARADORES`.

---

## Como funciona a aplicação de Finanças (`financas.html`)

### Período
Na barra de cima da página principal (só no separador Finanças): **Mês / Ano / Intervalo**, setas ‹ ›, um **calendário** ao clicar na data (ano + 12 meses; os meses com movimentos têm um ponto), o botão **Hoje** e o estado de gravação. Todas as abas usam o período escolhido. As Finanças expõem `window.fpPer` e avisam a página principal com a mensagem `fp-per`.

### Extratos
- **Importar**: arrastar ficheiros ou escolher (vários de uma vez).
  - Leitores sem IA, um por banco: **CGD** (CSV "Consultar saldos e movimentos"), **Millennium BCP** (Excel "Saldos e movimentos": conta à ordem e conta cartão, `leMillennium`), **BPI** (Excel do BPI Net, `leBPI`) e **cartão refeição** (Excel/CSV com Data mov., Data valor, Descrição, Valor, Saldo). Há também um leitor genérico.
  - Os **saldos são validados** linha a linha (e o saldo final).
  - **Duplicados**: cada movimento tem uma *chave* (banco, conta, datas, descrição original, valor, saldo). O que já existe é ignorado.
  - O prefixo "Compra …" sai da descrição e vai para Detalhes; a descrição original fica em `desc0`, para a chave não mudar.
- **Tabela** com colunas de largura fixa; mostra 100 linhas de cada vez e junta mais 100 ao descer (só se desenha a aba aberta). Os títulos das colunas ficam na barra fixa, junto à pesquisa e aos filtros.
- **Pesquisa** por texto, e também por data: `16/09`, `16/09/2026` ou `09/2026` (data mov. ou data valor, em todos os períodos).
- **Filtros**:
  - Tipo; Categoria (ou "Por categorizar"), Referência, Quem é e Banco com **multiseleção**;
  - botão "Limpar filtros".
- **Categorizar**: combos de categoria e referência em cada linha.
  - Ao categorizar à mão, pergunta se quer criar uma regra ou só para este movimento.
  - Seleção múltipla permite a **edição em massa**.
- **Botões de cada linha**, em lugares fixos e encostados à direita:
  - ↩ reembolso;
  - ✂ dividir;
  - ✏ editar (só nos movimentos em dinheiro);
  - 🗑 apagar.
- **Dividir (✂)**:
  - um movimento passa a ter várias linhas (valor, categoria, referência, observações);
  - a 1.ª linha é calculada (original − restantes);
  - as sub-linhas aparecem por baixo (▸/▾) e todas as contas passam a usar as partes.
- **Reembolso (↩)**: uma entrada é ligada à despesa original (ou a uma linha de uma despesa dividida). Fica com a mesma categoria/referência e **abate a essa despesa**. Numa entrada dividida, cada linha pode ser um reembolso.
- **＋ Movimento**, com duas abas:
  - movimentos em **dinheiro** (conta 💵 Dinheiro com saldo próprio; levantamentos entram e depósitos saem);
  - **Movimentos eliminados**, onde se repõem os últimos 50 apagados.
- **Movimentos apagados**:
  - não voltam a entrar ao reimportar o extrato;
  - exceção: os de uma importação removida podem ser reimportados.
- **⚙ Regras e pessoas** (uma janela, três abas):
  - **Regras especiais**: regras com nome e tipo — 📌 *ao escolher* estas referências não pede regra (e as regras não as usam); ↪ *ao mudar a partir* destas referências não pede regra (ex.: "Transferências"). Guardadas em `esp`.
  - **Regras**: "contém", "tem a palavra" ou "começa por", para entradas, saídas ou ambas. Ganha a primeira regra que corresponder (ordem ↑↓). Não mexem nos movimentos categorizados à mão nem nos divididos.
  - **Pessoas**: identificadores encontrados nas descrições (TFI, TRF, MB WAY…) associados a um nome, que preenche "Quem é". Tem uma pesquisa fixa.
- **⇅ Importar/Exportar** (menu por baixo do botão):
  - exportar em CSV os movimentos do período;
  - ver as importações feitas (e remover uma).

### Início
- Caixas **Entradas, Saídas, Saldo do período, Taxa de poupança**. Clicar em Entradas ou Saídas abre os Extratos filtrados.
- **O que não conta** nas entradas/saídas:
  - movimentos entre contas (Banco › Troca entre contas, Levantamentos, Depósitos; Poupanças);
  - categorias **fora das contas** (Banco, Por tratar, Investimentos, Empresas, Poupanças). Exceção: as **entradas de Rendimentos** (salário…) contam.
- **Como contam os reembolsos**: uma entrada numa categoria de despesa é um **reembolso** e abate às saídas.
- Gráfico **entradas e saídas por mês** (sempre 12 meses; opção Detalhado por categoria/entidade).
- **Saldo por banco**, incluindo "Poupanças – referência".
- **Despesas por categoria** e **por referência**.
- **Rendimentos** (por entidade) e **Rendimentos por tipo** (referência), a partir das entradas do extrato; o que está ligado a um recibo aparece com ✓, o resto "por confirmar".
- **Por categorizar**: as descrições mais frequentes, com ⚡ para criar uma regra.

### Rendimentos
- **Recibos de vencimento em PDF** (lidos com pdf.js): bruto, IRS retido, SS, subsídio no cartão, líquido.
  - Duplicados detetados pelo n.º do recibo.
  - Guardam-se só os valores, nunca o PDF.
- **Rendimentos pontuais** (prémios, rendas…).
- **Ligação automática ao extrato**: o líquido liga à entrada no banco e o subsídio liga à conta do cartão refeição (links 🔗 nos dois sentidos).
- **Resumo anual** por mês (maximizar/minimizar), com filtro por entidade.
- Os Extratos são a fonte do **dinheiro** que entra; os Rendimentos são a visão **fiscal** (bruto, IRS, SS).

### Despesas
- **Grelha de 12 meses** (a mesma em Mês e Ano): o ano começa no mês escolhido em Definições › Geral e o mês do período fica destacado.
- Linhas: categorias (abrem/fecham) e referências; colunas: meses (saídas − reembolsos), **Total**, **Média** (total ÷ meses com movimentos) e **Previsão** (mensal, editável). Acima da previsão fica a vermelho; clicar num valor abre os Extratos filtrados.
- Por baixo, a mesma grelha para as **categorias fora das contas** (entradas − saídas).
- **Modo Editar**: ordenar (↑↓), acrescentar ou apagar categorias e referências.

### Outras abas
Em Definições › 👪 Agregado familiar cria-se uma conta partilhada e convidam-se pessoas pelo email. Previsões tem as **despesas previstas por ano** (média/mês ou total do ano por referência, com os últimos 3 anos ao lado). Faturas e Saúde financeira existem mas ainda estão **em preparação** (ver ROADMAP). As cores das categorias escolhem-se em Despesas › Editar e as opções de pintura em Definições › Geral. Cada referência tem um **tipo de despesa** (Despesas › Editar); os tipos gerem-se em Definições › Tipos de despesa.

### 🧮 Como foi calculado
As caixas do Início, Despesas e Rendimentos têm um ícone 🧮 que abre um painel lateral com a fórmula, os movimentos que contam (a soma dá o valor da caixa) e os que ficaram de fora, agrupados pelo motivo (entre contas, fora das contas, reembolso, por categorizar). Clicar numa linha leva ao movimento. O ícone esconde-se em Definições › Geral.

### Estado da página
Ao atualizar a página fica tudo igual: aba, período, pesquisa e filtros, posição, secções abertas. Guarda-se no `sessionStorage` (`fp_estado_financas`).

Os valores mostram sempre o separador de milhares (`1 234,56 €`).

---

## Dados e sincronização

- **Sem sessão**: tudo funciona e os dados ficam **só no browser** (`localStorage`, chave `financas_v1`).
- **Com sessão**: os dados ficam na **conta** (Supabase) e sincronizam entre dispositivos.
  - Um registo por utilizador na tabela `public.financas_dados`, com `ferramenta = 'financas'` e `chave = 'estado'`; o campo `dados` é um JSONB com o estado todo.
  - Ao juntar versões de dois dispositivos (`junta()`), cada movimento fica com a edição mais recente (`u` = hora da edição).
  - Os movimentos apagados num dispositivo não reaparecem vindos do outro, e um movimento reposto também não volta a desaparecer.

Principais campos do estado (`DB`):

| Campo | Conteúdo |
|---|---|
| `mov` | movimentos: `id`, `banco`, `conta`, `dm`/`dv` (datas ISO), `desc`, `desc0`, `valor`, `saldo`, `cat`, `ref`, `catSrc` (manual/regra/rend), `det`, `obs`, `quem`, `partes` (divisão), `reemb` (chave da despesa original), `man`/`k` (dinheiro), `u` |
| `imports` | importações feitas (ficheiro, banco, período, novos, duplicados) |
| `rend` / `delR` | rendimentos (recibos e pontuais) / ids apagados |
| `cats`, `regras`, `pessoas` | categorias › referências, regras de categorização, pessoas |
| `prev`, `esp` | valores previstos / regras especiais (nome, tipo, referências; `refSo` é o formato antigo) |
| `del`, `delImp`, `delM`, `rep` | chaves apagadas (para sempre), apagadas por remover importação, últimos 50 apagados completos, reposições |

### Segurança
- **Row Level Security** em `financas_dados`: cada utilizador só lê e escreve as suas linhas (`auth.uid() = user_id`).
- No código só existe a **chave pública** do Supabase (via `plataforma-core`). Passwords, service keys ou outras credenciais **nunca** vão para o GitHub nem para o browser.
- Os sites externos nos separadores nunca recebem a sessão.
- Extratos, recibos e outros dados reais **nunca** entram no repositório; os testes usam só dados fictícios.

---

## Desenvolvimento

### Processo (ver `CLAUDE.md`)
1. Esclarecer o pedido antes de mexer.
2. Confirmar que não contraria nenhuma **decisão fixa** do `PATCH NOTES.md`; se contrariar, avisar e pedir confirmação.
3. Implementar.
4. Correr os testes (0 falhas).
5. Registar no `PATCH NOTES.md`: letra seguinte (`v0.7q` → `v0.7r`) para ajustes, `v0.8`, `v0.9`… para versões do roadmap. Regras novas passam a decisões fixas (com teste, se possível).
6. Atualizar `APP_VERSAO` em `financas.html` (aparece no menu da conta).
7. Commit e push para `main` (publica sozinho) e verificar o site.

### Testes
```bash
NODE_PATH=$(npm root -g) node tests/regressao.cjs
```
Os testes abrem o site com o Playwright (Chromium) e importam os extratos fictícios de `tests/fixtures`. Cada teste tem o código de uma **decisão fixa** (D01, D08c, D18, …): se um falhar, alguma regra combinada foi quebrada.

### Correr localmente
Abrir `public/index.html` no browser, ou servir a pasta (`npx serve public`). Cada HTML também funciona sozinho.

### Publicação
O Cloudflare publica a cada push para `main` (`npx wrangler deploy`, versão do Wrangler fixada em `package.json`). O domínio `financas.frisk.pt` está em `wrangler.jsonc`.

### Supabase
A tabela foi criada no projeto **Sites** (`aehitgqsfcpzuunyzpsh`) com `supabase/001_financas_dados.sql`, e o site está registado em `public.sites` com o id `financas`. Os separadores podem ler o utilizador em `window.parent.financasUser` (ou ouvir a mensagem `financas-sessao`).

### Bibliotecas
- `public/lib/`: pdf.js 3.11 (Mozilla, Apache-2.0) e SheetJS 0.18.5 (Apache-2.0), carregados só quando se lê um PDF ou um Excel.
- Nenhuma outra dependência no browser além do `auth.js` da plataforma.
