#!/bin/bash

# Script de Gerenciamento de Discos para Banana Pi M5 (aarch64) e Ubuntu 24.04 (Noble)
# Disk Management Script for Banana Pi M5 (aarch64) and Ubuntu 24.04 (Noble)

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

# Verificar e instalar dependências
check_dependencies() {
    echo "Verificando dependências / Checking dependencies..."
    
    # Lista de pacotes necessários
    REQUIRED_PACKAGES="parted fdisk ntfs-3g dosfstools e2fsprogs util-linux"
    MISSING_PACKAGES=""
    
    for package in $REQUIRED_PACKAGES; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            MISSING_PACKAGES="$MISSING_PACKAGES $package"
        fi
    done
    
    if [[ -n "$MISSING_PACKAGES" ]]; then
        echo "Instalando pacotes necessários / Installing required packages:$MISSING_PACKAGES"
        apt update -y
        apt install -y $MISSING_PACKAGES
        echo ""
    fi
}

# Função para listar discos e partições
list_disks() {
    echo "=== Listando Discos e Partições / Listing Disks and Partitions ==="
    echo ""
    
    echo "Discos Disponíveis / Available Disks:"
    echo "-------------------------------------"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE,LABEL
    echo ""
    
    echo "Informações Detalhadas / Detailed Information:"
    echo "----------------------------------------------"
    fdisk -l | grep -E "^Disk /dev/|^/dev/"
    echo ""
    
    echo "Partições Montadas / Mounted Partitions:"
    echo "----------------------------------------"
    df -h | grep -E "^/dev/"
    echo ""
    
    echo "=========================================="
}

# Função para criar partição
create_partition() {
    echo "=== Criando Partição / Creating Partition ==="
    echo ""
    
    # Listar discos disponíveis
    echo "Discos disponíveis / Available disks:"
    lsblk -d -o NAME,SIZE,TYPE | grep disk
    echo ""
    
    read -p "Digite o dispositivo (ex: /dev/sdb) / Enter device (ex: /dev/sdb): " device
    if [[ ! -b "$device" ]]; then
        echo "Dispositivo inválido / Invalid device: $device"
        return
    fi
    
    echo ""
    echo "⚠️  ATENÇÃO / WARNING ⚠️"
    echo "Esta operação irá modificar a tabela de partições do dispositivo $device"
    echo "This operation will modify the partition table of device $device"
    echo ""
    read -p "Tem certeza que deseja continuar? (s/N) / Are you sure you want to continue? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[SsYy]$ ]]; then
        echo "Operação cancelada / Operation cancelled"
        return
    fi
    
    echo ""
    echo "Tipos de partição / Partition types:"
    echo "1) Primária / Primary"
    echo "2) Estendida / Extended"
    echo "3) Lógica / Logical"
    read -p "Escolha o tipo (1-3) / Choose type (1-3): " part_type
    
    echo ""
    read -p "Digite o tamanho (ex: 10G, 500M, ou Enter para usar todo espaço) / Enter size (ex: 10G, 500M, or Enter for all space): " size
    
    echo ""
    echo "Criando partição / Creating partition..."
    
    case $part_type in
        1)
            if [[ -z "$size" ]]; then
                parted -s "$device" mkpart primary 0% 100%
            else
                parted -s "$device" mkpart primary 0% "$size"
            fi
            ;;
        2)
            if [[ -z "$size" ]]; then
                parted -s "$device" mkpart extended 0% 100%
            else
                parted -s "$device" mkpart extended 0% "$size"
            fi
            ;;
        3)
            if [[ -z "$size" ]]; then
                parted -s "$device" mkpart logical 0% 100%
            else
                parted -s "$device" mkpart logical 0% "$size"
            fi
            ;;
        *)
            echo "Tipo inválido / Invalid type"
            return
            ;;
    esac
    
    if [[ $? -eq 0 ]]; then
        echo "✓ Partição criada com sucesso / Partition created successfully"
        echo ""
        echo "Nova tabela de partições / New partition table:"
        parted "$device" print
    else
        echo "✗ Erro ao criar partição / Error creating partition"
    fi
    
    echo "=========================================="
}

# Função para apagar partição
delete_partition() {
    echo "=== Apagando Partição / Deleting Partition ==="
    echo ""
    
    # Listar partições disponíveis
    echo "Partições disponíveis / Available partitions:"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE
    echo ""
    
    read -p "Digite a partição (ex: /dev/sdb1) / Enter partition (ex: /dev/sdb1): " partition
    if [[ ! -b "$partition" ]]; then
        echo "Partição inválida / Invalid partition: $partition"
        return
    fi
    
    # Verificar se está montada
    if mount | grep -q "$partition"; then
        echo "⚠️  Partição está montada / Partition is mounted"
        read -p "Deseja desmontá-la primeiro? (s/N) / Do you want to unmount it first? (y/N): " unmount
        if [[ "$unmount" =~ ^[SsYy]$ ]]; then
            umount "$partition"
            if [[ $? -ne 0 ]]; then
                echo "✗ Erro ao desmontar / Error unmounting"
                return
            fi
        else
            echo "Operação cancelada / Operation cancelled"
            return
        fi
    fi
    
    echo ""
    echo "⚠️  ATENÇÃO / WARNING ⚠️"
    echo "Esta operação irá apagar permanentemente a partição $partition"
    echo "This operation will permanently delete partition $partition"
    echo "Todos os dados serão perdidos! / All data will be lost!"
    echo ""
    read -p "Tem certeza que deseja continuar? (s/N) / Are you sure you want to continue? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[SsYy]$ ]]; then
        echo "Operação cancelada / Operation cancelled"
        return
    fi
    
    # Extrair dispositivo e número da partição
    device=$(echo "$partition" | sed 's/[0-9]*$//')
    part_num=$(echo "$partition" | sed 's/.*[^0-9]//')
    
    echo ""
    echo "Apagando partição / Deleting partition..."
    parted -s "$device" rm "$part_num"
    
    if [[ $? -eq 0 ]]; then
        echo "✓ Partição apagada com sucesso / Partition deleted successfully"
        echo ""
        echo "Nova tabela de partições / New partition table:"
        parted "$device" print
    else
        echo "✗ Erro ao apagar partição / Error deleting partition"
    fi
    
    echo "=========================================="
}

# Função para formatar partição
format_partition() {
    echo "=== Formatando Partição / Formatting Partition ==="
    echo ""
    
    # Listar partições disponíveis
    echo "Partições disponíveis / Available partitions:"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE
    echo ""
    
    read -p "Digite a partição (ex: /dev/sdb1) / Enter partition (ex: /dev/sdb1): " partition
    if [[ ! -b "$partition" ]]; then
        echo "Partição inválida / Invalid partition: $partition"
        return
    fi
    
    # Verificar se está montada
    if mount | grep -q "$partition"; then
        echo "⚠️  Partição está montada / Partition is mounted"
        read -p "Deseja desmontá-la primeiro? (s/N) / Do you want to unmount it first? (y/N): " unmount
        if [[ "$unmount" =~ ^[SsYy]$ ]]; then
            umount "$partition"
            if [[ $? -ne 0 ]]; then
                echo "✗ Erro ao desmontar / Error unmounting"
                return
            fi
        else
            echo "Operação cancelada / Operation cancelled"
            return
        fi
    fi
    
    echo ""
    echo "Sistemas de arquivos disponíveis / Available filesystems:"
    echo "1) NTFS"
    echo "2) ext4"
    echo "3) FAT32"
    echo "4) exFAT"
    read -p "Escolha o sistema de arquivos (1-4) / Choose filesystem (1-4): " fs_type
    
    echo ""
    read -p "Digite um rótulo (opcional) / Enter a label (optional): " label
    
    echo ""
    echo "⚠️  ATENÇÃO / WARNING ⚠️"
    echo "Esta operação irá apagar todos os dados da partição $partition"
    echo "This operation will erase all data on partition $partition"
    echo ""
    read -p "Tem certeza que deseja continuar? (s/N) / Are you sure you want to continue? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[SsYy]$ ]]; then
        echo "Operação cancelada / Operation cancelled"
        return
    fi
    
    echo ""
    echo "Formatando partição / Formatting partition..."
    
    case $fs_type in
        1)
            if [[ -n "$label" ]]; then
                mkfs.ntfs -f -L "$label" "$partition"
            else
                mkfs.ntfs -f "$partition"
            fi
            ;;
        2)
            if [[ -n "$label" ]]; then
                mkfs.ext4 -F -L "$label" "$partition"
            else
                mkfs.ext4 -F "$partition"
            fi
            ;;
        3)
            if [[ -n "$label" ]]; then
                mkfs.fat -F 32 -n "$label" "$partition"
            else
                mkfs.fat -F 32 "$partition"
            fi
            ;;
        4)
            if [[ -n "$label" ]]; then
                mkfs.exfat -n "$label" "$partition"
            else
                mkfs.exfat "$partition"
            fi
            ;;
        *)
            echo "Sistema de arquivos inválido / Invalid filesystem"
            return
            ;;
    esac
    
    if [[ $? -eq 0 ]]; then
        echo "✓ Partição formatada com sucesso / Partition formatted successfully"
        echo ""
        echo "Informações da partição / Partition information:"
        lsblk -o NAME,SIZE,FSTYPE,LABEL "$partition"
    else
        echo "✗ Erro ao formatar partição / Error formatting partition"
    fi
    
    echo "=========================================="
}

# Função para montar partição
mount_partition() {
    echo "=== Montando Partição / Mounting Partition ==="
    echo ""
    
    # Listar partições não montadas
    echo "Partições disponíveis / Available partitions:"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE | grep -v "SWAP"
    echo ""
    
    read -p "Digite a partição (ex: /dev/sdb1) / Enter partition (ex: /dev/sdb1): " partition
    if [[ ! -b "$partition" ]]; then
        echo "Partição inválida / Invalid partition: $partition"
        return
    fi
    
    # Verificar se já está montada
    if mount | grep -q "$partition"; then
        echo "Partição já está montada em: $(mount | grep "$partition" | awk '{print $3}')"
        echo "Partition is already mounted at: $(mount | grep "$partition" | awk '{print $3}')"
        return
    fi
    
    echo ""
    read -p "Digite o ponto de montagem (ex: /mnt/disk1) / Enter mount point (ex: /mnt/disk1): " mount_point
    
    # Criar diretório se não existir
    if [[ ! -d "$mount_point" ]]; then
        echo "Criando diretório / Creating directory: $mount_point"
        mkdir -p "$mount_point"
    fi
    
    echo ""
    echo "Montando partição / Mounting partition..."
    mount "$partition" "$mount_point"
    
    if [[ $? -eq 0 ]]; then
        echo "✓ Partição montada com sucesso / Partition mounted successfully"
        echo "Local: $mount_point"
        echo ""
        echo "Informações de montagem / Mount information:"
        df -h "$mount_point"
    else
        echo "✗ Erro ao montar partição / Error mounting partition"
    fi
    
    echo "=========================================="
}

# Função para desmontar partição
unmount_partition() {
    echo "=== Desmontando Partição / Unmounting Partition ==="
    echo ""
    
    # Listar partições montadas
    echo "Partições montadas / Mounted partitions:"
    df -h | grep -E "^/dev/"
    echo ""
    
    read -p "Digite a partição ou ponto de montagem / Enter partition or mount point: " target
    
    if [[ ! -e "$target" ]]; then
        echo "Partição ou ponto de montagem inválido / Invalid partition or mount point: $target"
        return
    fi
    
    echo ""
    echo "Desmontando / Unmounting..."
    umount "$target"
    
    if [[ $? -eq 0 ]]; then
        echo "✓ Partição desmontada com sucesso / Partition unmounted successfully"
    else
        echo "✗ Erro ao desmontar partição / Error unmounting partition"
        echo "Tentando forçar desmontagem / Trying to force unmount..."
        umount -f "$target"
        if [[ $? -eq 0 ]]; then
            echo "✓ Partição desmontada forçadamente / Partition force unmounted"
        else
            echo "✗ Falha ao desmontar / Failed to unmount"
        fi
    fi
    
    echo "=========================================="
}

# Função para visualizar discos montados
view_mounted() {
    echo "=== Visualizando Discos Montados / Viewing Mounted Disks ==="
    echo ""
    
    echo "Discos e Partições Montados / Mounted Disks and Partitions:"
    echo "-----------------------------------------------------------"
    df -h | head -1  # Cabeçalho
    df -h | grep -E "^/dev/" | sort
    echo ""
    
    echo "Informações Detalhadas de Montagem / Detailed Mount Information:"
    echo "----------------------------------------------------------------"
    mount | grep -E "^/dev/" | sort | while read line; do
        device=$(echo "$line" | awk '{print $1}')
        mount_point=$(echo "$line" | awk '{print $3}')
        fs_type=$(echo "$line" | awk '{print $5}')
        options=$(echo "$line" | sed 's/.*(\(.*\)).*/\1/')
        
        echo "Dispositivo / Device: $device"
        echo "Ponto de Montagem / Mount Point: $mount_point"
        echo "Sistema de Arquivos / Filesystem: $fs_type"
        echo "Opções / Options: $options"
        echo "---"
    done
    echo ""
    
    echo "Uso de Espaço por Dispositivo / Space Usage by Device:"
    echo "------------------------------------------------------"
    df -h | grep -E "^/dev/" | awk '{printf "%-20s %8s %8s %8s %6s %s\n", $1, $2, $3, $4, $5, $6}'
    echo ""
    
    echo "=========================================="
}

# Função para montagem automática
auto_mount() {
    echo "=== Configurando Montagem Automática / Configuring Auto Mount ==="
    echo ""
    
    # Listar partições disponíveis
    echo "Partições disponíveis / Available partitions:"
    lsblk -o NAME,SIZE,TYPE,FSTYPE,UUID | grep -v "SWAP"
    echo ""
    
    read -p "Digite a partição (ex: /dev/sdb1) / Enter partition (ex: /dev/sdb1): " partition
    if [[ ! -b "$partition" ]]; then
        echo "Partição inválida / Invalid partition: $partition"
        return
    fi
    
    # Obter UUID da partição
    UUID=$(blkid -s UUID -o value "$partition")
    if [[ -z "$UUID" ]]; then
        echo "✗ Não foi possível obter UUID da partição / Could not get partition UUID"
        return
    fi
    
    echo ""
    read -p "Digite o ponto de montagem (ex: /mnt/disk1) / Enter mount point (ex: /mnt/disk1): " mount_point
    
    # Criar diretório se não existir
    if [[ ! -d "$mount_point" ]]; then
        echo "Criando diretório / Creating directory: $mount_point"
        mkdir -p "$mount_point"
    fi
    
    # Detectar sistema de arquivos
    FSTYPE=$(blkid -s TYPE -o value "$partition")
    
    echo ""
    echo "Opções de montagem / Mount options:"
    echo "1) Padrão / Default"
    echo "2) Personalizada / Custom"
    read -p "Escolha (1-2) / Choose (1-2): " option_choice
    
    if [[ "$option_choice" == "2" ]]; then
        read -p "Digite as opções (ex: defaults,uid=1000,gid=1000) / Enter options (ex: defaults,uid=1000,gid=1000): " mount_options
    else
        case $FSTYPE in
            ntfs)
                mount_options="defaults,uid=1000,gid=1000,umask=0022"
                ;;
            vfat|fat32)
                mount_options="defaults,uid=1000,gid=1000,umask=0022"
                ;;
            *)
                mount_options="defaults"
                ;;
        esac
    fi
    
    # Criar entrada no fstab
    FSTAB_ENTRY="UUID=$UUID $mount_point $FSTYPE $mount_options 0 2"
    
    echo ""
    echo "Entrada a ser adicionada ao /etc/fstab:"
    echo "Entry to be added to /etc/fstab:"
    echo "$FSTAB_ENTRY"
    echo ""
    
    read -p "Confirma a adição? (s/N) / Confirm addition? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[SsYy]$ ]]; then
        echo "Operação cancelada / Operation cancelled"
        return
    fi
    
    # Backup do fstab
    cp /etc/fstab /etc/fstab.backup.$(date +%Y%m%d_%H%M%S)
    
    # Adicionar entrada
    echo "$FSTAB_ENTRY" >> /etc/fstab
    
    # Testar montagem
    echo "Testando montagem / Testing mount..."
    mount -a
    
    if [[ $? -eq 0 ]]; then
        echo "✓ Montagem automática configurada com sucesso / Auto mount configured successfully"
        echo ""
        echo "Verificando montagem / Checking mount:"
        df -h "$mount_point"
    else
        echo "✗ Erro na configuração / Configuration error"
        echo "Restaurando backup do fstab / Restoring fstab backup..."
        mv /etc/fstab.backup.$(date +%Y%m%d_%H%M%S) /etc/fstab
    fi
    
    echo "=========================================="
}

# Função para mostrar o menu
show_menu() {
    clear
    detect_system
    echo "=========================================="
    echo "  MENU DO DISK MANAGER / DISK MANAGER MENU"
    echo "  Banana Pi M5 & Ubuntu 24.04"
    echo "=========================================="
    echo ""
    echo "1) Listar Discos e Partições / List Disks and Partitions"
    echo "2) Visualizar Discos Montados / View Mounted Disks"
    echo "3) Criar Partição / Create Partition"
    echo "4) Apagar Partição / Delete Partition"
    echo "5) Formatar Partição / Format Partition"
    echo "6) Montar Partição / Mount Partition"
    echo "7) Desmontar Partição / Unmount Partition"
    echo "8) Configurar Montagem Automática / Configure Auto Mount"
    echo "0) Sair / Exit"
    echo ""
    echo "=========================================="
}

# Função principal
main() {
    check_root
    check_dependencies
    
    while true; do
        show_menu
        read -p "Escolha uma opção / Choose an option (0-8): " choice
        echo ""
        
        case $choice in
            1)
                list_disks
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
            2)
                view_mounted
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
            3)
                create_partition
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
            4)
                delete_partition
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
            5)
                format_partition
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
            6)
                mount_partition
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
            7)
                unmount_partition
                read -p "Pressione Enter para continuar / Press Enter to continue..."
                ;;
            8)
                auto_mount
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