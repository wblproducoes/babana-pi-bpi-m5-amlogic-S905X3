#!/bin/bash

# Script de Atualização para Banana Pi M5 (aarch64) e Ubuntu 24.04 (Noble)
# Update Script for Banana Pi M5 (aarch64) and Ubuntu 24.04 (Noble)

# Verificar se está rodando como root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "Este script precisa ser executado como root (sudo)"
        echo "This script needs to be run as root (sudo)"
        exit 1
    fi
}

# Detectar arquitetura e sistema
detect_system() {
    ARCH=$(uname -m)
    OS_VERSION=$(lsb_release -rs 2>/dev/null || echo "Unknown")
    OS_CODENAME=$(lsb_release -cs 2>/dev/null || echo "Unknown")
    
    echo "=========================================="
    echo "Sistema Detectado / Detected System:"
    echo "Arquitetura / Architecture: $ARCH"
    echo "Versão OS / OS Version: $OS_VERSION"
    echo "Codinome / Codename: $OS_CODENAME"
    echo "=========================================="
    echo ""
    
    if [[ "$ARCH" != "aarch64" ]] && [[ "$OS_CODENAME" != "noble" ]]; then
        echo "AVISO: Este script foi otimizado para Banana Pi M5 (aarch64) e Ubuntu 24.04 (noble)"
        echo "WARNING: This script was optimized for Banana Pi M5 (aarch64) and Ubuntu 24.04 (noble)"
        echo ""
    fi
}

# Função para atualizar lista de pacotes
update_packages() {
    echo "=== Atualizando lista de pacotes / Updating package list ==="
    apt update -y
    echo "Lista de pacotes atualizada! / Package list updated!"
    echo ""
}

# Função para atualizar pacotes instalados
upgrade_packages() {
    echo "=== Atualizando pacotes instalados / Upgrading installed packages ==="
    apt upgrade -y
    echo "Pacotes atualizados! / Packages upgraded!"
    echo ""
}

# Função para atualização de distribuição
dist_upgrade_packages() {
    echo "=== Executando atualização de distribuição / Running distribution upgrade ==="
    apt dist-upgrade -y
    echo "Atualização de distribuição concluída! / Distribution upgrade completed!"
    echo ""
}

# Função para corrigir dependências
fix_dependencies() {
    echo "=== Corrigindo dependências / Fixing dependencies ==="
    apt install -f -y
    echo "Dependências corrigidas! / Dependencies fixed!"
    echo ""
}

# Função para remover pacotes desnecessários
autoremove_packages() {
    echo "=== Removendo pacotes desnecessários / Removing unnecessary packages ==="
    apt autoremove -y
    echo "Pacotes desnecessários removidos! / Unnecessary packages removed!"
    echo ""
}

# Função para limpar cache
autoclean_cache() {
    echo "=== Limpando cache / Cleaning cache ==="
    apt autoclean -y
    echo "Cache limpo! / Cache cleaned!"
    echo ""
}

# Função para atualização completa
full_update() {
    echo "=========================================="
    echo "ATUALIZAÇÃO COMPLETA / FULL UPDATE"
    echo "=========================================="
    update_packages
    upgrade_packages
    dist_upgrade_packages
    fix_dependencies
    autoremove_packages
    autoclean_cache
    echo "=========================================="
    echo "ATUALIZAÇÃO COMPLETA FINALIZADA!"
    echo "FULL UPDATE COMPLETED!"
    echo "=========================================="
}

# Função para reiniciar o sistema
restart_system() {
    echo "=========================================="
    echo "REINICIANDO SISTEMA / RESTARTING SYSTEM"
    echo "=========================================="
    echo "O sistema será reiniciado em 10 segundos..."
    echo "The system will restart in 10 seconds..."
    echo "Pressione Ctrl+C para cancelar / Press Ctrl+C to cancel"
    echo ""
    
    for i in {10..1}; do
        echo "Reiniciando em $i segundos... / Restarting in $i seconds..."
        sleep 1
    done
    
    echo "Reiniciando agora... / Restarting now..."
    reboot
}

# Função para desligar o sistema
shutdown_system() {
    echo "=========================================="
    echo "DESLIGANDO SISTEMA / SHUTTING DOWN SYSTEM"
    echo "=========================================="
    echo "O sistema será desligado em 10 segundos..."
    echo "The system will shutdown in 10 seconds..."
    echo "Pressione Ctrl+C para cancelar / Press Ctrl+C to cancel"
    echo ""
    
    for i in {10..1}; do
        echo "Desligando em $i segundos... / Shutting down in $i seconds..."
        sleep 1
    done
    
    echo "Desligando agora... / Shutting down now..."
    shutdown -h now
}

# Função para mostrar o menu
show_menu() {
    clear
    detect_system
    echo "=========================================="
    echo "  MENU DE ATUALIZAÇÃO / UPDATE MENU"
    echo "  Banana Pi M5 & Ubuntu 24.04"
    echo "=========================================="
    echo ""
    echo "1) Update (Atualizar lista de pacotes)"
    echo "2) Upgrade (Atualizar pacotes instalados)"
    echo "3) Dist-upgrade (Atualização de distribuição)"
    echo "4) Install -f (Corrigir dependências)"
    echo "5) Autoremove (Remover pacotes desnecessários)"
    echo "6) Autoclean (Limpar cache)"
    echo "7) ATUALIZAÇÃO COMPLETA (Todas as opções acima)"
    echo "8) Reiniciar Sistema / Restart System"
    echo "9) Desligar Sistema / Shutdown System"
    echo "0) Sair / Exit"
    echo ""
    echo "=========================================="
}

# Função principal
main() {
    check_root
    
    while true; do
        show_menu
        read -p "Escolha uma opção / Choose an option (0-9): " choice
        echo ""
        
        case $choice in
            1)
                update_packages
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
            2)
                upgrade_packages
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
            3)
                dist_upgrade_packages
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
            4)
                fix_dependencies
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
            5)
                autoremove_packages
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
            6)
                autoclean_cache
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
            7)
                full_update
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
            8)
                restart_system
                ;;
            9)
                shutdown_system
                ;;
            0)
                echo "Saindo... / Exiting..."
                exit 0
                ;;
            *)
                echo "Opção inválida! / Invalid option!"
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
        esac
    done
}

# Executar função principal
main