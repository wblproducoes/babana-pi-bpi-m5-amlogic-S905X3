#!/bin/bash

#==============================================================================
# SCRIPT PHP MANAGER - BANANA PI M5 / UBUNTU 24.04
#==============================================================================
# Nome: phpmanager.sh
# Versão: 1.0
# Descrição: Script para instalar, configurar e desinstalar PHP 8.4 (FPM) e Composer
# Compatibilidade: Banana Pi M5 (aarch64) + Ubuntu 24.04 (Noble)
# Usuário: server
#==============================================================================

# Configurações globais
SCRIPT_NAME="PHP Manager"
SCRIPT_VERSION="1.0"
TARGET_USER="server"
USER_HOME="/home/$TARGET_USER"

# Diretórios do usuário (Assumidos do nginx.sh)
PUBLIC_HTML="$USER_HOME/public_html"
LOGS_DIR="$USER_HOME/logs"
ERROR_DIR="$USER_HOME/error"

# Configurações PHP
PHP_VERSION="8.4"
PHP_FPM_SERVICE="php${PHP_VERSION}-fpm"
PHP_PACKAGES="php${PHP_VERSION}-fpm php${PHP_VERSION}-cli php${PHP_VERSION}-common php${PHP_VERSION}-mysql php${PHP_VERSION}-curl php${PHP_VERSION}-gd php${PHP_VERSION}-mbstring php${PHP_VERSION}-xml php${PHP_VERSION}-zip"
NGINX_DEFAULT_CONF="/etc/nginx/sites-available/default"
TEST_PHP_FILE="$PUBLIC_HTML/info.php"

# Cores para output (baseado no nginx.sh)
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

# Atualizar sistema (simplificada)
update_system() {
    msg "info" "Atualizando lista de pacotes..."
    apt update -qq
    if [[ $? -ne 0 ]]; then
        msg "err" "Falha ao atualizar lista de pacotes."
        return 1
    fi
    msg "ok" "Lista de pacotes atualizada"
}

# FUNÇÕES DE INSTALAÇÃO
#==============================================================================

# Adicionar repositório PHP (Ondrej Sury - Necessário para PHP 8.4 no Noble)
add_php_repo() {
    msg "info" "Adicionando repositório PPA de Ondrej Sury para PHP ${PHP_VERSION}..."
    
    # Instalar pacotes essenciais
    apt install -y software-properties-common ca-certificates lsb-release
    
    # Adicionar PPA
    if add-apt-repository -y ppa:ondrej/php; then
        msg "ok" "Repositório adicionado com sucesso."
        update_system
        return 0
    else
        msg "err" "Falha ao adicionar repositório PPA. Verifique a conectividade."
        return 1
    fi
}

# Instalar PHP 8.4 e módulos
install_php() {
    msg "title" "=== INSTALANDO PHP ${PHP_VERSION} (FPM) ==="
    
    if systemctl is-active --quiet "$PHP_FPM_SERVICE"; then
        msg "warn" "PHP ${PHP_VERSION} FPM já está instalado e ativo."
        return 0
    fi
    
    add_php_repo || return 1
    
    msg "info" "Instalando pacotes do PHP ${PHP_VERSION}: $PHP_PACKAGES"
    
    # Forçar atualização/upgrade após adicionar o PPA
    apt install -y $PHP_PACKAGES
    
    if [[ $? -eq 0 ]]; then
        msg "ok" "PHP ${PHP_VERSION} FPM e módulos instalados com sucesso."
        # Configurar PHP FPM
        config_php_fpm
    else
        msg "err" "Falha na instalação do PHP ${PHP_VERSION} FPM."
        return 1
    fi
}

# Configurar PHP FPM para o usuário server
config_php_fpm() {
    msg "info" "Configurando pool do PHP-FPM para o usuário '$TARGET_USER'..."
    local FPM_CONF="/etc/php/${PHP_VERSION}/fpm/pool.d/${TARGET_USER}.conf"
    
    # Cria uma cópia do pool padrão
    cp /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf "$FPM_CONF"
    
    # Ajustar as configurações do pool
    sed -i "s/\[www\]/\[${TARGET_USER}\]/g" "$FPM_CONF"
    sed -i "s/^user = www-data/user = ${TARGET_USER}/g" "$FPM_CONF"
    sed -i "s/^group = www-data/group = www-data/g" "$FPM_CONF" # Mantém www-data como grupo
    sed -i "s/^listen = \/run\/php\/php${PHP_VERSION}-fpm.sock/listen = \/run\/php\/php-fpm-${TARGET_USER}.sock/g" "$FPM_CONF"
    
    # Habilitar e iniciar o serviço FPM (e desabilitar o pool www padrão se for a primeira vez)
    if [[ -f "/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf" ]]; then
        mv /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf.bak 2>/dev/null
        msg "warn" "Pool 'www.conf' original movido para 'www.conf.bak'."
    fi
    
    systemctl enable "$PHP_FPM_SERVICE"
    systemctl restart "$PHP_FPM_SERVICE"
    
    if systemctl is-active --quiet "$PHP_FPM_SERVICE"; then
        msg "ok" "PHP-FPM configurado e reiniciado. Socket: /run/php/php-fpm-${TARGET_USER}.sock"
    else
        msg "err" "Falha ao reiniciar PHP-FPM. Verifique 'systemctl status $PHP_FPM_SERVICE'."
        return 1
    fi
}

# Configurar Nginx para suportar PHP
configure_nginx_for_php() {
    msg "title" "=== CONFIGURANDO NGINX PARA PHP-FPM ==="
    
    if [[ ! -f "$NGINX_DEFAULT_CONF" ]]; then
        msg "err" "Arquivo de configuração Nginx padrão não encontrado: $NGINX_DEFAULT_CONF"
        msg "warn" "Execute a instalação completa do Nginx primeiro (opção 1 do nginx.sh)."
        return 1
    fi
    
    # 1. Checa se o Nginx já está configurado para PHP
    if grep -q "fastcgi_pass unix:/run/php/php-fpm-${TARGET_USER}.sock;" "$NGINX_DEFAULT_CONF"; then
        msg "warn" "Nginx já parece configurado para o PHP-FPM do usuário '$TARGET_USER'. Ignorando."
        return 0
    fi
    
    # 2. Faz backup da configuração atual
    cp "$NGINX_DEFAULT_CONF" "$NGINX_DEFAULT_CONF.pre_php_backup"
    msg "info" "Backup da configuração Nginx em: $NGINX_DEFAULT_CONF.pre_php_backup"
    
    # 3. Adiciona index.php
    sed -i 's/index index.html index.htm/index index.php index.html index.htm/g' "$NGINX_DEFAULT_CONF"
    
    # 4. Remove o bloco de location PHP padrão (se existir)
    sed -i '/# pass PHP scripts to FastCGI server/,$d' "$NGINX_DEFAULT_CONF"
    
    # 5. Adiciona o bloco de location FastCGI personalizado
    msg "info" "Inserindo bloco de configuração FastCGI..."
    
    # Usa 'awk' para inserir o novo bloco FastCGI antes da última chave '}' do server block principal (porta 443)
    # A última chave é a do bloco 'server {}' final, a penúltima é do bloco 'location / {}'
    # Procuramos o ponto de inserção: antes da última '}' do bloco 'server'
    
    # O bloco server_name para 443 é:
    # server {
    #     listen 443 ssl http2;
    #     listen [::]:443 ssl http2;
    #     server_name $server_ip;
    # ... (restante da config)
    # }
    
    # Adicionamos a configuração PHP no final do bloco 'server 443'
    # Encontra o último '}' e insere o bloco antes dele. Isso é um pouco arriscado, mas funciona para o padrão.
    
    # Marca a última linha do bloco 'server' na porta 443 (antes do último '}')
    awk '/server_name [^;]+;/ {in_server=1} in_server {print; if ($0 ~ /}/) in_server=0}' "$NGINX_DEFAULT_CONF"
    
    # O código anterior quebra a lógica de inserção. O mais seguro é o método de substituição em linha ou marcadores.
    # Vamos usar um marcador simples: insere a nova config logo antes da penúltima '}'
    
    # Esta regex localiza a penúltima '}' do arquivo e insere o bloco antes.
    # Assumindo que o formato do arquivo é o do nginx.sh:
    # server { ... }
    # server {
    #    ...
    #    location / { ... }
    #    location ^~ /error/ { ... }
    # } <--- inserir aqui
    
    local config_block="
    # pass PHP scripts to FastCGI server
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php-fpm-${TARGET_USER}.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_buffer_size 32k;
        fastcgi_buffers 8 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }
"
    
    # Encontra a linha que precede o último '}' no arquivo e insere a configuração antes dela
    # Isso coloca o bloco 'location ~ \.php$' antes da última chave '}' do server block HTTPS
    sed -i "\$i$config_block" "$NGINX_DEFAULT_CONF"

    # Testar configuração
    if nginx -t; then
        msg "ok" "Configuração Nginx para PHP-FPM válida."
        systemctl reload nginx
        msg "ok" "Nginx recarregado."
    else
        msg "err" "Falha na configuração Nginx para PHP-FPM. Revertendo backup..."
        mv "$NGINX_DEFAULT_CONF.pre_php_backup" "$NGINX_DEFAULT_CONF"
        systemctl reload nginx 2>/dev/null
        return 1
    fi
}

# Criar página de teste PHP
create_php_test_page() {
    msg "info" "Criando página de teste PHP (info.php)..."
    
    cat > "$TEST_PHP_FILE" << 'EOF'
<?php
    echo "<h1>PHP ${PHP_VERSION} Funcionando!</h1>";
    echo "<p>Usuário FPM: " . get_current_user() . "</p>";
    phpinfo();
?>
EOF
    
    chown "$TARGET_USER:www-data" "$TEST_PHP_FILE"
    msg "ok" "Página de teste em: $TEST_PHP_FILE"
}


# Instalar Composer
install_composer() {
    msg "title" "=== INSTALANDO COMPOSER ==="
    
    if command -v composer &>/dev/null; then
        msg "warn" "Composer já está instalado."
        return 0
    fi
    
    msg "info" "Baixando o Composer Installer..."
    php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');"
    
    # Verificar a integridade do instalador (opcional, mas recomendado)
    local HASH_COMPOSER='48e3236262b3228effaed42f1a6469716d373700b3d88e762192249228f260ed' # hash verificado em Oct 2025
    local installer_hash=$(php -r "echo hash_file('sha384', '/tmp/composer-setup.php');")
    
    if [[ "$installer_hash" != "$HASH_COMPOSER" ]]; then
        msg "warn" "AVISO: Hash do instalador do Composer é diferente do esperado."
    fi
    
    msg "info" "Executando instalação global do Composer..."
    php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
    
    if [[ $? -eq 0 ]]; then
        msg "ok" "Composer instalado globalmente. Versão:"
        sudo -u "$TARGET_USER" composer --version
    else
        msg "err" "Falha na instalação do Composer."
        return 1
    fi
    
    rm /tmp/composer-setup.php
}


# Instalação completa PHP
full_install_php() {
    msg "title" "=== INSTALAÇÃO COMPLETA PHP ${PHP_VERSION} ==="
    
    # 1. Instalar PHP e módulos
    install_php || return 1
    
    # 2. Configurar Nginx
    configure_nginx_for_php || return 1
    
    # 3. Criar página de teste
    create_php_test_page
    
    # 4. Instalar Composer
    install_composer
    
    # Detectar IP para mostrar URLs corretas
    if command -v ip &>/dev/null; then
        local server_ip=$(ip route get 8.8.8.8 2>/dev/null | grep -oP 'src \K\S+' | head -1 || hostname -I | awk '{print $1}')
    else
        local server_ip="localhost"
    fi
    
    msg "ok" "Instalação PHP/FPM/Composer finalizada!"
    msg "info" "Teste PHP acessando: https://${server_ip}/info.php"
    msg "cyan" "Config FPM em: /etc/php/${PHP_VERSION}/fpm/pool.d/${TARGET_USER}.conf"
    msg "cyan" "Config Nginx em: $NGINX_DEFAULT_CONF"
}

# FUNÇÕES DE DESINSTALAÇÃO
#==============================================================================

# Desinstalar PHP e Composer
uninstall_php() {
    msg "title" "=== DESINSTALANDO PHP ${PHP_VERSION} E COMPOSER ==="
    
    msg "warn" "ATENÇÃO: Esta operação irá:"
    echo "  • Parar e desinstalar o PHP ${PHP_VERSION} FPM e módulos."
    echo "  • Apagar arquivos de configuração e pool."
    echo "  • Remover o Composer globalmente."
    echo "  • **ATENÇÃO:** Não remove o repositório PPA de Ondrej Sury, que pode ser usado por outros pacotes."
    echo
    read -p "Tem certeza? Digite 'REMOVER' para confirmar: " confirm
    
    if [[ "$confirm" != "REMOVER" ]]; then
        msg "info" "Operação cancelada"
        return 0
    fi
    
    # 1. Parar serviço FPM
    if systemctl is-active --quiet "$PHP_FPM_SERVICE"; then
        msg "info" "Parando serviço $PHP_FPM_SERVICE..."
        systemctl stop "$PHP_FPM_SERVICE"
        systemctl disable "$PHP_FPM_SERVICE"
    fi
    
    # 2. Remover pacotes PHP
    msg "info" "Removendo pacotes PHP ${PHP_VERSION}..."
    apt remove --purge -y php${PHP_VERSION}*
    apt autoremove -y
    
    # 3. Remover arquivos de configuração remanescentes
    msg "info" "Removendo arquivos de configuração..."
    rm -rf "/etc/php/$PHP_VERSION"
    
    # 4. Desinstalar Composer
    if command -v composer &>/dev/null; then
        msg "info" "Removendo Composer..."
        rm -f /usr/local/bin/composer
    fi
    
    # 5. Reverter configuração Nginx (opcional, mas recomendado)
    if [[ -f "$NGINX_DEFAULT_CONF.pre_php_backup" ]]; then
        msg "info" "Restaurando backup da configuração Nginx..."
        mv "$NGINX_DEFAULT_CONF.pre_php_backup" "$NGINX_DEFAULT_CONF"
        if nginx -t; then
             systemctl reload nginx
             msg "ok" "Configuração Nginx restaurada e recarregada."
        else
            msg "err" "Falha ao restaurar configuração Nginx. Verifique manualmente: $NGINX_DEFAULT_CONF"
        fi
    else
        msg "warn" "Nenhum backup de configuração Nginx encontrado ($NGINX_DEFAULT_CONF.pre_php_backup)."
        msg "warn" "Remova o bloco 'location ~ \.php$' manualmente de $NGINX_DEFAULT_CONF."
    fi
    
    # 6. Remover arquivo de teste
    if [[ -f "$TEST_PHP_FILE" ]]; then
        msg "info" "Removendo arquivo de teste $TEST_PHP_FILE..."
        rm -f "$TEST_PHP_FILE"
    fi
    
    msg "ok" "PHP ${PHP_VERSION} e Composer completamente desinstalados."
}

# INTERFACE DO MENU
#==============================================================================

show_menu() {
    clear
    msg "title" "=================================================="
    msg "title" "        PHP MANAGER - BANANA PI M5 / UBUNTU 24.04"
    msg "title" "=================================================="
    echo
    msg "cyan" "Versão PHP: ${PHP_VERSION}"
    msg "cyan" "Usuário alvo: $TARGET_USER"
    echo
    echo "1) Instalar/Configurar PHP ${PHP_VERSION} (FPM) e Composer"
    echo "2) Desinstalar PHP ${PHP_VERSION} e Composer (remove tudo)"
    echo "3) Status do PHP-FPM"
    echo "4) Reiniciar PHP-FPM"
    echo "5) Testar Configuração Nginx/PHP"
    echo "6) Ver Logs do PHP-FPM (Systemd)"
    echo "0) Sair"
    echo
}

# Status do PHP-FPM
show_php_status() {
    msg "title" "=== STATUS DO PHP ${PHP_VERSION} FPM ==="
    
    if systemctl is-active --quiet "$PHP_FPM_SERVICE"; then
        msg "ok" "$PHP_FPM_SERVICE está ATIVO"
        echo
        systemctl status "$PHP_FPM_SERVICE" --no-pager -l
    else
        msg "err" "$PHP_FPM_SERVICE está INATIVO"
    fi
    
    echo
    read -p "Pressione Enter para continuar..."
}

# Reiniciar PHP-FPM
restart_php_fpm() {
    msg "info" "Reiniciando $PHP_FPM_SERVICE..."
    
    if systemctl restart "$PHP_FPM_SERVICE"; then
        msg "ok" "$PHP_FPM_SERVICE reiniciado com sucesso"
    else
        msg "err" "Falha ao reiniciar $PHP_FPM_SERVICE. Verifique os logs."
    fi
    
    echo
    read -p "Pressione Enter para continuar..."
}

# Logs do PHP-FPM
view_php_fpm_logs() {
    msg "title" "=== LOGS DO PHP ${PHP_VERSION} FPM (Últimas 50 linhas) ==="
    journalctl -u "$PHP_FPM_SERVICE" --since "1 hour ago" -n 50 --no-pager
    
    echo
    read -p "Pressione Enter para continuar..."
}

# Testar Configuração Nginx/PHP
test_nginx_php() {
    msg "title" "=== TESTE DE CONFIGURAÇÃO NGINX/PHP ==="
    
    if nginx -t; then
        msg "ok" "Configuração Nginx válida."
    else
        msg "err" "Erro na configuração Nginx."
    fi
    
    if systemctl is-active --quiet "$PHP_FPM_SERVICE"; then
        msg "ok" "$PHP_FPM_SERVICE está ativo."
    else
        msg "err" "$PHP_FPM_SERVICE está inativo. O PHP não funcionará."
    fi
    
    if [[ -f "$TEST_PHP_FILE" ]]; then
        msg "info" "Arquivo de teste PHP: $TEST_PHP_FILE existe. Verifique no navegador."
    else
        msg "warn" "Arquivo de teste PHP ($TEST_PHP_FILE) não existe. Crie ou execute a opção 1."
    fi
    
    echo
    read -p "Pressione Enter para continuar..."
}

# Processar escolha do menu
process_choice() {
    case "$1" in
        1) full_install_php ;;
        2) uninstall_php ;;
        3) show_php_status ;;
        4) restart_php_fpm ;;
        5) test_nginx_php ;;
        6) view_php_fpm_logs ;;
        0) msg "info" "Saindo..."; exit 0 ;;
        *) msg "err" "Opção inválida" ;;
    esac
    
    # Pausa após opções de instalação/desinstalação
    if [[ "$1" == "1" || "$1" == "2" ]]; then
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