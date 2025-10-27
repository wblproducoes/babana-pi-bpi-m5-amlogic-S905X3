# Gerenciador de Node.js e NPM (nodejs.sh)

**Prompt Original:**

> crie um script em bash (com menu onde a opção 0 é de sair e/ou voltar) com o mesmo nome para funcionanr no banana pi m5 com arquitetura de aarch64 e no ubuntu 24.04 (noble) que instale e desistele ( e apague a pasta mesmo que ela não esteja vazia) o nodejs e npm. A instalação deve servir para todos os usuário do servidor. Crie também um arquivo .md com o mesmo nome com a explicação linha a linha e função a função e com esse prompt original. E no fina do arquivo crie "rm -rf arquivo.sh;nano arquivo.sh;chmod +x arquivo.sh;bash arquivo.sh" trocando arquivo pelo o nome de arquivo;

## Explicação do Script Bash (`nodejs.sh`)

O script utiliza funções para modularizar o código, um loop `while` para manter o menu ativo e comandos `sudo` para garantir que as operações de instalação e desinstalação afetem todo o sistema (todos os usuários), o que é essencial para um servidor.

### Variáveis e Inicialização

| Linha(s) | Código | Explicação |
|---|---|---|
| `3` | `NOME_ARQUIVO="nodejs.sh"` | Define uma variável para o nome do script, usada na mensagem de saída. |
| `5` | `PASTA_NODE_GLOBAL="/usr/bin/node"` | Define a localização do binário principal do Node.js, usada para verificação/remoção. |

### Função `exibir_cabecalho()`

| Linha(s) | Código | Explicação |
|---|---|---|
| `8-14` | `function exibir_cabecalho() { ... }` | Limpa a tela (`clear`) e exibe um cabeçalho formatado para o menu, incluindo a arquitetura alvo (aarch64/arm64) e o sistema operacional (Ubuntu 24.04). |

### Função `menu_principal()`

| Linha(s) | Código | Explicação |
|---|---|---|
| `17-25` | `function menu_principal() { ... }` | Exibe as opções disponíveis para o usuário (Instalar, Desinstalar, Sair). Usa `read -p` para capturar a escolha do usuário na variável `opcao`. |

### Função `instalar_nodejs()`

Esta função é responsável por adicionar o repositório oficial do NodeSource e instalar o Node.js e o NPM, garantindo que seja feito de forma global (com `sudo`).

| Linha(s) | Código | Explicação |
|---|---|---|
| `28-36` | `function instalar_nodejs() { ... }` | Verifica se o `node` já está no PATH e exibe um aviso se estiver. |
| `39-43` | `sudo apt update; if [ $? -ne 0 ]; ...` | Atualiza o índice de pacotes do APT. O `$? -ne 0` verifica se o comando anterior falhou (código de saída diferente de zero). |
| `45-49` | `sudo apt install -y curl; if [ $? -ne 0 ]; ...` | Instala o `curl`, necessário para baixar o script de configuração do NodeSource. |
| `52-56` | `curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -; if [ $? -ne 0 ]; ...` | Baixa e executa o script de configuração do NodeSource (LTS - Long Term Support). O `sudo -E bash -` executa o script com privilégios de root, garantindo que o novo PPA (repositório) seja adicionado ao sistema. |
| `59-63` | `sudo apt install -y nodejs; if [ $? -ne 0 ]; ...` | Instala o pacote `nodejs`, que inclui o Node.js e o NPM (no NodeSource, o npm é empacotado junto). A instalação via `sudo` garante que seja global. |
| `66-74` | `node_v=$(node -v 2>/dev/null); ...` | Verifica as versões instaladas do Node.js e NPM e exibe uma mensagem de sucesso ou erro. |
| `76` | `read -p "Pressione [Enter] para continuar..."` | Pausa a execução para que o usuário possa ler a saída. |

### Função `desinstalar_nodejs()`

Esta função é responsável por remover o Node.js, o NPM, o PPA do NodeSource e **apagar as pastas globais do NPM, mesmo que não estejam vazias**, conforme solicitado.

| Linha(s) | Código | Explicação |
|---|---|---|
| `79-84` | `function desinstalar_nodejs() { ... }` | Exibe o cabeçalho e um aviso, solicitando confirmação para a ação de desinstalação e remoção de pastas. |
| `86` | `if [[ "$confirmacao" =~ ^[Ss]$ ]]; then` | Processa apenas se o usuário digitar 'S' ou 's'. |
| `89-92` | `sudo apt purge -y nodejs; sudo apt autoremove -y` | Remove o pacote `nodejs` e seus arquivos de configuração (`purge`), e remove as dependências que não são mais necessárias (`autoremove`). |
| `95-96` | `sudo rm -f /etc/apt/sources.list.d/nodesource.list*` | Remove o arquivo de configuração do repositório NodeSource, se ele existir. |
| `99-100` | `sudo apt update` | Atualiza o índice de pacotes após remover o PPA. |
| `104-107` | `if [ -L "$PASTA_NODE_GLOBAL" ] || [ -f "$PASTA_NODE_GLOBAL" ]; then ...` | Verifica e remove o link simbólico ou arquivo principal do Node.js. |
| `112-114` | `sudo rm -rf /usr/lib/node_modules; sudo rm -rf /var/lib/npm;` | **Ação crítica:** Remove recursivamente (`-r`) e forçadamente (`-f`) os diretórios globais do NPM (`/usr/lib/node_modules`) e a pasta de dados/cache do NPM (`/var/lib/npm`). O `rm -rf` apaga pastas mesmo que não vazias, conforme solicitado. |
| `117-118` | `rm -rf ~/.npm` | Remove o cache do NPM do **usuário atual**. |
| `121-125` | `if ! command -v node &> /dev/null ...` | Verifica se os comandos `node` e `npm` não existem mais no PATH após a desinstalação. |
| `127-129` | `else ...` | Mensagem de cancelamento se o usuário não confirmar a desinstalação. |
| `131` | `read -p "Pressione [Enter] para continuar..."` | Pausa a execução para que o usuário possa ler a saída. |

### Loop Principal (`while true`)

| Linha(s) | Código | Explicação |
|---|---|---|
| `134` | `while true; do` | Inicia um loop infinito para manter o menu ativo. |
| `135` | `menu_principal` | Chama a função que exibe as opções e lê a escolha do usuário. |
| `136-150` | `case $opcao in ... esac` | Estrutura de controle que executa a função correspondente à opção escolhida: `1` instala, `2` desinstala e `0` sai do script (`exit 0`). Opções inválidas exibem uma mensagem de erro. |

---

## Como Usar o Script

Para criar e executar o script no seu terminal, use a seguinte sequência de comandos (substituindo `arquivo` por `nodejs`):

```bash
rm -rf nodejs.sh;nano nodejs.sh;chmod +x nodejs.sh;bash nodejs.sh