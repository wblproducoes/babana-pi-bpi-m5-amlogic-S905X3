#!/bin/bash

# Script de Gerenciamento do Tailscale para Banana Pi M5 (aarch64) e Ubuntu 24.04 (Noble)
# Tailscale Management Script for Banana Pi M5 (aarch64) and Ubuntu 24.04 (Noble)

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

# Função para instalar Tailscale
install_tailscale() {
    echo "=== Instalando Tailscale / Installing Tailscale ==="
    echo ""
    
    # Verificar se já está instalado
    if command -v tailscale &> /dev/null; then
        echo "Tailscale já está instalado / Tailscale is already installed"
        echo "Versão atual / Current version: $(tailscale version)"
        echo ""
        read -p "Deseja reinstalar? (s/N) / Do you want to reinstall? (y/N): " reinstall
        if [[ ! "$reinstall" =~ ^[SsYy]$ ]]; then
            echo "Instalação cancelada / Installation cancelled"
            return
        fi
    fi
    
    echo "Baixando e instalando Tailscale..."
    echo "Downloading and installing Tailscale..."
    echo ""
    
    # Atualizar lista de pacotes
    echo "Atualizando lista de pacotes / Updating package list..."
    apt update -y
    echo ""
    
    # Baixar e instalar Tailscale
    echo "Baixando script de instalação / Downloading installation script..."
    curl -fsSL https://tailscale.com/install.sh | sh
    
    if [[ $? -eq 0 ]]; then
        echo ""
        echo "✓ Tailscale instalado com sucesso / Tailscale installed successfully"
        echo ""
        
        # Habilitar e iniciar serviço
        echo "Habilitando e iniciando serviço / Enabling and starting service..."
        systemctl enable tailscaled
        systemctl start tailscaled
        
        echo ""
        echo "Para conectar à sua rede Tailscale, execute:"
        echo "To connect to your Tailscale network, run:"
        echo "sudo tailscale up"
        echo ""
    else
        echo ""
        echo "✗ Erro ao instalar Tailscale / Error installing Tailscale"
    fi
    
    echo "=========================================="
}

# Função para desinstalar Tailscale
uninstall_tailscale() {
    echo "=== Desinstalando Tailscale / Uninstalling Tailscale ==="
    echo ""
    
    # Verificar se está instalado
    if ! command -v tailscale &> /dev/null; then
        echo "Tailscale não está instalado / Tailscale is not installed"
        return
    fi
    
    # Confirmar desinstalação
    read -p "Tem certeza que deseja remover o Tailscale? (s/N) / Are you sure you want to remove Tailscale? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[SsYy]$ ]]; then
        echo "Operação cancelada / Operation cancelled"
        return
    fi
    
    # Desconectar da rede primeiro
    echo "Desconectando da rede Tailscale / Disconnecting from Tailscale network..."
    tailscale down 2>/dev/null || true
    
    # Parar e desabilitar serviço
    echo "Parando e desabilitando serviço / Stopping and disabling service..."
    systemctl stop tailscaled 2>/dev/null || true
    systemctl disable tailscaled 2>/dev/null || true
    
    # Remover pacote
    echo "Removendo pacote Tailscale / Removing Tailscale package..."
    apt remove --purge -y tailscale
    
    # Remover diretórios e arquivos de configuração
    read -p "Deseja remover também as configurações e dados? (s/N) / Do you want to remove configurations and data too? (y/N): " remove_data
    if [[ "$remove_data" =~ ^[SsYy]$ ]]; then
        echo "Removendo dados do Tailscale / Removing Tailscale data..."
        rm -rf /var/lib/tailscale 2>/dev/null || true
        rm -rf /etc/tailscale 2>/dev/null || true
        rm -rf ~/.config/tailscale 2>/dev/null || true
        rm -f /etc/systemd/system/tailscaled.service 2>/dev/null || true
        echo "Dados removidos / Data removed"
    fi
    
    # Limpeza adicional
    echo "Executando limpeza adicional / Running additional cleanup..."
    apt autoremove -y
    apt autoclean -y
    
    # Recarregar systemd
    systemctl daemon-reload
    
    echo ""
    echo "✓ Tailscale removido com sucesso / Tailscale removed successfully"
    echo "=========================================="
}

# Função para verificar status do Tailscale
check_status() {
    echo "=== Status do Tailscale / Tailscale Status ==="
    echo ""
    
    # Verificar se está instalado
    if ! command -v tailscale &> /dev/null; then
        echo "Tailscale não está instalado / Tailscale is not installed"
        echo "Use a opção 1 para instalar / Use option 1 to install"
        return
    fi
    
    # Verificar status do serviço
    echo "Status do Serviço / Service Status:"
    echo "-----------------------------------"
    if systemctl is-active --quiet tailscaled; then
        echo "✓ Serviço tailscaled está rodando / tailscaled service is running"
    else
        echo "✗ Serviço tailscaled não está rodando / tailscaled service is not running"
        echo "Para iniciar: sudo systemctl start tailscaled"
        echo "To start: sudo systemctl start tailscaled"
    fi
    echo ""
    
    # Verificar status da conexão
    echo "Status da Conexão / Connection Status:"
    echo "--------------------------------------"
    tailscale status
    echo ""
    
    # Mostrar versão
    echo "Versão / Version:"
    echo "-----------------"
    tailscale version
    echo ""
    
    echo "=========================================="
}

# Função para verificar IP do Tailscale
check_ip() {
    echo "=== IP do Tailscale / Tailscale IP ==="
    echo ""
    
    # Verificar se está instalado
    if ! command -v tailscale &> /dev/null; then
        echo "Tailscale não está instalado / Tailscale is not installed"
        echo "Use a opção 1 para instalar / Use option 1 to install"
        return
    fi
    
    # Verificar se está conectado
    if ! tailscale status &> /dev/null; then
        echo "Tailscale não está conectado / Tailscale is not connected"
        echo "Para conectar: sudo tailscale up"
        echo "To connect: sudo tailscale up"
        return
    fi
    
    # Obter IP do Tailscale
    echo "Informações de IP / IP Information:"
    echo "-----------------------------------"
    
    # IP da interface Tailscale
    TAILSCALE_IP=$(tailscale ip -4 2>/dev/null)
    if [[ -n "$TAILSCALE_IP" ]]; then
        echo "IP Tailscale (IPv4): $TAILSCALE_IP"
    else
        echo "IP Tailscale (IPv4): Não disponível / Not available"
    fi
    
    # IPv6 se disponível
    TAILSCALE_IP6=$(tailscale ip -6 2>/dev/null)
    if [[ -n "$TAILSCALE_IP6" ]]; then
        echo "IP Tailscale (IPv6): $TAILSCALE_IP6"
    fi
    
    echo ""
    
    # Mostrar interface de rede
    echo "Interface de Rede / Network Interface:"
    echo "--------------------------------------"
    ip addr show tailscale0 2>/dev/null || echo "Interface tailscale0 não encontrada / Interface tailscale0 not found"
    
    echo ""
    echo "=========================================="
}

# Função para conectar/desconectar Tailscale
manage_connection() {
    echo "=== Gerenciar Conexão / Manage Connection ==="
    echo ""
    
    # Verificar se está instalado
    if ! command -v tailscale &> /dev/null; then
        echo "Tailscale não está instalado / Tailscale is not installed"
        echo "Use a opção 1 para instalar / Use option 1 to install"
        return
    fi
    
    # Verificar status atual
    if tailscale status &> /dev/null; then
        echo "Tailscale está conectado / Tailscale is connected"
        echo ""
        read -p "Deseja desconectar? (s/N) / Do you want to disconnect? (y/N): " disconnect
        if [[ "$disconnect" =~ ^[SsYy]$ ]]; then
            echo "Desconectando... / Disconnecting..."
            tailscale down
            echo "✓ Desconectado com sucesso / Disconnected successfully"
        fi
    else
        echo "Tailscale não está conectado / Tailscale is not connected"
        echo ""
        read -p "Deseja conectar? (s/N) / Do you want to connect? (y/N): " connect
        if [[ "$connect" =~ ^[SsYy]$ ]]; then
            echo "Conectando... / Connecting..."
            echo "Siga as instruções na tela para autenticar"
            echo "Follow the on-screen instructions to authenticate"
            tailscale up
            if [[ $? -eq 0 ]]; then
                echo "✓ Conectado com sucesso / Connected successfully"
            else
                echo "✗ Erro ao conectar / Error connecting"
            fi
        fi
    fi
    
    echo "=========================================="
}

# Função para mostrar o menu
show_menu() {
    clear
    detect_system
    echo "=========================================="
    echo "  MENU DO TAILSCALE MANAGER / TAILSCALE MANAGER MENU"
    echo "  Banana Pi M5 & Ubuntu 24.04"
    echo "=========================================="
    echo ""
    echo "1) Instalar Tailscale / Install Tailscale"
    echo "2) Desinstalar Tailscale / Uninstall Tailscale"
    echo "3) Verificar Status / Check Status"
    echo "4) Verificar IP / Check IP"
    echo "5) Conectar/Desconectar / Connect/Disconnect"
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
                install_tailscale
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
            2)
                uninstall_tailscale
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
            3)
                check_status
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
            4)
                check_ip
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
            5)
                manage_connection
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