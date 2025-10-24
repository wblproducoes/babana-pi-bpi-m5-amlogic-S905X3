#!/bin/bash

# Script de Instalação/Desinstalação de Pacotes Básicos para Banana Pi M5 (aarch64) e Ubuntu 24.04 (Noble)
# Basic Package Installation/Uninstallation Script for Banana Pi M5 (aarch64) and Ubuntu 24.04 (Noble)

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

# Lista de pacotes
PACKAGES="curl unzip unrar git ufw wget"

# Função para instalar pacotes
install_packages() {
    echo "=== Instalando Pacotes Básicos / Installing Basic Packages ==="
    echo "Pacotes a instalar / Packages to install: $PACKAGES"
    echo ""
    
    # Atualizar lista de pacotes primeiro
    echo "Atualizando lista de pacotes / Updating package list..."
    apt update -y
    echo ""
    
    # Instalar cada pacote
    for package in $PACKAGES; do
        echo "Instalando / Installing: $package"
        apt install -y $package
        if [[ $? -eq 0 ]]; then
            echo "✓ $package instalado com sucesso / installed successfully"
        else
            echo "✗ Erro ao instalar / Error installing $package"
        fi
        echo ""
    done
    
    echo "=========================================="
    echo "INSTALAÇÃO CONCLUÍDA / INSTALLATION COMPLETED"
    echo "=========================================="
}

# Função para desinstalar pacotes
uninstall_packages() {
    echo "=== Desinstalando Pacotes Básicos / Uninstalling Basic Packages ==="
    echo "Pacotes a remover / Packages to remove: $PACKAGES"
    echo ""
    
    # Confirmar desinstalação
    read -p "Tem certeza que deseja remover todos os pacotes? (s/N) / Are you sure you want to remove all packages? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[SsYy]$ ]]; then
        echo "Operação cancelada / Operation cancelled"
        return
    fi
    
    # Remover cada pacote
    for package in $PACKAGES; do
        echo "Removendo / Removing: $package"
        apt remove --purge -y $package
        if [[ $? -eq 0 ]]; then
            echo "✓ $package removido com sucesso / removed successfully"
        else
            echo "✗ Erro ao remover / Error removing $package"
        fi
        echo ""
    done
    
    # Limpeza adicional
    echo "Executando limpeza adicional / Running additional cleanup..."
    apt autoremove -y
    apt autoclean -y
    
    echo "=========================================="
    echo "DESINSTALAÇÃO CONCLUÍDA / UNINSTALLATION COMPLETED"
    echo "=========================================="
}

# Função para configurar UFW
configure_ufw() {
    echo "=== Configurando UFW Firewall ==="
    echo ""
    
    # Verificar se UFW está instalado
    if ! command -v ufw &> /dev/null; then
        echo "UFW não está instalado. Instalando primeiro..."
        echo "UFW is not installed. Installing first..."
        apt update -y
        apt install -y ufw
    fi
    
    # Resetar UFW para configuração limpa
    echo "Resetando configuração do UFW / Resetting UFW configuration..."
    ufw --force reset
    
    # Configurar políticas padrão
    echo "Configurando políticas padrão / Setting default policies..."
    ufw default deny incoming
    ufw default allow outgoing
    
    # Configurar portas específicas
    echo "Configurando portas específicas / Configuring specific ports..."
    
    # FTP
    ufw allow 20/tcp comment "FTP Data"
    ufw allow 21/tcp comment "FTP Control"
    ufw allow 40000:50000/tcp comment "FTP Passive"
    
    # HTTP/HTTPS
    ufw allow 80/tcp comment "HTTP"
    ufw allow 443/tcp comment "HTTPS"
    
    # SSH
    ufw allow 22/tcp comment "SSH"
    
    # Outras portas
    ufw allow 1305/tcp comment "Custom Port 1305"
    ufw allow 465/tcp comment "SMTP SSL"
    ufw allow 587/tcp comment "SMTP TLS"
    ufw allow 993/tcp comment "IMAP SSL"
    ufw allow 995/tcp comment "POP3 SSL"
    ufw allow 143/tcp comment "IMAP"
    ufw allow 110/tcp comment "POP3"
    
    echo ""
    echo "Configuração do UFW concluída / UFW configuration completed"
    echo "=========================================="
}

# Função para mostrar status do UFW
show_ufw_status() {
    echo "=== Status do UFW Firewall ==="
    echo ""
    
    if command -v ufw &> /dev/null; then
        ufw status verbose
    else
        echo "UFW não está instalado / UFW is not installed"
    fi
    
    echo ""
    echo "=========================================="
}

# Função para reiniciar UFW
restart_ufw() {
    echo "=== Reiniciando UFW Firewall ==="
    echo ""
    
    if command -v ufw &> /dev/null; then
        echo "Desabilitando UFW / Disabling UFW..."
        ufw disable
        echo ""
        echo "Habilitando UFW / Enabling UFW..."
        ufw --force enable
        echo ""
        echo "UFW reiniciado com sucesso / UFW restarted successfully"
    else
        echo "UFW não está instalado / UFW is not installed"
    fi
    
    echo "=========================================="
}

# Função para mostrar o menu
show_menu() {
    clear
    detect_system
    echo "=========================================="
    echo "  MENU DE PACOTES BÁSICOS / BASIC PACKAGES MENU"
    echo "  Banana Pi M5 & Ubuntu 24.04"
    echo "=========================================="
    echo ""
    echo "Pacotes: curl, unzip, unrar, git, ufw, wget"
    echo ""
    echo "1) Instalar todos os pacotes / Install all packages"
    echo "2) Desinstalar todos os pacotes / Uninstall all packages"
    echo "3) Configurar UFW (portas específicas) / Configure UFW (specific ports)"
    echo "4) Mostrar status do UFW / Show UFW status"
    echo "5) Reiniciar UFW / Restart UFW"
    echo "0) Sair / Exit"
    echo ""
    echo "=========================================="
}

# Função principal
main() {
    check_root
    
    while true; do
        show_menu
        read -p "Escolha uma opção / Choose an option (0-5): " choice
        echo ""
        
        case $choice in
            1)
                install_packages
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
            2)
                uninstall_packages
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
            3)
                configure_ufw
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
            4)
                show_ufw_status
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
            5)
                restart_ufw
                read -p "Pressione Enter para continuar / Press Enter to continue..."
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