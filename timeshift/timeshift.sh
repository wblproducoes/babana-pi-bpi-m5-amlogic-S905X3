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

# Função para instalar Timeshift
install_packages() {
    echo "=== Instalando Timeshift / Installing Timeshift ==="
    echo ""
    
    # Verificar se já está instalado
    if command -v timeshift &> /dev/null; then
        echo "Timeshift já está instalado / Timeshift is already installed"
        timeshift --version
        return
    fi
    
    echo "Adicionando repositório PPA oficial do Timeshift..."
    echo "Adding official Timeshift PPA repository..."
    
    # Instalar software-properties-common se necessário
    apt update -y
    apt install -y software-properties-common
    
    # Adicionar PPA oficial do Timeshift
    add-apt-repository -y ppa:teejee2008/timeshift
    
    if [[ $? -ne 0 ]]; then
        echo "✗ Erro ao adicionar PPA / Error adding PPA"
        echo "Tentando instalação via repositórios padrão..."
        echo "Trying installation via default repositories..."
    fi
    
    # Atualizar lista de pacotes
    echo "Atualizando lista de pacotes / Updating package list..."
    apt update -y
    echo ""
    
    # Instalar Timeshift
    echo "Instalando Timeshift / Installing Timeshift..."
    apt install -y timeshift
    
    if [[ $? -eq 0 ]]; then
        echo "✓ Timeshift instalado com sucesso / Timeshift installed successfully"
        echo ""
        echo "Versão instalada / Installed version:"
        timeshift --version
    else
        echo "✗ Erro ao instalar Timeshift / Error installing Timeshift"
    fi
    
    echo ""
    echo "=========================================="
    echo "INSTALAÇÃO CONCLUÍDA / INSTALLATION COMPLETED"
    echo "=========================================="
}

# Função para desinstalar Timeshift
uninstall_packages() {
    echo "=== Desinstalando Timeshift / Uninstalling Timeshift ==="
    echo ""
    
    # Verificar se está instalado
    if ! command -v timeshift &> /dev/null; then
        echo "Timeshift não está instalado / Timeshift is not installed"
        return
    fi
    
    # Confirmar desinstalação
    read -p "Tem certeza que deseja remover o Timeshift? (s/N) / Are you sure you want to remove Timeshift? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[SsYy]$ ]]; then
        echo "Operação cancelada / Operation cancelled"
        return
    fi
    
    # Parar serviços do Timeshift se estiverem rodando
    echo "Parando serviços do Timeshift / Stopping Timeshift services..."
    systemctl stop crond 2>/dev/null || true
    
    # Remover Timeshift
    echo "Removendo Timeshift / Removing Timeshift..."
    apt remove --purge -y timeshift
    
    if [[ $? -eq 0 ]]; then
        echo "✓ Timeshift removido com sucesso / Timeshift removed successfully"
    else
        echo "✗ Erro ao remover Timeshift / Error removing Timeshift"
    fi
    
    # Remover PPA (opcional)
    read -p "Deseja remover o PPA do Timeshift? (s/N) / Do you want to remove Timeshift PPA? (y/N): " remove_ppa
    if [[ "$remove_ppa" =~ ^[SsYy]$ ]]; then
        echo "Removendo PPA do Timeshift / Removing Timeshift PPA..."
        add-apt-repository --remove -y ppa:teejee2008/timeshift 2>/dev/null || true
    fi
    
    # Remover diretório /timeshift onde os snapshots são armazenados
    if [[ -d "/timeshift" ]]; then
        echo ""
        echo "⚠️  ATENÇÃO / WARNING ⚠️"
        echo "Encontrado diretório /timeshift com snapshots do sistema"
        echo "Found /timeshift directory with system snapshots"
        echo "Este diretório contém todos os backups criados pelo Timeshift"
        echo "This directory contains all backups created by Timeshift"
        echo ""
        read -p "Deseja remover o diretório /timeshift? (s/N) / Do you want to remove /timeshift directory? (y/N): " remove_timeshift_dir
        
        if [[ "$remove_timeshift_dir" =~ ^[SsYy]$ ]]; then
            echo "Removendo diretório /timeshift / Removing /timeshift directory..."
            rm -rf /timeshift
            if [[ $? -eq 0 ]]; then
                echo "✓ Diretório /timeshift removido / /timeshift directory removed"
            else
                echo "✗ Erro ao remover diretório /timeshift / Error removing /timeshift directory"
            fi
        else
            echo "Diretório /timeshift mantido / /timeshift directory kept"
        fi
    fi
    
    # Remover configurações do usuário
    read -p "Deseja remover configurações do usuário? (s/N) / Do you want to remove user configurations? (y/N): " remove_config
    if [[ "$remove_config" =~ ^[SsYy]$ ]]; then
        echo "Removendo configurações / Removing configurations..."
        rm -rf ~/.config/timeshift 2>/dev/null || true
        rm -rf /etc/timeshift 2>/dev/null || true
        echo "Configurações removidas / Configurations removed"
    fi
    
    # Limpeza adicional
    echo "Executando limpeza adicional / Running additional cleanup..."
    apt autoremove -y
    apt autoclean -y
    
    echo ""
    echo "=========================================="
    echo "DESINSTALAÇÃO CONCLUÍDA / UNINSTALLATION COMPLETED"
    echo "=========================================="
}

# Função para criar backup
create_backup() {
    echo "=== Criando Backup com Timeshift / Creating Backup with Timeshift ==="
    echo ""
    
    # Verificar se o Timeshift está instalado
    if ! command -v timeshift &> /dev/null; then
        echo "✗ Timeshift não está instalado / Timeshift is not installed"
        echo "Execute a opção 'Instalar Timeshift' primeiro / Run 'Install Timeshift' option first"
        return
    fi
    
    # Verificar se o Timeshift está configurado
    if [[ ! -f "/etc/timeshift/timeshift.json" ]]; then
        echo "⚠️  Timeshift não está configurado / Timeshift is not configured"
        echo "Configurando automaticamente... / Configuring automatically..."
        echo ""
        
        # Configuração básica automática
        timeshift --setup --snapshot-device /dev/sda1 --backup-device /dev/sda1 2>/dev/null || true
    fi
    
    # Solicitar comentário para o backup
    echo "Você pode adicionar um comentário para este backup:"
    echo "You can add a comment for this backup:"
    read -p "Comentário (opcional) / Comment (optional): " backup_comment
    
    if [[ -z "$backup_comment" ]]; then
        backup_comment="Backup manual criado via script / Manual backup created via script"
    fi
    
    echo ""
    echo "Criando snapshot do sistema / Creating system snapshot..."
    echo "Comentário / Comment: $backup_comment"
    echo ""
    
    # Criar o backup
    timeshift --create --comments "$backup_comment"
    
    if [[ $? -eq 0 ]]; then
        echo ""
        echo "✓ Backup criado com sucesso / Backup created successfully"
        echo ""
        
        # Mostrar informações do último backup
        echo "Informações do backup / Backup information:"
        timeshift --list | tail -5
        
        echo ""
        echo "Para ver todos os backups: timeshift --list"
        echo "To see all backups: timeshift --list"
    else
        echo ""
        echo "✗ Erro ao criar backup / Error creating backup"
        echo "Verifique se há espaço suficiente no disco / Check if there's enough disk space"
        echo "Verifique as permissões / Check permissions"
    fi
    
    echo "=========================================="
}

# Função para listar backups
list_backups() {
    echo "=== Ver Backups do Timeshift / View Timeshift Backups ==="
    echo ""
    
    # Verificar se Timeshift está instalado
    if ! command -v timeshift &> /dev/null; then
        echo "✗ Timeshift não está instalado / Timeshift is not installed"
        echo "Execute a opção 'Instalar Timeshift' primeiro / Run 'Install Timeshift' option first"
        return
    fi
    
    echo "Listando todos os snapshots do sistema / Listing all system snapshots..."
    echo ""
    
    # Verificar se existem backups
    backup_count=$(timeshift --list 2>/dev/null | grep -c "^>" || echo "0")
    
    if [[ "$backup_count" -eq 0 ]]; then
        echo "✗ Nenhum backup encontrado / No backups found"
        echo ""
        echo "Para criar um backup:"
        echo "To create a backup:"
        echo "• Use a opção 'Criar Backup com Timeshift'"
        echo "• Use the 'Create Backup with Timeshift' option"
        echo "• Ou execute: timeshift --create"
        echo "• Or run: timeshift --create"
        return
    fi
    
    echo "Snapshots encontrados / Snapshots found: $backup_count"
    echo "========================================================"
    
    # Listar backups com informações detalhadas
    timeshift --list
    
    if [[ $? -eq 0 ]]; then
        echo "========================================================"
        echo ""
        
        # Mostrar informações adicionais
        echo "Informações adicionais / Additional information:"
        echo "• Para restaurar um backup, use a opção 'Restaurar Backup'"
        echo "• To restore a backup, use the 'Restore Backup' option"
        echo "• Para criar um novo backup, use a opção 'Criar Backup'"
        echo "• To create a new backup, use the 'Create Backup' option"
        echo ""
        
        # Mostrar espaço usado pelos backups
        if [[ -d "/timeshift" ]]; then
            echo "Espaço usado pelos backups / Space used by backups:"
            du -sh /timeshift 2>/dev/null || echo "Não foi possível calcular / Could not calculate"
        fi
        
        # Mostrar localização dos backups
        echo ""
        echo "Localização dos backups / Backup location:"
        if [[ -d "/timeshift" ]]; then
            echo "📁 /timeshift"
        else
            echo "⚠️  Diretório de backups não encontrado / Backup directory not found"
        fi
    else
        echo ""
        echo "✗ Erro ao listar backups / Error listing backups"
        echo "Verifique se o Timeshift está configurado corretamente"
        echo "Check if Timeshift is configured correctly"
    fi
    
    echo ""
    echo "=========================================="
}

# Função para restaurar backup
restore_backup() {
    echo "=== Restaurando Backup com Timeshift / Restoring Backup with Timeshift ==="
    echo ""
    
    # Verificar se Timeshift está instalado
    if ! command -v timeshift &> /dev/null; then
        echo "✗ Timeshift não está instalado / Timeshift is not installed"
        echo "Execute a opção 'Instalar Timeshift' primeiro / Run 'Install Timeshift' option first"
        return
    fi
    
    # Listar backups disponíveis
    echo "Listando snapshots existentes / Listing existing snapshots..."
    echo ""
    
    # Verificar se existem backups
    backup_count=$(timeshift --list 2>/dev/null | grep -c "^>" || echo "0")
    
    if [[ "$backup_count" -eq 0 ]]; then
        echo "✗ Nenhum backup encontrado / No backups found"
        echo "Crie um backup primeiro usando a opção 'Criar Backup'"
        echo "Create a backup first using 'Create Backup' option"
        return
    fi
    
    echo "Backups disponíveis / Available backups:"
    echo "========================================"
    timeshift --list
    echo "========================================"
    echo ""
    
    # Verificar se o ambiente gráfico está disponível
    if [[ -n "$DISPLAY" ]] || [[ -n "$WAYLAND_DISPLAY" ]]; then
        echo "Abrindo assistente gráfico do Timeshift..."
        echo "Opening Timeshift graphical assistant..."
        echo ""
        echo "No assistente gráfico você pode:"
        echo "In the graphical assistant you can:"
        echo "• Visualizar todos os snapshots disponíveis"
        echo "• View all available snapshots"
        echo "• Selecionar qual snapshot restaurar"
        echo "• Select which snapshot to restore"
        echo "• Escolher quais arquivos restaurar"
        echo "• Choose which files to restore"
        echo ""
        
        # Abrir interface gráfica
        timeshift-gtk &
        
        echo "✓ Interface gráfica aberta / Graphical interface opened"
        echo "Use a interface para selecionar e restaurar o backup desejado"
        echo "Use the interface to select and restore the desired backup"
    else
        echo "⚠️  Interface gráfica não disponível / Graphical interface not available"
        echo "Modo de linha de comando / Command line mode"
        echo ""
        
        # Solicitar ID do backup
        read -p "Digite o ID do snapshot para restaurar / Enter snapshot ID to restore: " backup_id
        
        if [[ -z "$backup_id" ]]; then
            echo "ID do snapshot não fornecido / Snapshot ID not provided"
            return
        fi
        
        # Confirmar restauração
        echo ""
        echo "⚠️  ATENÇÃO / WARNING ⚠️"
        echo "Esta operação irá restaurar o sistema para o estado do snapshot selecionado"
        echo "This operation will restore the system to the selected snapshot state"
        echo "Todos os dados criados após este snapshot serão perdidos"
        echo "All data created after this snapshot will be lost"
        echo ""
        read -p "Tem certeza que deseja continuar? (s/N) / Are you sure you want to continue? (y/N): " confirm
        
        if [[ ! "$confirm" =~ ^[SsYy]$ ]]; then
            echo "Operação cancelada / Operation cancelled"
            return
        fi
        
        echo ""
        echo "Restaurando snapshot $backup_id..."
        echo "Restoring snapshot $backup_id..."
        echo ""
        
        # Restaurar backup
        timeshift --restore --snapshot "$backup_id"
        
        if [[ $? -eq 0 ]]; then
            echo ""
            echo "✓ Snapshot restaurado com sucesso / Snapshot restored successfully"
            echo "⚠️  Reinicie o sistema para completar a restauração / Restart system to complete restoration"
        else
            echo ""
            echo "✗ Erro ao restaurar snapshot / Error restoring snapshot"
        fi
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
    echo "1) Instalar Timeshift / Install Timeshift"
    echo "2) Desinstalar Timeshift / Uninstall Timeshift"
    echo "3) Criar Backup com Timeshift / Create Backup with Timeshift"
    echo "4) Restaurar Backup com Timeshift / Restore Backup with Timeshift"
    echo "5) Ver Backups do Timeshift / View Timeshift Backups"
    echo "6) Sair / Exit"
    echo ""
    echo "=========================================="
}

# Função principal
main() {
    check_root
    
    while true; do
        show_menu
        read -p "Escolha uma opção / Choose an option (1-6): " choice
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
                create_backup
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
            4)
                restore_backup
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
            5)
                list_backups
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
            6)
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