#!/bin/bash

#==============================================================================
# SCRIPT MARIADB MANAGER - BANANA PI M5 / UBUNTU 24.04
#==============================================================================
# Nome: mariadbmanager.sh
# Versão: 1.0
# Descrição: Script para instalar, configurar e desinstalar MariaDB Server
# Compatibilidade: Banana Pi M5 (aarch64) + Ubuntu 24.04 (Noble)
# Usuário: server (contexto)
#==============================================================================

# Configurações globais
SCRIPT_NAME="MariaDB Manager"
SCRIPT_VERSION="1.0"
TARGET_USER="server"

# Cores para output (baseado nos scripts anteriores)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Símbolos
OK="✓"
ERR="✗"
WARN="!"
INFO="ℹ"

# FUNÇÕES BÁSICAS
#==============================================================================

# Função para mensagens coloridas
msg() {
    case "$1" in
        "ok")   echo -e "${GREEN}${OK} $2${NC}" ;;
        "err")  echo -e "${RED}${ERR} $2${NC}" ;;
        "warn") echo -e "${YELLOW}${WARN} $2${NC}" ;;
        "info") echo -e "${BLUE}${INFO} $2${NC}" ;;
        "title") echo -e "${PURPLE}$2${NC}" ;;
        "cyan") echo -e "${CYAN}$2${NC}" ;;
        *) echo "$2" ;;
    esac
}

# Verificar se é root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        msg "err" "Este script deve ser executado como root"
        msg "info" "Use: sudo $0"
        exit 1
    fi
}

# Atualizar sistema
update_system() {
    msg "info" "Atualizando lista de pacotes..."
    apt update -qq
    if [[ $? -ne 0 ]]; then
        msg "err" "Falha ao atualizar lista de pacotes."
        return 1
    fi
    msg "ok" "Lista de pacotes atualizada"
}

# FUNÇÕES DE INSTALAÇÃO E SEGURANÇA
#==============================================================================

# Instalar MariaDB
install_mariadb() {
    msg "title" "=== INSTALANDO MARIADB SERVER ==="
    
    # Verificar se MariaDB já está instalado
    if systemctl is-active --quiet mariadb; then
        msg "warn" "MariaDB já está instalado e ativo."
        return 0
    fi
    
    update_system || return 1
    
    msg "info" "Instalando MariaDB Server e cliente..."
    apt install -y mariadb-server mariadb-client
    
    if [[ $? -eq 0 ]]; then
        msg "ok" "MariaDB instalado com sucesso."
        systemctl enable mariadb
        systemctl start mariadb
        msg "ok" "MariaDB iniciado e habilitado."
    else
        msg "err" "Falha na instalação do MariaDB."
        return 1
    fi
}

# Executar a instalação de segurança interativa
secure_mariadb_installation() {
    msg "title" "=== INSTALAÇÃO DE SEGURANÇA DO MARIADB ==="
    
    if ! systemctl is-active --quiet mariadb; then
        msg "err" "MariaDB não está ativo. Inicie o serviço primeiro."
        return 1
    fi
    
    msg "warn" "O script 'mysql_secure_installation' será executado."
    msg "info" "Você será guiado pelas seguintes etapas:"
    echo "  1. Definir a senha do usuário root (ou usar autenticação por socket)."
    echo "  2. Remover usuários anônimos."
    echo "  3. Desabilitar login remoto do root."
    echo "  4. Remover o banco de dados de teste."
    echo "  5. Recarregar tabelas de privilégios."
    echo
    msg "info" "Recomendação: Basta pressionar ENTER nas primeiras perguntas (como a autenticação do root no Ubuntu 24.04 usa socket, o campo de senha atual estará vazio) e aceitar as opções padrão (Y/Sim) para as demais."
    echo
    read -p "Pressione ENTER para iniciar a instalação de segurança..."
    
    # Executa o script interativo
    mysql_secure_installation
    
    if [[ $? -eq 0 ]]; then
        msg "ok" "Instalação de segurança do MariaDB concluída."
    else
        msg "err" "Falha ou cancelamento na execução da instalação de segurança."
    fi
}

# Instalação completa
full_install_mariadb() {
    msg "title" "=== INSTALAÇÃO COMPLETA DO MARIADB ==="
    
    install_mariadb || return 1
    
    secure_mariadb_installation
    
    msg "ok" "MariaDB instalado e segurança configurada."
    msg "info" "Para gerenciar o banco de dados, use:"
    msg "cyan" "sudo mariadb"
    msg "cyan" "ou"
    msg "cyan" "sudo mysql"
}

# FUNÇÕES DE DESINSTALAÇÃO
#==============================================================================

# Desinstalar MariaDB
uninstall_mariadb() {
    msg "title" "=== DESINSTALANDO MARIADB SERVER ==="
    
    msg "warn" "ATENÇÃO: Esta operação irá:"
    echo "  • Parar e desinstalar o MariaDB Server e cliente."
    echo "  • Remover TODAS as configurações e DADOS (diretório /var/lib/mysql)."
    echo
    read -p "Tem certeza? Digite 'APAGAR DADOS' para confirmar: " confirm
    
    if [[ "$confirm" != "APAGAR DADOS" ]]; then
        msg "info" "Operação cancelada"
        return 0
    fi
    
    msg "info" "Parando MariaDB..."
    systemctl stop mariadb 2>/dev/null
    systemctl disable mariadb 2>/dev/null
    
    msg "info" "Removendo pacotes MariaDB e seus arquivos de configuração..."
    # A opção --purge remove também os arquivos de configuração
    apt remove --purge -y mariadb-server mariadb-client mariadb-common
    apt autoremove -y
    
    # Remover o diretório de dados, mesmo que não vazio
    msg "info" "Removendo diretório de dados /var/lib/mysql (permanente)..."
    rm -rf /var/lib/mysql
    
    # Remover diretório de log
    msg "info" "Removendo diretório de logs /var/log/mysql..."
    rm -rf /var/log/mysql
    
    msg "ok" "MariaDB completamente desinstalado e dados removidos."
}

# INTERFACE DO MENU
#==============================================================================

show_menu() {
    clear
    msg "title" "=================================================="
    msg "title" "   MARIADB MANAGER - BANANA PI M5 / UBUNTU 24.04"
    msg "title" "=================================================="
    echo
    echo "1) Instalar MariaDB Server e Cliente + Segurança"
    echo "2) Desinstalar MariaDB (remove tudo e apaga dados!)"
    echo "3) Executar Instalação de Segurança (mysql_secure_installation)"
    echo "4) Status do MariaDB"
    echo "5) Reiniciar MariaDB"
    echo "0) Sair"
    echo
}

# Status do MariaDB
show_status() {
    msg "title" "=== STATUS DO MARIADB ==="
    
    if systemctl is-active --quiet mariadb; then
        msg "ok" "MariaDB está ATIVO"
        echo
        systemctl status mariadb --no-pager -l
    else
        msg "err" "MariaDB está INATIVO"
    fi
    
    echo
    read -p "Pressione Enter para continuar..."
}

# Reiniciar MariaDB
restart_mariadb() {
    msg "info" "Reiniciando MariaDB..."
    
    if systemctl restart mariadb; then
        msg "ok" "MariaDB reiniciado com sucesso"
    else
        msg "err" "Falha ao reiniciar MariaDB"
    fi
    
    echo
    read -p "Pressione Enter para continuar..."
}

# Processar escolha do menu
process_choice() {
    case "$1" in
        1) full_install_mariadb ;;
        2) uninstall_mariadb ;;
        3) secure_mariadb_installation ;;
        4) show_status ;;
        5) restart_mariadb ;;
        0) msg "info" "Saindo..."; exit 0 ;;
        *) msg "err" "Opção inválida" ;;
    esac
    
    # Pausa após opções que não sejam de status/reinício
    if [[ "$1" != "4" && "$1" != "5" ]]; then
        echo
        read -p "Pressione Enter para voltar ao menu..."
    fi
}

# FUNÇÃO PRINCIPAL
#==============================================================================

main() {
    # Verificações iniciais
    check_root
    
    while true; do
        show_menu
        read -p "Escolha uma opção: " choice
        echo
        process_choice "$choice"
    done
}

# Executar se chamado diretamente
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"