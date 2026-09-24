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
