#!/bin/bash

#==============================================================================
# SCRIPT PROFTPD MANAGER - BANANA PI M5 / UBUNTU 24.04
#==============================================================================
# Nome: proftpdmanager.sh
# Versão: 1.1 (Correção de Chroot)
# Descrição: Script para instalar, configurar (chroot) e desinstalar ProFTPD
# Compatibilidade: Banana Pi M5 (aarch64) + Ubuntu 24.04 (Noble)
# Usuário: server (contexto)
#==============================================================================

# Configurações globais
SCRIPT_NAME="ProFTPD Manager"
SCRIPT_VERSION="1.1"
TARGET_USER="server"
USER_HOME="/home/$TARGET_USER"

# Arquivos de configuração
PROFTPD_CONF="/etc/proftpd/proftpd.conf"
PROFTPD_PACKAGE="proftpd-basic"

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

# FUNÇÕES DE INSTALAÇÃO E CONFIGURAÇÃO
#==============================================================================

# Instalar ProFTPD
install_proftpd() {
    msg "title" "=== INSTALANDO PROFTPD SERVER ==="
    
    if systemctl is-active --quiet proftpd; then
        msg "warn" "ProFTPD já está instalado e ativo."
        configure_chroot # Se já instalado, garante o chroot
        return 0
    fi
    
    update_system || return 1
    
    msg "info" "Instalando pacote $PROFTPD_PACKAGE..."
    
    export DEBIAN_FRONTEND=noninteractive
    apt install -y "$PROFTPD_PACKAGE"
    export DEBIAN_FRONTEND=
    
    if [[ $? -eq 0 ]]; then
        msg "ok" "ProFTPD instalado com sucesso."
        configure_chroot || return 1
    else
        msg "err" "Falha na instalação do ProFTPD."
        return 1
    fi
}

# Configurar ProFTPD para restringir usuários às suas pastas home (chroot) - CORRIGIDO
configure_chroot() {
    msg "title" "=== CONFIGURANDO CHROOT NO PROFTPD ==="
    
    if [[ ! -f "$PROFTPD_CONF" ]]; then
        msg "err" "Arquivo de configuração ProFTPD não encontrado: $PROFTPD_CONF"
        return 1
    fi
    
    msg "info" "Garantindo DefaultRoot ~ (Chroot) está configurado..."

    # 1. Configurar DefaultRoot ~: Substitui qualquer linha 'DefaultRoot' (comentada ou não) pela correta.
    if grep -qE "^\s*#?\s*DefaultRoot" "$PROFTPD_CONF"; then
        # Usa 'c' (change) no sed para substituir a linha existente, garantindo que não está comentada.
        sed -i '/^\s*#\?\s*DefaultRoot/c\DefaultRoot ~' "$PROFTPD_CONF"
        msg "ok" "DefaultRoot ~ (Chroot) substituído."
    else
        # Se não existe, injeta DefaultRoot ~ após ServerType standalone (ponto comum no início do arquivo).
        sed -i '/ServerType standalone/a DefaultRoot ~' "$PROFTPD_CONF"
        msg "ok" "DefaultRoot ~ (Chroot) injetado."
    fi

    # 2. Desabilitar RequireValidShell: Isso é crucial para usuários FTP com shell /bin/false.
    msg "info" "Desabilitando RequireValidShell para permitir usuários FTP/chroot..."
    if grep -qE "^\s*#?\s*RequireValidShell" "$PROFTPD_CONF"; then
        # Substitui a linha existente por 'RequireValidShell off'
        sed -i 's/^\s*#\?\s*RequireValidShell.*/RequireValidShell off/' "$PROFTPD_CONF"
        msg "ok" "RequireValidShell definido para 'off'."
    else
        # Injeta 'RequireValidShell off' após DefaultRoot
        sed -i '/DefaultRoot/a RequireValidShell off' "$PROFTPD_CONF"
        msg "ok" "RequireValidShell off injetado."
    fi

    # 3. Reiniciar o serviço
    msg "info" "Testando e reiniciando ProFTPD..."
    
    if service proftpd restart; then
        msg "ok" "ProFTPD configurado (Chroot ativado) e reiniciado com sucesso."
        msg "info" "Usuários locais agora só poderão acessar sua pasta home ($USER_HOME/)"
        msg "warn" "Lembre-se: Usuários devem ter permissão de login no sistema para usar o FTP."
    else
        msg "err" "Falha ao reiniciar ProFTPD. Verifique os logs."
        return 1
    fi
}

# Instalação completa
full_install_proftpd() {
    msg "title" "=== INSTALAÇÃO COMPLETA DO PROFTPD ==="
    
    install_proftpd || return 1
    
    msg "ok" "ProFTPD instalado e pronto. Usuários restritos ao seu diretório home."
    msg "cyan" "Certifique-se de que a porta 21/TCP (e as portas passivas, se configuradas) estejam liberadas no firewall."
}

# FUNÇÕES DE DESINSTALAÇÃO
#==============================================================================

# Desinstalar ProFTPD
uninstall_proftpd() {
    msg "title" "=== DESINSTALANDO PROFTPD SERVER ==="
    
    msg "warn" "ATENÇÃO: Esta operação irá:"
    echo "  • Parar e desinstalar o ProFTPD Server."
    echo "  • Remover TODAS as configurações e arquivos de sistema."
    echo
    read -p "Tem certeza? Digite 'REMOVER' para confirmar: " confirm
    
    if [[ "$confirm" != "REMOVER" ]]; then
        msg "info" "Operação cancelada"
        return 0
    fi
    
    msg "info" "Parando ProFTPD..."
    systemctl stop proftpd 2>/dev/null
    systemctl disable proftpd 2>/dev/null
    
    msg "info" "Removendo pacote $PROFTPD_PACKAGE e suas configurações..."
    apt remove --purge -y "$PROFTPD_PACKAGE"
    apt autoremove -y
    
    # Remover o diretório de configuração remanescente
    msg "info" "Removendo diretório de configuração /etc/proftpd..."
    rm -rf /etc/proftpd
    
    # Remover diretório de log
    msg "info" "Removendo diretório de logs /var/log/proftpd..."
    rm -rf /var/log/proftpd
    
    msg "ok" "ProFTPD completamente desinstalado."
}

# INTERFACE DO MENU
#==============================================================================

show_menu() {
    clear
    msg "title" "=================================================="
    msg "title" "   PROFTPD MANAGER - BANANA PI M5 / UBUNTU 24.04"
    msg "title" "=================================================="
    echo
    msg "cyan" "Protocolo: FTP/FTPS"
    msg "cyan" "Segurança: CHROOT (Usuário restrito ao Home) - ATIVO"
    echo
    echo "1) Instalar e Configurar ProFTPD (Com Chroot)"
    echo "2) Desinstalar ProFTPD (remove tudo)"
    echo "3) Status do ProFTPD"
    echo "4) Reiniciar ProFTPD"
    echo "5) Re-aplicar Configuração Chroot"
    echo "0) Sair"
    echo
}

# Status e Reinício (funções show_status e restart_proftpd inalteradas)
show_status() {
    msg "title" "=== STATUS DO PROFTPD ==="
    
    if systemctl is-active --quiet proftpd; then
        msg "ok" "ProFTPD está ATIVO"
        echo
        systemctl status proftpd --no-pager -l
    else
        msg "err" "ProFTPD está INATIVO"
    fi
    
    echo
    read -p "Pressione Enter para continuar..."
}

restart_proftpd() {
    msg "info" "Reiniciando ProFTPD..."
    
    if systemctl restart proftpd; then
        msg "ok" "ProFTPD reiniciado com sucesso"
    else
        msg "err" "Falha ao reiniciar ProFTPD"
    fi
    
    echo
    read -p "Pressione Enter para continuar..."
}


# Processar escolha do menu
process_choice() {
    case "$1" in
        1) full_install_proftpd ;;
        2) uninstall_proftpd ;;
        3) show_status ;;
        4) restart_proftpd ;;
        5) configure_chroot ;;
        0) msg "info" "Saindo..."; exit 0 ;;
        *) msg "err" "Opção inválida" ;;
    esac
    
    # Pausa após opções que não sejam de status/reinício
    if [[ "$1" != "3" && "$1" != "4" ]]; then
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