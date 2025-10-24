#!/bin/bash

# Script de Gerenciamento do Timeshift para Banana Pi M5 (aarch64) e Ubuntu 24.04 (Noble)
# Timeshift Management Script for Banana Pi M5 (aarch64) and Ubuntu 24.04 (Noble)

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
PACKAGES="timeshift xauth"

# Função para instalar pacotes
install_packages() {
    echo "=== Instalando Timeshift e Xauth / Installing Timeshift and Xauth ==="
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
    echo "=== Desinstalando Timeshift e Xauth / Uninstalling Timeshift and Xauth ==="
    echo "Pacotes a remover / Packages to remove: $PACKAGES"
    echo ""
    
    # Confirmar desinstalação
    read -p "Tem certeza que deseja remover todos os pacotes? (s/N) / Are you sure you want to remove all packages? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[SsYy]$ ]]; then
        echo "Operação cancelada / Operation cancelled"
        return
    fi
    
    # Parar serviços do Timeshift se estiverem rodando
    echo "Parando serviços do Timeshift / Stopping Timeshift services..."
    systemctl stop crond 2>/dev/null || true
    
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
    
    # Remover diretórios de configuração e backups (se solicitado)
    read -p "Deseja remover também os backups e configurações? (s/N) / Do you want to remove backups and configurations too? (y/N): " remove_data
    if [[ "$remove_data" =~ ^[SsYy]$ ]]; then
        echo "Removendo dados do Timeshift / Removing Timeshift data..."
        rm -rf /timeshift 2>/dev/null || true
        rm -rf /home/timeshift 2>/dev/null || true
        rm -rf ~/.config/timeshift 2>/dev/null || true
        echo "Dados removidos / Data removed"
    fi
    
    # Limpeza adicional
    echo "Executando limpeza adicional / Running additional cleanup..."
    apt autoremove -y
    apt autoclean -y
    
    echo "=========================================="
    echo "DESINSTALAÇÃO CONCLUÍDA / UNINSTALLATION COMPLETED"
    echo "=========================================="
}

# Função para criar backup
create_backup() {
    echo "=== Criando Backup com Timeshift / Creating Backup with Timeshift ==="
    echo ""
    
    # Verificar se Timeshift está instalado
    if ! command -v timeshift &> /dev/null; then
        echo "Timeshift não está instalado. Instale primeiro usando a opção 1."
        echo "Timeshift is not installed. Install it first using option 1."
        return
    fi
    
    # Solicitar comentário para o backup
    read -p "Digite um comentário para este backup / Enter a comment for this backup: " comment
    if [[ -z "$comment" ]]; then
        comment="Backup manual $(date '+%Y-%m-%d %H:%M:%S')"
    fi
    
    echo "Criando backup com comentário: $comment"
    echo "Creating backup with comment: $comment"
    echo ""
    
    # Criar backup
    timeshift --create --comments "$comment"
    
    if [[ $? -eq 0 ]]; then
        echo ""
        echo "✓ Backup criado com sucesso / Backup created successfully"
    else
        echo ""
        echo "✗ Erro ao criar backup / Error creating backup"
    fi
    
    echo "=========================================="
}

# Função para listar backups
list_backups() {
    echo "=== Listando Backups Disponíveis / Listing Available Backups ==="
    echo ""
    
    # Verificar se Timeshift está instalado
    if ! command -v timeshift &> /dev/null; then
        echo "Timeshift não está instalado. Instale primeiro usando a opção 1."
        echo "Timeshift is not installed. Install it first using option 1."
        return
    fi
    
    # Listar backups
    timeshift --list
    
    echo ""
    echo "=========================================="
}

# Função para restaurar backup
restore_backup() {
    echo "=== Restaurando Backup com Timeshift / Restoring Backup with Timeshift ==="
    echo ""
    
    # Verificar se Timeshift está instalado
    if ! command -v timeshift &> /dev/null; then
        echo "Timeshift não está instalado. Instale primeiro usando a opção 1."
        echo "Timeshift is not installed. Install it first using option 1."
        return
    fi
    
    # Mostrar backups disponíveis primeiro
    echo "Backups disponíveis / Available backups:"
    echo "----------------------------------------"
    timeshift --list
    echo ""
    
    # Solicitar qual backup restaurar
    read -p "Digite o nome do snapshot para restaurar (ex: 2024-01-15_10-30-45) / Enter snapshot name to restore (ex: 2024-01-15_10-30-45): " snapshot
    
    if [[ -z "$snapshot" ]]; then
        echo "Nome do snapshot não fornecido. Operação cancelada."
        echo "Snapshot name not provided. Operation cancelled."
        return
    fi
    
    # Confirmar restauração
    echo ""
    echo "⚠️  ATENÇÃO / WARNING ⚠️"
    echo "Esta operação irá restaurar o sistema para o estado do backup selecionado."
    echo "This operation will restore the system to the selected backup state."
    echo "Todos os dados atuais podem ser perdidos!"
    echo "All current data may be lost!"
    echo ""
    read -p "Tem certeza que deseja continuar? (s/N) / Are you sure you want to continue? (y/N): " confirm
    
    if [[ ! "$confirm" =~ ^[SsYy]$ ]]; then
        echo "Operação cancelada / Operation cancelled"
        return
    fi
    
    # Executar restauração
    echo "Iniciando restauração do snapshot: $snapshot"
    echo "Starting restoration of snapshot: $snapshot"
    echo ""
    
    timeshift --restore --snapshot "$snapshot"
    
    if [[ $? -eq 0 ]]; then
        echo ""
        echo "✓ Restauração concluída com sucesso / Restoration completed successfully"
        echo "O sistema pode precisar ser reiniciado / The system may need to be restarted"
    else
        echo ""
        echo "✗ Erro durante a restauração / Error during restoration"
    fi
    
    echo "=========================================="
}

# Função para configurar Timeshift
configure_timeshift() {
    echo "=== Configurando Timeshift / Configuring Timeshift ==="
    echo ""
    
    # Verificar se Timeshift está instalado
    if ! command -v timeshift &> /dev/null; then
        echo "Timeshift não está instalado. Instale primeiro usando a opção 1."
        echo "Timeshift is not installed. Install it first using option 1."
        return
    fi
    
    echo "Iniciando configuração do Timeshift..."
    echo "Starting Timeshift configuration..."
    echo ""
    echo "NOTA: Esta configuração abrirá a interface do Timeshift."
    echo "NOTE: This configuration will open the Timeshift interface."
    echo "Se estiver usando SSH, certifique-se de ter X11 forwarding habilitado."
    echo "If using SSH, make sure X11 forwarding is enabled."
    echo ""
    
    read -p "Pressione Enter para continuar / Press Enter to continue..."
    
    # Tentar abrir interface gráfica
    if [[ -n "$DISPLAY" ]]; then
        timeshift-gtk
    else
        echo "Interface gráfica não disponível. Usando configuração via linha de comando."
        echo "Graphical interface not available. Using command line configuration."
        echo ""
        
        # Configuração básica via linha de comando
        echo "Configuração básica do Timeshift:"
        echo "1. Tipo de snapshot: RSYNC (recomendado para sistemas de arquivos ext4)"
        echo "2. Localização: /timeshift (padrão)"
        echo ""
        
        read -p "Deseja configurar agendamento automático? (s/N) / Do you want to configure automatic scheduling? (y/N): " schedule
        if [[ "$schedule" =~ ^[SsYy]$ ]]; then
            echo "Para configurar agendamento, use: timeshift --schedule"
            echo "Exemplo: timeshift --schedule-monthly 2 --schedule-weekly 3 --schedule-daily 5"
        fi
    fi
    
    echo "=========================================="
}

# Função para mostrar o menu
show_menu() {
    clear
    detect_system
    echo "=========================================="
    echo "  MENU DO TIMESHIFT MANAGER / TIMESHIFT MANAGER MENU"
    echo "  Banana Pi M5 & Ubuntu 24.04"
    echo "=========================================="
    echo ""
    echo "Pacotes: timeshift, xauth"
    echo ""
    echo "1) Instalar Timeshift e Xauth / Install Timeshift and Xauth"
    echo "2) Desinstalar Timeshift e Xauth / Uninstall Timeshift and Xauth"
    echo "3) Configurar Timeshift / Configure Timeshift"
    echo "4) Criar Backup / Create Backup"
    echo "5) Listar Backups / List Backups"
    echo "6) Restaurar Backup / Restore Backup"
    echo "0) Sair / Exit"
    echo ""
    echo "=========================================="
}

# Função principal
main() {
    check_root
    
    while true; do
        show_menu
        read -p "Escolha uma opção / Choose an option (0-6): " choice
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
                configure_timeshift
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
            4)
                create_backup
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
            5)
                list_backups
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
            6)
                restore_backup
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