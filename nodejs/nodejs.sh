#!/bin/bash

# Nome do script
NOME_ARQUIVO="gerenciar_node.sh"
# Pasta onde o Node.js e NPM geralmente instalam binários globais
PASTA_NODE_GLOBAL="/usr/bin/node"

# Função para exibir o cabeçalho do menu
function exibir_cabecalho() {
    clear
    echo "================================================="
    echo " Gerenciador de Node.js e NPM (Banana Pi M5/Ubuntu 24.04)"
    echo " Arquitetura: aarch64/arm64"
    echo "================================================="
}

# Função para exibir o menu principal
function menu_principal() {
    exibir_cabecalho
    echo "Escolha uma opção:"
    echo "1) Instalar Node.js e NPM (Usando NodeSource LTS)"
    echo "2) Desinstalar Node.js e NPM (Remove pacotes e pastas)"
    echo "0) Sair"
    echo "-------------------------------------------------"
    read -p "Opção: " opcao
    echo "-------------------------------------------------"
}

# Função de Instalação
function instalar_nodejs() {
    exibir_cabecalho
    echo "-> INICIANDO INSTALAÇÃO DO NODE.JS E NPM (NodeSource LTS) PARA TODOS OS USUÁRIOS..."
    echo "   * Será instalada a versão LTS mais recente (recomendado para produção)."
    
    # Verifica se já está instalado (uma verificação simples, pode ser mais complexa)
    if command -v node &> /dev/null; then
        echo "   [!] Node.js já parece estar instalado. Versão: $(node -v). O script continuará a instalação/atualização via NodeSource."
        sleep 2
    fi

    # 1. Atualiza a lista de pacotes
    echo "1. Atualizando a lista de pacotes..."
    sudo apt update
    if [ $? -ne 0 ]; then
        echo "   [ERRO] Falha ao atualizar a lista de pacotes. Abortando."
        return 1
    fi
    
    # 2. Instala dependências (curl é necessário para o script do NodeSource)
    echo "2. Instalando dependências (curl)..."
    sudo apt install -y curl
    if [ $? -ne 0 ]; then
        echo "   [ERRO] Falha ao instalar curl. Abortando."
        return 1
    fi

    # 3. Adiciona o repositório NodeSource (usando a versão LTS mais recente)
    # curl | bash é um padrão para adicionar PPA. -E para manter o ambiente root,
    # importante em alguns sistemas para o script de setup.
    echo "3. Adicionando o repositório NodeSource LTS..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    if [ $? -ne 0 ]; then
        echo "   [ERRO] Falha ao adicionar o repositório NodeSource. Abortando."
        return 1
    fi

    # 4. Instala o Node.js (que inclui o NPM)
    echo "4. Instalando nodejs e npm..."
    # O pacote no NodeSource se chama 'nodejs' e inclui o npm.
    sudo apt install -y nodejs
    if [ $? -ne 0 ]; then
        echo "   [ERRO] Falha ao instalar nodejs. Abortando."
        return 1
    fi

    # 5. Verifica a instalação
    echo "5. Verificando a instalação:"
    node_v=$(node -v 2>/dev/null)
    npm_v=$(npm -v 2>/dev/null)
    
    if [ -n "$node_v" ] && [ -n "$npm_v" ]; then
        echo "   [SUCESSO] Node.js e NPM instalados com sucesso!"
        echo "   Versão Node.js: $node_v"
        echo "   Versão NPM:     $npm_v"
    else
        echo "   [ERRO] Verificação de instalação falhou. Tente novamente ou verifique a saída acima."
    fi
    
    read -p "Pressione [Enter] para continuar..."
}

# Função de Desinstalação
function desinstalar_nodejs() {
    exibir_cabecalho
    echo "-> INICIANDO DESINSTALAÇÃO DO NODE.JS E NPM..."
    echo "   * Isso removerá os pacotes e apagará pastas globais do NPM (mesmo que não estejam vazias)."
    
    read -p "Tem certeza que deseja desinstalar e APAGAR PASTAS (S/N)? " confirmacao
    
    if [[ "$confirmacao" =~ ^[Ss]$ ]]; then
        # 1. Remove os pacotes do Node.js e NPM (purge remove arquivos de configuração)
        echo "1. Removendo pacotes nodejs e npm..."
        # O pacote principal é 'nodejs', que inclui o npm.
        sudo apt purge -y nodejs
        # Remove quaisquer dependências que não são mais necessárias
        sudo apt autoremove -y

        # 2. Remove o PPA do NodeSource, se estiver presente
        echo "2. Removendo o repositório NodeSource, se presente..."
        # Remove o arquivo de lista do NodeSource (pode ter vários nomes, este é o mais comum)
        sudo rm -f /etc/apt/sources.list.d/nodesource.list*

        # 3. Atualiza a lista de pacotes após remover o PPA
        echo "3. Atualizando a lista de pacotes..."
        sudo apt update

        # 4. Apaga pastas globais do NPM (MESMO QUE NÃO ESTEJAM VAZIAS, conforme solicitado)
        # O diretório global de módulos (geralmente /usr/lib/node_modules ou similar)
        # e a pasta de binários (onde o link simbólico aponta)
        echo "4. Apagando pastas globais do NPM (ex: /usr/lib/node_modules) e links simbólicos..."
        
        # Encontra e remove o link simbólico principal (se ainda existir)
        if [ -L "$PASTA_NODE_GLOBAL" ] || [ -f "$PASTA_NODE_GLOBAL" ]; then
            sudo rm -rf "$PASTA_NODE_GLOBAL"
            echo "   Link/Arquivo $PASTA_NODE_GLOBAL removido."
        fi
        
        # Pasta de módulos global principal (onde módulos instalados globalmente ficam)
        # O local exato pode variar, mas /usr/lib/node_modules é comum.
        # Vamos usar a pasta de cache e a pasta de módulos, pois `apt purge` pode deixar resquícios.
        # Esta é a ação destrutiva solicitada, APAGAR PASTAS MESMO QUE NÃO VAZIAS.
        echo "   [ATENÇÃO] Removendo /usr/lib/node_modules e pastas de cache do npm..."
        sudo rm -rf /usr/lib/node_modules
        sudo rm -rf /var/lib/npm
        
        # Limpa o cache do npm de todos os usuários
        echo "   Limpando cache do NPM para o usuário atual (~/.npm)..."
        rm -rf ~/.npm

        # 5. Verifica a desinstalação
        echo "5. Verificando a desinstalação..."
        if ! command -v node &> /dev/null && ! command -v npm &> /dev/null; then
            echo "   [SUCESSO] Node.js e NPM removidos com sucesso!"
        else
            echo "   [AVISO] Os comandos 'node' e 'npm' ainda estão disponíveis ou a verificação falhou. Verifique manualmente."
        fi
    else
        echo "-> Desinstalação cancelada pelo usuário."
    fi
    
    read -p "Pressione [Enter] para continuar..."
}

# Loop principal do menu
while true; do
    menu_principal
    case $opcao in
        1)
            instalar_nodejs
            ;;
        2)
            desinstalar_nodejs
            ;;
        0)
            exibir_cabecalho
            echo "Saindo. Obrigado por usar o $NOME_ARQUIVO!"
            echo "================================================="
            exit 0
            ;;
        *)
            echo "Opção inválida. Tente novamente."
            sleep 1
            ;;
    esac
done