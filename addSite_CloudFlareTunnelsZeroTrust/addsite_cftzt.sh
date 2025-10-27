#!/bin/bash

#==============================================================================
# SCRIPT VHOST MANAGER - BANANA PI M5 / UBUNTU 24.04
#==============================================================================
# Nome: vhostmanager.sh
# Versão: 2.0 (Configuração Nginx Otimizada para Cloudflare Tunnel)
# Descrição: Script para criar, configurar e remover VHOSTs/Usuários completos (LEMP)
# Compatibilidade: Banana Pi M5 (aarch64) + Ubuntu 24.04 (Noble)
#==============================================================================

# Configurações globais
SCRIPT_NAME="VHost Manager"
SCRIPT_VERSION="2.0"
NGINX_CONF_DIR="/etc/nginx/sites-available"
NGINX_ENABLED_DIR="/etc/nginx/sites-enabled"
HOSTS_FILE="/etc/hosts"
PHPMYADMIN_DIR="/usr/share/phpmyadmin"

# Cores para output
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

# Variáveis dinâmicas (serão preenchidas no menu de gerenciar)
CURRENT_USER=""
CURRENT_DOMAIN=""

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

# FUNÇÕES DE VALIDAÇÃO
#==============================================================================

# Validar nome de usuário (apenas letras minúsculas e números)
validate_user_name() {
    if [[ "$1" =~ ^[a-z0-9]+$ ]]; then
        return 0
    else
        msg "err" "Nome de usuário inválido. Use apenas letras minúsculas e números."
        return 1
    fi
}

# Validar nome de domínio
validate_domain() {
    # Regex simples para validar a estrutura do domínio
    if [[ "$1" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*\.[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        msg "err" "Domínio inválido."
        return 1
    fi
}

# Detectar IP do sistema (silenciosa)
get_server_ip_silent() {
    # Tenta diferentes métodos para obter o IP
    local server_ip
    server_ip=$(ip route get 8.8.8.8 2>/dev/null | grep -oP 'src \K\S+' | head -1)
    if [[ -z "$server_ip" ]]; then
        server_ip=$(hostname -I | awk '{print $1}')
    fi
    if [[ -z "$server_ip" ]]; then
        server_ip="127.0.0.1"
    fi
    echo "$server_ip"
}

# FUNÇÕES DE CRIAÇÃO (ADD VHOST)
#==============================================================================

# Criar usuário e adicionar ao grupo www-data
create_user_and_set_password() {
    local user_name="$1"
    local user_home="/home/$user_name"
    
    if id "$user_name" &>/dev/null; then
        msg "warn" "Usuário '$user_name' já existe."
        return 0
    fi

    msg "info" "Criando usuário '$user_name'..."
    useradd -m -s /bin/bash "$user_name"
    
    if [[ $? -ne 0 ]]; then
        msg "err" "Falha ao criar usuário '$user_name'."
        return 1
    fi

    # Solicitar e definir a senha
    while true; do
        read -s -p "Digite a senha para o usuário $user_name: " user_pass
        echo
        read -s -p "Confirme a senha: " user_pass_confirm
        echo
        if [[ "$user_pass" == "$user_pass_confirm" && -n "$user_pass" ]]; then
            echo "$user_name:$user_pass" | chpasswd
            msg "ok" "Senha definida para o usuário '$user_name'."
            break
        else
            msg "err" "Senhas não conferem ou estão vazias. Tente novamente."
        fi
    done
    
    # Adicionar ao grupo www-data
    msg "info" "Adicionando usuário '$user_name' ao grupo www-data..."
    usermod -a -G www-data "$user_name"
    msg "ok" "Usuário '$user_name' criado e adicionado a 'www-data'."
}

# Criar estrutura de diretórios e definir permissões
create_vhost_directories() {
    local user_name="$1"
    local user_home="/home/$user_name"
    
    msg "info" "Criando estrutura de diretórios para $user_name..."
    local public_html="$user_home/public_html"
    local logs_dir="$user_home/logs"
    local error_dir="$user_home/error"
    local ssl_dir="$user_home/ssl"
    
    mkdir -p "$public_html" "$logs_dir" "$error_dir" "$ssl_dir"
    
    # Definir permissões
    chown -R "$user_name:www-data" "$user_home"
    chmod 755 "$public_html" "$error_dir"
    chmod 750 "$logs_dir" "$ssl_dir"
    
    # Permissões específicas para www-data (Nginx e FPM)
    chmod g+w "$public_html" "$logs_dir"
    chmod g+r "$ssl_dir" "$error_dir"
    
    msg "ok" "Estrutura de diretórios e permissões definidas."
}

# Gerar certificado SSL auto-assinado (Mantido, mas não usado pelo Nginx com Cloudflare Tunnel)
generate_vhost_ssl() {
    local user_name="$1"
    local domain_name="$2"
    local ssl_dir="/home/$user_name/ssl"
    
    msg "info" "Gerando certificado SSL auto-assinado (Apenas para uso interno/debug)..."
    
    # Gerar chave privada
    openssl genrsa -out "$ssl_dir/$domain_name.key" 2048
    
    # Gerar certificado com domínio como CN
    openssl req -new -x509 -key "$ssl_dir/$domain_name.key" -out "$ssl_dir/$domain_name.crt" -days 365 -subj "/C=BR/ST=SP/L=SaoPaulo/O=VHost/OU=Server/CN=$domain_name"
    
    # Definir permissões seguras
    chmod 600 "$ssl_dir/$domain_name.key"
    chmod 644 "$ssl_dir/$domain_name.crt"
    chown "$user_name:www-data" "$ssl_dir"/*
    
    msg "ok" "Certificado SSL gerado em $ssl_dir"
}

# Criar arquivos de conteúdo (index.php, info.php, páginas de erro)
create_vhost_content() {
    local user_name="$1"
    local domain_name="$2"
    local public_html="/home/$user_name/public_html"
    local error_dir="/home/$user_name/error"
    
    # Arquivo index.php (Bootstrap 5.3 Moderno)
    msg "info" "Criando index.php e info.php..."
    cat > "$public_html/index.php" << EOF
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Servidor Web - $domain_name</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        .hero {
            background: linear-gradient(45deg, #0d6efd, #6f42c1);
            color: white;
            padding: 80px 0;
            border-radius: 10px;
            margin-top: 50px;
        }
    </style>
</head>
<body>
    <div class="container text-center">
        <div class="hero shadow">
            <h1 class="display-4">🎉 VHost Ativo: $domain_name</h1>
            <p class="lead">Este servidor está rodando Nginx e PHP-FPM no seu Banana Pi M5 (aarch64).</p>
            <p class="mt-4">
                <a href="/info.php" class="btn btn-warning btn-lg me-2">Ver PHP Info</a>
                <a href="/phpmyadmin" class="btn btn-light btn-lg">Acessar phpMyAdmin</a>
            </p>
        </div>
        <div class="alert alert-info mt-5">
            <strong>Usuário FTP/SSH:</strong> $user_name
        </div>
        <footer class="mt-5 text-muted">
            <p>Gerenciado por VHost Manager v$SCRIPT_VERSION</p>
        </footer>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
EOF

    # Arquivo info.php
    echo '<?php phpinfo(); ?>' > "$public_html/info.php"
    
    # Criar páginas de erro personalizadas (usando a base do seu script)
    local error_template="
<!DOCTYPE html>
<html lang=\"pt-BR\">
<head>
    <meta charset=\"UTF-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
    <title>%TITLE%</title>
    <link href=\"https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css\" rel=\"stylesheet\">
</head>
<body class=\"bg-light\">
    <div class=\"container\">
        <div class=\"row justify-content-center align-items-center min-vh-100\">
            <div class=\"col-md-6 text-center\">
                <div class=\"card shadow-lg border-%COLOR%\">
                    <div class=\"card-body p-5\">
                        <h1 class=\"display-1 text-%COLOR%\">%CODE%</h1>
                        <h2 class=\"mb-3\">%MESSAGE%</h2>
                        <p class=\"lead\">%DESCRIPTION%</p>
                        <a href=\"/\" class=\"btn btn-primary mt-3\">Voltar ao Início</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
"
    
    # 403 - Forbidden
    echo "${error_template}" | sed "s/%TITLE%/403 - Acesso Negado/; s/%CODE%/403/; s/%MESSAGE%/Acesso Negado/; s/%DESCRIPTION%/Você não tem permissão para acessar este recurso./; s/%COLOR%/danger/" > "$error_dir/403.html"
    
    # 404 - Not Found
    echo "${error_template}" | sed "s/%TITLE%/404 - Não Encontrado/; s/%CODE%/404/; s/%MESSAGE%/Página Não Encontrada/; s/%DESCRIPTION%/O recurso que você tentou acessar não existe./; s/%COLOR%/warning/" > "$error_dir/404.html"

    # 405 - Method Not Allowed
    echo "${error_template}" | sed "s/%TITLE%/405 - Método Não Permitido/; s/%CODE%/405/; s/%MESSAGE%/Método Não Permitido/; s/%DESCRIPTION%/O método HTTP usado não é permitido para este recurso./; s/%COLOR%/info/" > "$error_dir/405.html"
    
    # 500 - Internal Server Error
    echo "${error_template}" | sed "s/%TITLE%/500 - Erro Interno/; s/%CODE%/500/; s/%MESSAGE%/Erro Interno do Servidor/; s/%DESCRIPTION%/Ocorreu um erro interno. Tente novamente mais tarde./; s/%COLOR%/danger/" > "$error_dir/500.html"

    # Permissões do conteúdo
    chown "$user_name:www-data" "$public_html"/{index.php,info.php}
    chown -R "$user_name:www-data" "$error_dir"
    
    msg "ok" "Conteúdo e páginas de erro criados."
}

# Criar link simbólico do phpMyAdmin
create_phpmyadmin_symlink() {
    local user_name="$1"
    local public_html="/home/$user_name/public_html"
    local phpmyadmin_link="$public_html/phpmyadmin"

    if [[ ! -d "$PHPMYADMIN_DIR" ]]; then
        msg "err" "phpMyAdmin não instalado em $PHPMYADMIN_DIR. Instale-o primeiro."
        return 1
    fi
    
    msg "info" "Criando link simbólico para phpMyAdmin..."
    ln -s "$PHPMYADMIN_DIR" "$phpmyadmin_link" 2>/dev/null
    
    if [[ $? -eq 0 ]]; then
        chown "$user_name:www-data" "$phpmyadmin_link"
        msg "ok" "Link phpmyadmin criado: $phpmyadmin_link"
    else
        msg "warn" "Link já pode existir ou falha na criação."
    fi
}

# Criar arquivo de configuração Nginx para o VHost - OTIMIZADO PARA CLOUDFLARE TUNNEL
create_nginx_vhost_conf() {
    local user_name="$1"
    local domain_name="$2"
    local conf_file="$NGINX_CONF_DIR/$domain_name.conf"
    local user_home="/home/$user_name"
    local logs_dir="$user_home/logs"
    local public_html="$user_home/public_html"
    local fpm_sock="/run/php/php-fpm-${user_name}.sock" 
    
    msg "info" "Criando arquivo de configuração Nginx para $domain_name (APENAS HTTP/80 - Cloudflare Tunnel)..."

    # Verifica se o socket FPM existe ou usa um padrão
    if [[ ! -S "$fpm_sock" ]]; then
        msg "warn" "Socket FPM '$fpm_sock' não encontrado. Usando php8.4-fpm.sock como fallback."
        fpm_sock="/run/php/php8.4-fpm.sock" 
    fi
    
    # Apenas o bloco HTTP (porta 80) é criado. O redirecionamento e SSL são removidos.
    cat > "$conf_file" << EOF
server {
    listen 80;
    listen [::]:80;
    server_name $domain_name www.$domain_name;

    # Tráfego vindo do Cloudflare Tunnel (já seguro) é recebido aqui.
    
    # Document Root
    root $public_html;
    index index.php index.html index.htm;
    
    # Logs personalizados
    access_log $logs_dir/access.log;
    error_log $logs_dir/error.log;
    
    # Main location
    location / {
        try_files \$uri \$uri/ =404;
    }
    
    # Error pages personalizadas
    error_page 403 /error/403.html;
    error_page 404 /error/404.html;
    error_page 405 /error/405.html;
    error_page 500 502 503 504 /error/500.html;
    
    location ^~ /error/ {
        internal;
        root $user_home;
    }
    
    # Passa scripts PHP para o FastCGI
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:$fpm_sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
    
    # Security headers (Ainda relevantes)
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
}
EOF

    # Habilitar configuração
    ln -s "$conf_file" "$NGINX_ENABLED_DIR/" 2>/dev/null
    
    # Testar e Recarregar Nginx
    if nginx -t; then
        msg "ok" "Configuração Nginx válida (Cloudflare Otimizada)."
        systemctl reload nginx
        msg "ok" "Nginx recarregado. VHost $domain_name ativo!"
        msg "warn" "Certifique-se de que o pool PHP-FPM para '$user_name' foi criado."
    else
        msg "err" "Erro na configuração Nginx."
        rm -f "$NGINX_ENABLED_DIR/$domain_name.conf"
        return 1
    fi
}

# Adicionar domínio ao /etc/hosts (Apenas para testes locais)
add_domain_to_hosts() {
    local domain_name="$1"
    local server_ip=$(get_server_ip_silent)
    
    msg "info" "Adicionando $domain_name ao $HOSTS_FILE para teste local..."
    
    if grep -q "$domain_name" "$HOSTS_FILE"; then
        msg "warn" "$domain_name já está em $HOSTS_FILE. Ignorando."
    else
        echo "$server_ip $domain_name www.$domain_name" >> "$HOSTS_FILE"
        msg "ok" "Adicionado: $server_ip $domain_name"
        msg "warn" "LEMBRETE: Você deve adicionar esta entrada ao seu arquivo hosts local (do seu PC) para testar."
    fi
}

# Função principal de criação
add_vhost() {
    msg "title" "=== CRIAÇÃO DE NOVO VHOST ==="
    
    # 1. Perguntar nome do usuário
    local user_name
    while true; do
        read -p "Digite o nome do NOVO USUÁRIO (ex: cliente1): " user_name
        if validate_user_name "$user_name"; then
            break
        fi
    done

    # 2. Perguntar nome do domínio
    local domain_name
    while true; do
        read -p "Digite o NOME DO DOMÍNIO (ex: meuprojeto.com.br): " domain_name
        if validate_domain "$domain_name"; then
            break
        fi
    done
    
    local user_home="/home/$user_name"
    
    # Inicia o processo
    create_user_and_set_password "$user_name" || return 1
    create_vhost_directories "$user_name"
    generate_vhost_ssl "$user_name" "$domain_name" # Certificado gerado, mas Nginx não o usa.
    create_vhost_content "$user_name" "$domain_name"
    create_phpmyadmin_symlink "$user_name"
    
    # === CHAMADA OTIMIZADA ===
    create_nginx_vhost_conf "$user_name" "$domain_name" || return 1
    
    add_domain_to_hosts "$domain_name"
    
    msg "ok" "VHOST '$domain_name' criado com sucesso!"
    msg "cyan" "Configuração Nginx: Porta 80 APENAS (Pronta para Cloudflare Tunnel)"
    msg "cyan" "Acesso: https://$domain_name (via Cloudflare)"
}

# FUNÇÕES DE REMOÇÃO (DELETE VHOST)
#==============================================================================

# Remover VHost
remove_vhost() {
    msg "title" "=== REMOÇÃO DE VHOST/USUÁRIO ==="
    
    local user_name
    read -p "Digite o nome do USUÁRIO a ser removido: " user_name
    
    if ! id "$user_name" &>/dev/null; then
        msg "err" "Usuário '$user_name' não existe. Abortando."
        return 1
    fi
    
    local user_home="/home/$user_name"
    local domain_name=$(ls "$NGINX_CONF_DIR" | grep -E "^${user_name}\." | sed 's/\.conf$//' | head -1)

    msg "warn" "ATENÇÃO: Você está prestes a remover o usuário '$user_name' e TUDO em '$user_home' (incluindo dados do site e certificados)."
    echo "Domínios associados (se houver): $domain_name"
    echo
    read -p "Confirme a remoção PERMANENTE digitando o nome do usuário ($user_name): " confirm_user
    
    if [[ "$confirm_user" != "$user_name" ]]; then
        msg "info" "Remoção cancelada."
        return 0
    fi
    
    # 1. Desabilitar Nginx
    msg "info" "Removendo configuração Nginx..."
    if [[ -n "$domain_name" ]]; then
        rm -f "$NGINX_ENABLED_DIR/$domain_name.conf"
        rm -f "$NGINX_CONF_DIR/$domain_name.conf"
        # Remover do /etc/hosts
        sed -i "/$domain_name/d" "$HOSTS_FILE"
        systemctl reload nginx 2>/dev/null
        msg "ok" "Configurações Nginx e hosts para $domain_name removidas."
    fi
    
    # 2. Remover o usuário e sua pasta home
    msg "info" "Removendo usuário '$user_name' e sua pasta home ($user_home)..."
    userdel -r "$user_name"
    
    # Garantir que a pasta home foi removida (caso userdel falhe)
    if [[ -d "$user_home" ]]; then
        msg "warn" "Pasta home '$user_home' ainda existe. Forçando remoção..."
        rm -rf "$user_home"
    fi

    if ! id "$user_name" &>/dev/null; then
        msg "ok" "VHost/Usuário '$user_name' completamente removido."
    else
        msg "err" "Falha na remoção completa do usuário."
    fi
}

# FUNÇÕES DE GERENCIAMENTO
#==============================================================================

# Menu de Gerenciamento (funções inalteradas)
manage_vhost_menu() {
    local domain_name
    local user_name
    
    msg "title" "=== GERENCIAMENTO DE VHOST ==="
    read -p "Digite o nome do DOMÍNIO/USUÁRIO que deseja gerenciar: " input
    
    # Tentar encontrar o usuário/domínio correspondente
    if id "$input" &>/dev/null; then
        user_name="$input"
        domain_name=$(ls "$NGINX_CONF_DIR" | grep -E "^${user_name}\." | sed 's/\.conf$//' | head -1)
    else
        domain_name="$input"
        # Tentar obter o nome do usuário a partir da conf Nginx (mais complexo, vamos simplificar)
        if [[ -f "$NGINX_CONF_DIR/$domain_name.conf" ]]; then
             user_home=$(grep 'root ' "$NGINX_CONF_DIR/$domain_name.conf" | head -1 | awk '{print $2}' | sed 's/\/public_html;//;s/"//g')
             user_name=$(basename "$user_home")
        fi
    fi
    
    if [[ -z "$user_name" || ! -d "/home/$user_name" ]]; then
        msg "err" "Usuário/VHost não encontrado para o nome/domínio '$input'."
        read -p "Pressione Enter para continuar..."
        return
    fi
    
    local conf_file="$NGINX_CONF_DIR/$domain_name.conf"

    while true; do
        clear
        msg "title" "--- Gerenciando VHost: $domain_name (Usuário: $user_name) ---"
        msg "cyan" "Config: $conf_file"
        msg "cyan" "Root: /home/$user_name/public_html"
        echo
        echo "1) 👁️  Ver arquivo Nginx (CAT)"
        echo "2) 📝 Editar arquivo Nginx (NANO)"
        echo "3) 🧪 Testar e Recarregar Nginx"
        echo "4) 🔄 Re-criar Certificado SSL (Apenas para uso interno/debug)"
        echo "0) ↩️ Voltar ao Menu Principal"
        echo
        read -p "Escolha uma opção: " choice
        echo
        
        case "$choice" in
            1) msg "title" "=== $domain_name.conf (Nginx) ==="; cat "$conf_file" || msg "err" "Arquivo não encontrado."; read -p "Pressione Enter para continuar..." ;;
            2) nano "$conf_file"; msg "warn" "Após editar, use a opção 3 para testar/recarregar."; read -p "Pressione Enter para continuar..." ;;
            3) if nginx -t; then msg "ok" "Configuração Nginx válida."; systemctl reload nginx; msg "ok" "Nginx recarregado."; else msg "err" "Erro na configuração Nginx."; fi; read -p "Pressione Enter para continuar..." ;;
            4) generate_vhost_ssl "$user_name" "$domain_name"; read -p "Pressione Enter para continuar..." ;;
            0) break ;;
            *) msg "err" "Opção inválida" ;;
        esac
    done
}


# INTERFACE DO MENU
#==============================================================================

show_menu() {
    clear
    msg "title" "=================================================="
    msg "title" "     VHOST MANAGER - BANANA PI M5 / UBUNTU 24.04"
    msg "title" "=================================================="
    echo
    msg "cyan" "Status: Nginx - $(systemctl is-active nginx &>/dev/null && echo "${GREEN}ATIVO${NC}" || echo "${RED}INATIVO${NC}")"
    msg "cyan" "Status: PHP-FPM - $(systemctl is-active php8.4-fpm &>/dev/null && echo "${GREEN}ATIVO${NC}" || echo "${RED}INATIVO${NC}")"
    echo
    echo "1) ➕ Criar Novo VHost e Usuário Completo (CF Tunnel Otimizado)"
    echo "2) ⚙️ Gerenciar VHost Existente (Nginx/SSL)"
    echo "3) ➖ Remover VHost e Usuário (DESTRUTIVO!)"
    echo "0) 🚪 Sair"
    echo
}

# Processar escolha do menu principal
process_choice() {
    case "$1" in
        1) add_vhost ;;
        2) manage_vhost_menu ;;
        3) remove_vhost ;;
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
    
    while true; do
        show_menu
        read -p "Escolha uma opção: " choice
        echo
        process_choice "$choice"
    done
}

# Executar se chamado diretamente
[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"