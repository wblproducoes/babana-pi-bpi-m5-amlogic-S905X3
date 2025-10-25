#!/bin/bash

#==============================================================================
# SCRIPT BARE-METAL RÁPIDO - BACKUP/RESTAURAÇÃO DE SISTEMA
#==============================================================================
# Nome: baremetal.sh
# Versão: 2.0 (Otimizado)
# Descrição: Script rápido para criar, restaurar, apagar e backup do sistema
# Destino: /media/disk0
# Características: Simples, Rápido, Compactado
#==============================================================================

# Configurações globais
SCRIPT_NAME="BareMetal Fast"
SCRIPT_VERSION="2.0"
BACKUP_DESTINATION="/opt/backups"
BACKUP_PREFIX="backup"

# Cores simples
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Símbolos
OK="✓"
ERR="✗"
WARN="!"

# FUNÇÕES BÁSICAS
#==============================================================================

# Função simples para mensagens
msg() {
    case "$1" in
        "ok")   echo -e "${GREEN}${OK} $2${NC}" ;;
        "err")  echo -e "${RED}${ERR} $2${NC}" ;;
        "warn") echo -e "${YELLOW}${WARN} $2${NC}" ;;
        "info") echo -e "${BLUE}$2${NC}" ;;
        *) echo "$2" ;;
    esac
}

# Verificar root
check_root() {
    [[ $EUID -ne 0 ]] && { msg "err" "Execute como root: sudo $0"; exit 1; }
}

# Preparar destino e verificar espaço
prep_dest() {
    # Criar diretório se não existir
    if [[ ! -d "$BACKUP_DESTINATION" ]]; then
        mkdir -p "$BACKUP_DESTINATION" 2>/dev/null || {
            msg "err" "Não foi possível criar $BACKUP_DESTINATION"
            return 1
        }
    fi
    
    # Verificar se o diretório está acessível
    if [[ ! -w "$BACKUP_DESTINATION" ]]; then
        msg "err" "Sem permissão de escrita em $BACKUP_DESTINATION"
        return 1
    fi
    
    # Verificar espaço disponível (mínimo 5GB para backup no disco principal)
    local available=$(df "$BACKUP_DESTINATION" | awk 'NR==2 {print $4}')
    if [[ $available -lt 5242880 ]]; then  # 5GB em KB
        local space_gb=$((available / 1024 / 1024))
        msg "err" "Espaço insuficiente em $BACKUP_DESTINATION (${space_gb}GB disponível)"
        msg "info" "Mínimo necessário: 5GB para backup no disco principal"
        return 1
    fi
    
    return 0
 }

# FUNÇÕES DE BACKUP RÁPIDO
#==============================================================================

# Criar backup compactado
create_backup() {
    # Verificar preparação do destino
    prep_dest || return 1
    
    local backup_name="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    local backup_path="$BACKUP_DESTINATION/$backup_name"
    
    msg "info" "Criando backup: $backup_name"
    read -p "Confirma? (s/N): " confirm
    [[ ! "$confirm" =~ ^[Ss]$ ]] && { msg "warn" "Cancelado"; return; }
    
    msg "info" "Iniciando backup... (pode demorar)"
    
    # Criar backup com verificação de erro detalhada
    if tar -czf "$backup_path" \
        --exclude=/proc --exclude=/sys --exclude=/dev --exclude=/tmp \
        --exclude=/run --exclude=/mnt --exclude=/media --exclude=/lost+found \
        --exclude=/var/cache --exclude=/var/tmp --exclude=/var/log \
        --exclude=/home/*/.cache --exclude=/home/*/.local/share/Trash \
        --exclude="$BACKUP_DESTINATION" --exclude=/opt/backups \
        / 2>/tmp/backup_error.log; then
        
        local size=$(du -h "$backup_path" 2>/dev/null | cut -f1)
        msg "ok" "Backup criado: $backup_name ($size)"
    else
        msg "err" "Falha no backup"
        if [[ -f /tmp/backup_error.log ]]; then
            msg "info" "Últimos erros:"
            tail -5 /tmp/backup_error.log
        fi
        # Remover backup incompleto
        [[ -f "$backup_path" ]] && rm -f "$backup_path"
    fi
}

# Listar backups
list_backups() {
    prep_dest
    
    msg "info" "Backups em $BACKUP_DESTINATION:"
    echo
    
    local found=false
    for backup in "$BACKUP_DESTINATION"/${BACKUP_PREFIX}_*.tar.gz; do
        if [[ -f "$backup" ]]; then
            found=true
            local name=$(basename "$backup")
            local size=$(du -h "$backup" | cut -f1)
            local date=$(stat -c %y "$backup" | cut -d' ' -f1)
            echo "  $name ($size) - $date"
        fi
    done
    
    [[ "$found" == false ]] && echo "  Nenhum backup encontrado"
    echo
}

# Apagar backup
delete_backup() {
    prep_dest
    
    msg "info" "Backups disponíveis:"
    local backups=()
    local i=1
    
    for backup in "$BACKUP_DESTINATION"/${BACKUP_PREFIX}_*.tar.gz; do
        if [[ -f "$backup" ]]; then
            backups+=("$backup")
            echo "  $i) $(basename "$backup")"
            ((i++))
        fi
    done
    
    if [[ ${#backups[@]} -eq 0 ]]; then
        msg "info" "Nenhum backup encontrado"
        return
    fi
    
    echo
    read -p "Escolha o número do backup para apagar (0 para cancelar): " choice
    
    if [[ "$choice" -gt 0 && "$choice" -le ${#backups[@]} ]]; then
        local selected="${backups[$((choice-1))]}"
        local name=$(basename "$selected")
        
        echo
        msg "warn" "ATENÇÃO: Apagar backup $name?"
        read -p "Digite 'APAGAR' para confirmar: " confirm
        
        if [[ "$confirm" == "APAGAR" ]]; then
            rm -f "$selected"
            msg "ok" "Backup $name apagado"
        else
            msg "info" "Operação cancelada"
        fi
    fi
}

#==============================================================================
# FUNÇÕES DE RESTAURAÇÃO
#==============================================================================

# Restaurar backup
restore_backup() {
    prep_dest
    
    msg "info" "Backups disponíveis:"
    local backups=()
    local i=1
    
    for backup in "$BACKUP_DESTINATION"/${BACKUP_PREFIX}_*.tar.gz; do
        if [[ -f "$backup" ]]; then
            backups+=("$backup")
            echo "  $i) $(basename "$backup")"
            ((i++))
        fi
    done
    
    if [[ ${#backups[@]} -eq 0 ]]; then
        msg "info" "Nenhum backup encontrado"
        return
    fi
    
    echo
    read -p "Escolha o número do backup para restaurar (0 para cancelar): " choice
    
    if [[ "$choice" -gt 0 && "$choice" -le ${#backups[@]} ]]; then
        local selected="${backups[$((choice-1))]}"
        local name=$(basename "$selected")
        
        echo
        msg "warn" "ATENÇÃO: Restaurar irá sobrescrever o sistema atual!"
        read -p "Digite 'RESTAURAR' para confirmar: " confirm
        
        if [[ "$confirm" == "RESTAURAR" ]]; then
            msg "info" "Restaurando $name..."
            
            # Restauração direta do tar compactado
            tar -xzf "$selected" -C / 2>/dev/null
            
            if [[ $? -eq 0 ]]; then
                msg "ok" "Sistema restaurado. Recomenda-se reiniciar."
            else
                msg "err" "Falha na restauração"
            fi
        else
            msg "info" "Operação cancelada"
        fi
    fi
}

#==============================================================================
# FUNÇÕES DE CRIAÇÃO DE SISTEMA
#==============================================================================

# Criar sistema bare-metal mínimo
create_system() {
    # Verificar preparação do destino
    prep_dest || return 1
    
    local system_name="baremetal_$(date +%Y%m%d_%H%M%S)"
    local system_path="$BACKUP_DESTINATION/$system_name"
    
    msg "info" "Criando sistema bare-metal: $system_name"
    read -p "Confirma? (s/N): " confirm
    [[ ! "$confirm" =~ ^[Ss]$ ]] && { msg "warn" "Cancelado"; return; }
    
    msg "info" "Criando estrutura..."
    
    # Criar estrutura básica com verificação de erro
    if ! mkdir -p "$system_path"/{bin,sbin,etc,lib,usr,var,tmp,root,home,proc,sys,dev} 2>/dev/null; then
        msg "err" "Falha ao criar estrutura de diretórios"
        return 1
    fi
    
    # Verificar se os diretórios foram criados
    if [[ ! -d "$system_path/etc" ]]; then
        msg "err" "Falha na criação do diretório etc"
        return 1
    fi
    
    # Arquivos essenciais com verificação
    if ! cat > "$system_path/etc/passwd" << 'EOF' 2>/dev/null
root:x:0:0:root:/root:/bin/bash
EOF
    then
        msg "err" "Falha ao criar /etc/passwd"
        return 1
    fi
    
    cat > "$system_path/etc/group" << 'EOF'
root:x:0:
EOF
    echo "baremetal" > "$system_path/etc/hostname"
    cat > "$system_path/etc/hosts" << 'EOF'
127.0.0.1 localhost baremetal
EOF
    
    # Script init básico
    cat > "$system_path/init" << 'EOF'
#!/bin/bash
echo "Sistema Bare-Metal Iniciado"
exec /bin/bash
EOF
    
    # Permissões (com verificação silenciosa)
    chmod +x "$system_path/init" 2>/dev/null
    chmod 1777 "$system_path/tmp" 2>/dev/null
    chmod 700 "$system_path/root" 2>/dev/null
    
    msg "ok" "Sistema bare-metal criado: $system_name"
}

# INTERFACE SIMPLES
#==============================================================================

show_menu() {
    clear
    echo "=========================================="
    echo "    BACKUP BARE-METAL - v$SCRIPT_VERSION"
    echo "=========================================="
    echo
    echo "1) Criar backup"
    echo "2) Restaurar backup"
    echo "3) Criar sistema bare-metal"
    echo "4) Listar backups"
    echo "5) Apagar backup"
    echo "0) Sair"
    echo
}

process_choice() {
    case "$1" in
        1) create_backup ;;
        2) restore_backup ;;
        3) create_system ;;
        4) list_backups ;;
        5) delete_backup ;;
        0) msg "info" "Saindo..."; exit 0 ;;
        *) msg "err" "Opção inválida" ;;
    esac
    echo
    read -p "Pressione Enter para continuar..."
}

# FUNÇÃO PRINCIPAL
#==============================================================================

main() {
    # Verificações iniciais
    check_root
    
    # Mostrar informação sobre o destino
    msg "info" "Destino dos backups: $BACKUP_DESTINATION"
    
    while true; do
        show_menu
        read -p "Escolha: " choice
        process_choice "$choice"
    done
}

# Executar se chamado diretamente
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"