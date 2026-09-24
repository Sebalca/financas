# Finanças Pessoais

Conjunto de ferramentas HTML offline, cada uma num ficheiro próprio, reunidas por separadores no topo.

| Ficheiro | Conteúdo |
|---|---|
| `index.html` | Página principal com a barra de separadores |
| `simulador-salarial.html` | Simulador salarial 2026 (Pessoas, Empresas, Unipessoal, Esquema) |
| `financas.html` | Finanças (em construção) |

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

Criar a tabela (uma vez): abrir o **SQL Editor** do projeto Supabase da plataforma e correr `supabase/001_financas_dados.sql`.

Os separadores podem ler o utilizador com sessão em `window.parent.financasUser` (ou ouvir a mensagem `financas-sessao`).
