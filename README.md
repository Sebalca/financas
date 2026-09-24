# Finanças Pessoais

Conjunto de ferramentas HTML offline, cada uma num ficheiro próprio, reunidas por separadores no topo.

| Ficheiro | Conteúdo |
|---|---|
| `public/index.html` | Página principal com a barra de separadores |
| `public/simulador-salarial.html` | Simulador salarial 2026 (Pessoas, Empresas, Unipessoal, Esquema) |
| `public/financas.html` | Finanças (em construção) |

## Usar
Abrir `index.html` no browser (os ficheiros têm de estar na mesma pasta). Cada HTML também funciona sozinho.

Link direto para um separador: `index.html#simulador`, `index.html#financas`.

## Adicionar um separador
1. Criar o novo ficheiro HTML nesta pasta.
2. Acrescentar uma linha à lista `SEPARADORES` em `index.html`:
   ```js
   {id:'novo', nome:'Nome do separador', ficheiro:'novo.html'}
   ```

## GitHub Pages
Publicar a pasta num repositório e ativar GitHub Pages (branch `main`, pasta raiz). O `index.html` passa a ser a página inicial.

## Contas (Supabase)
O login é **opcional** e usa as mesmas contas dos outros sites `*.frisk.pt`, através do `auth.js` partilhado (`sebalca/plataforma-core`). Sem sessão, tudo funciona e os dados ficam só no browser.

Os dados deste site ficam numa tabela própria, `public.financas_dados` (um registo por utilizador / ferramenta / chave, com RLS: cada utilizador só acede aos seus dados).

A tabela já foi criada no projeto Supabase **Sites** (`aehitgqsfcpzuunyzpsh`) com `supabase/001_financas_dados.sql`, e o site está registado em `public.sites` com o id `financas`.

Os separadores podem ler o utilizador com sessão em `window.parent.financasUser` (ou ouvir a mensagem `financas-sessao`).

## Publicação (Cloudflare Workers)
O site é publicado pelo Cloudflare a cada `push` para `main` (comando `npx wrangler deploy`). Configuração em `wrangler.jsonc`: os ficheiros servidos estão na pasta `public/` e o domínio é `financas.frisk.pt`. A versão do Wrangler está fixada em `package.json`.

## Plano
Ver [ROADMAP.md](ROADMAP.md).
