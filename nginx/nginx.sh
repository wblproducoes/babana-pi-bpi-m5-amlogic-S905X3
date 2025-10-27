#!/bin/bash

#==============================================================================
# SCRIPT NGINX MANAGER - BANANA PI M5 / UBUNTU 24.04
#==============================================================================
# Nome: nginx.sh
# Versão: 1.0
# Descrição: Script para instalar, configurar e gerenciar Nginx
# Compatibilidade: Banana Pi M5 (aarch64) + Ubuntu 24.04 (Noble)
# Usuário: server
#==============================================================================

# Configurações globais
SCRIPT_NAME="Nginx Manager"
SCRIPT_VERSION="1.0"
TARGET_USER="server"
USER_HOME="/home/$TARGET_USER"

# Diretórios do usuário
PUBLIC_HTML="$USER_HOME/public_html"
LOGS_DIR="$USER_HOME/logs"
SSL_DIR="$USER_HOME/ssl"
ERROR_DIR="$USER_HOME/error"

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

# Verificar se usuário existe
check_user() {
    if ! id "$TARGET_USER" &>/dev/null; then
        msg "err" "Usuário '$TARGET_USER' não existe"
        msg "info" "Criando usuário '$TARGET_USER'..."
        useradd -m -s /bin/bash "$TARGET_USER"
        msg "ok" "Usuário '$TARGET_USER' criado"
    fi
}

# Detectar IP do sistema (versão silenciosa para uso em configurações)
get_server_ip_silent() {
    # Tentar diferentes métodos para obter o IP
    local server_ip
    
    # Método 1: IP da interface principal (mais confiável)
    server_ip=$(ip route get 8.8.8.8 2>/dev/null | grep -oP 'src \K\S+' | head -1)
    
    # Método 2: Fallback para hostname -I
    if [[ -z "$server_ip" ]]; then
        server_ip=$(hostname -I | awk '{print $1}')
    fi
    
    # Método 3: Fallback para interface eth0/enp
    if [[ -z "$server_ip" ]]; then
        server_ip=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2}' | cut -d'/' -f1)
    fi
    
    # Fallback final para localhost se nada funcionar
    if [[ -z "$server_ip" ]]; then
        server_ip="localhost"
    fi
    
    echo "$server_ip"
}

# Detectar IP do sistema (versão com mensagens para interface)
get_server_ip() {
    local server_ip=$(get_server_ip_silent)
    
    if [[ "$server_ip" == "localhost" ]]; then
        msg "warn" "Não foi possível detectar IP, usando localhost"
    else
        msg "info" "IP detectado: $server_ip"
    fi
    
    echo "$server_ip"
}

# Atualizar sistema
update_system() {
    msg "info" "Atualizando sistema..."
    apt update -qq && apt upgrade -y -qq
    msg "ok" "Sistema atualizado"
}

# FUNÇÕES DE INSTALAÇÃO
#==============================================================================

# Instalar Nginx
install_nginx() {
    msg "title" "=== INSTALANDO NGINX ==="
    
    # Verificar se já está instalado
    if systemctl is-active --quiet nginx; then
        msg "warn" "Nginx já está instalado e ativo"
        return 0
    fi
    
    update_system
    
    msg "info" "Instalando Nginx..."
    apt install -y nginx openssl
    
    if [[ $? -eq 0 ]]; then
        msg "ok" "Nginx instalado com sucesso"
        systemctl enable nginx
        systemctl start nginx
        msg "ok" "Nginx iniciado e habilitado"
    else
        msg "err" "Falha na instalação do Nginx"
        return 1
    fi
}

# Criar estrutura de diretórios
create_directories() {
    msg "info" "Criando estrutura de diretórios para usuário '$TARGET_USER'..."
    
    # Adicionar usuário ao grupo www-data
    msg "info" "Adicionando usuário '$TARGET_USER' ao grupo www-data..."
    usermod -a -G www-data "$TARGET_USER"
    
    # Criar diretórios
    mkdir -p "$PUBLIC_HTML" "$LOGS_DIR" "$SSL_DIR" "$ERROR_DIR"
    
    # Definir permissões com grupo www-data
    chown -R "$TARGET_USER:www-data" "$USER_HOME"/{public_html,logs,ssl,error}
    chmod 755 "$PUBLIC_HTML" "$ERROR_DIR"
    chmod 750 "$LOGS_DIR" "$SSL_DIR"
    
    # Permissões específicas para www-data
    chmod g+w "$PUBLIC_HTML" "$LOGS_DIR"
    chmod g+r "$SSL_DIR" "$ERROR_DIR"
    
    msg "ok" "Estrutura de diretórios criada com permissões www-data"
}

# Criar página inicial
create_index_page() {
    cat > "$PUBLIC_HTML/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Servidor Nginx - Banana Pi M5</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .hero-section {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 100px 0;
        }
    </style>
</head>
<body>
    <div class="hero-section">
        <div class="container text-center">
            <h1 class="display-4 mb-4">🍌 Banana Pi M5 Server</h1>
            <p class="lead">Nginx rodando no Ubuntu 24.04 (aarch64)</p>
            <p class="mb-4">Servidor configurado e funcionando perfeitamente!</p>
            <div class="row mt-5">
                <div class="col-md-4">
                    <div class="card bg-transparent border-light">
                        <div class="card-body">
                            <h5 class="card-title">⚡ Performance</h5>
                            <p class="card-text">Otimizado para ARM64</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card bg-transparent border-light">
                        <div class="card-body">
                            <h5 class="card-title">🔒 Segurança</h5>
                            <p class="card-text">SSL/TLS Configurado</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card bg-transparent border-light">
                        <div class="card-body">
                            <h5 class="card-title">📊 Monitoramento</h5>
                            <p class="card-text">Logs Personalizados</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="container my-5">
        <div class="row">
            <div class="col-lg-8 mx-auto">
                <h2 class="text-center mb-4">Informações do Servidor</h2>
                <div class="table-responsive">
                    <table class="table table-striped">
                        <tr><td><strong>Servidor Web</strong></td><td>Nginx</td></tr>
                        <tr><td><strong>Sistema Operacional</strong></td><td>Ubuntu 24.04 LTS</td></tr>
                        <tr><td><strong>Arquitetura</strong></td><td>aarch64 (ARM64)</td></tr>
                        <tr><td><strong>Hardware</strong></td><td>Banana Pi M5</td></tr>
                        <tr><td><strong>Data/Hora</strong></td><td id="datetime"></td></tr>
                    </table>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.getElementById('datetime').textContent = new Date().toLocaleString('pt-BR');
    </script>
</body>
</html>
EOF
    
    chown "$TARGET_USER:www-data" "$PUBLIC_HTML/index.html"
    msg "ok" "Página inicial criada"
}

# Criar páginas de erro
create_error_pages() {
    msg "info" "Criando páginas de erro com Bootstrap 5.3..."
    
    # Página 403 - Forbidden
    cat > "$ERROR_DIR/403.html" << 'EOF'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>403 - Acesso Negado</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container">
        <div class="row justify-content-center align-items-center min-vh-100">
            <div class="col-md-6 text-center">
                <div class="card shadow">
                    <div class="card-body p-5">
                        <h1 class="display-1 text-danger">403</h1>
                        <h2 class="mb-3">Acesso Negado</h2>
                        <p class="lead">Você não tem permissão para acessar este recurso.</p>
                        <a href="/" class="btn btn-primary">Voltar ao Início</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
EOF

    # Página 404 - Not Found
    cat > "$ERROR_DIR/404.html" << 'EOF'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 - Página Não Encontrada</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container">
        <div class="row justify-content-center align-items-center min-vh-100">
            <div class="col-md-6 text-center">
                <div class="card shadow">
                    <div class="card-body p-5">
                        <h1 class="display-1 text-warning">404</h1>
                        <h2 class="mb-3">Página Não Encontrada</h2>
                        <p class="lead">A página que você está procurando não existe.</p>
                        <a href="/" class="btn btn-primary">Voltar ao Início</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
EOF

    # Página 405 - Method Not Allowed
    cat > "$ERROR_DIR/405.html" << 'EOF'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>405 - Método Não Permitido</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container">
        <div class="row justify-content-center align-items-center min-vh-100">
            <div class="col-md-6 text-center">
                <div class="card shadow">
                    <div class="card-body p-5">
                        <h1 class="display-1 text-info">405</h1>
                        <h2 class="mb-3">Método Não Permitido</h2>
                        <p class="lead">O método HTTP usado não é permitido para este recurso.</p>
                        <a href="/" class="btn btn-primary">Voltar ao Início</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
EOF

    # Página 500 - Internal Server Error
    cat > "$ERROR_DIR/500.html" << 'EOF'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>500 - Erro Interno do Servidor</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container">
        <div class="row justify-content-center align-items-center min-vh-100">
            <div class="col-md-6 text-center">
                <div class="card shadow">
                    <div class="card-body p-5">
                        <h1 class="display-1 text-danger">500</h1>
                        <h2 class="mb-3">Erro Interno do Servidor</h2>
                        <p class="lead">Ocorreu um erro interno no servidor. Tente novamente mais tarde.</p>
                        <a href="/" class="btn btn-primary">Voltar ao Início</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
EOF

    chown -R "$TARGET_USER:www-data" "$ERROR_DIR"
    msg "ok" "Páginas de erro criadas (403, 404, 405, 500)"
}

# Gerar certificado SSL auto-assinado
generate_ssl_certificate() {
    msg "info" "Gerando certificado SSL auto-assinado..."
    
    # Detectar IP do servidor (versão silenciosa)
    local server_ip=$(get_server_ip_silent)
    msg "info" "Gerando certificado para IP: $server_ip"
    
    # Gerar chave privada
    openssl genrsa -out "$SSL_DIR/nginx.key" 2048
    
    # Gerar certificado com IP ou localhost
    openssl req -new -x509 -key "$SSL_DIR/nginx.key" -out "$SSL_DIR/nginx.crt" -days 365 -subj "/C=BR/ST=SP/L=SaoPaulo/O=BananaPi/OU=Server/CN=$server_ip"
    
    # Definir permissões com grupo www-data
    chmod 600 "$SSL_DIR/nginx.key"
    chmod 644 "$SSL_DIR/nginx.crt"
    chown "$TARGET_USER:www-data" "$SSL_DIR"/*
    
    msg "ok" "Certificado SSL gerado"
}

# Configurar Nginx
configure_nginx() {
    msg "info" "Configurando Nginx..."
    
    # Detectar IP do servidor (versão silenciosa para evitar códigos de cor no arquivo)
    local server_ip=$(get_server_ip_silent)
    msg "info" "Configurando para IP: $server_ip"
    
    # Backup da configuração original
    cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup
    
    # Criar nova configuração
    cat > /etc/nginx/sites-available/default << EOF
server {
    listen 80;
    listen [::]:80;
    server_name $server_ip;
    
    # Redirect HTTP to HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $server_ip;
    
    # SSL Configuration
    ssl_certificate $SSL_DIR/nginx.crt;
    ssl_certificate_key $SSL_DIR/nginx.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    
    # Document Root
    root $PUBLIC_HTML;
    index index.html index.htm index.nginx-debian.html;
    
    # Logs
    access_log $LOGS_DIR/access.log;
    error_log $LOGS_DIR/error.log;
    
    # Main location
    location / {
        try_files \$uri \$uri/ =404;
    }
    
    # Error pages
    error_page 403 /error/403.html;
    error_page 404 /error/404.html;
    error_page 405 /error/405.html;
    error_page 500 502 503 504 /error/500.html;
    
    location ^~ /error/ {
        internal;
        root $USER_HOME;
    }
    
    # Security headers
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
    
    # Testar configuração
    if nginx -t; then
        msg "ok" "Configuração do Nginx válida"
        systemctl reload nginx
        msg "ok" "Nginx recarregado"
    else
        msg "err" "Erro na configuração do Nginx"
        return 1
    fi
}

# Instalação completa
full_install() {
    msg "title" "=== INSTALAÇÃO COMPLETA DO NGINX ==="
    
    check_user
    install_nginx || return 1
    create_directories
    create_index_page
    create_error_pages
    generate_ssl_certificate
    configure_nginx
    
    # Detectar IP para mostrar URLs corretas
    local server_ip=$(get_server_ip)
    
    msg "ok" "Instalação completa finalizada!"
    msg "info" "Acesse: http://$server_ip (redireciona para HTTPS)"
    msg "info" "HTTPS: https://$server_ip"
    msg "cyan" "Logs em: $LOGS_DIR"
    msg "cyan" "SSL em: $SSL_DIR"
    msg "cyan" "Páginas em: $PUBLIC_HTML"
}

# FUNÇÕES DE DESINSTALAÇÃO
#==============================================================================

# Desinstalar Nginx
uninstall_nginx() {
    msg "title" "=== DESINSTALANDO NGINX ==="
    
    msg "warn" "ATENÇÃO: Esta operação irá:"
    echo "  • Parar e desinstalar o Nginx"
    echo "  • Remover todas as configurações"
    echo "  • Apagar pastas do usuário '$TARGET_USER' (mesmo que não vazias)"
    echo
    read -p "Tem certeza? Digite 'DESINSTALAR' para confirmar: " confirm
    
    if [[ "$confirm" != "DESINSTALAR" ]]; then
        msg "info" "Operação cancelada"
        return 0
    fi
    
    msg "info" "Parando Nginx..."
    systemctl stop nginx 2>/dev/null
    systemctl disable nginx 2>/dev/null
    
    msg "info" "Removendo Nginx..."
    apt remove --purge -y nginx nginx-common nginx-core
    apt autoremove -y
    
    msg "info" "Removendo configurações..."
    rm -rf /etc/nginx
    rm -rf /var/log/nginx
    rm -rf /var/www/html
    
    msg "info" "Removendo pastas do usuário '$TARGET_USER'..."
    rm -rf "$PUBLIC_HTML" "$LOGS_DIR" "$SSL_DIR" "$ERROR_DIR"
    
    msg "ok" "Nginx completamente desinstalado"
    msg "info" "Usuário '$TARGET_USER' mantido (apenas pastas removidas)"
}

# INTERFACE DO MENU
#==============================================================================

show_menu() {
    clear
    msg "title" "=================================================="
    msg "title" "    NGINX MANAGER - BANANA PI M5 / UBUNTU 24.04"
    msg "title" "=================================================="
    echo
    msg "cyan" "Usuário alvo: $TARGET_USER"
    msg "cyan" "Diretório: $USER_HOME"
    echo
    echo "1) Instalar e Configurar Nginx Completo"
    echo "2) Desinstalar Nginx (remove tudo)"
    echo "3) Status do Nginx"
    echo "4) Reiniciar Nginx"
    echo "5) Ver Logs (Access)"
    echo "6) Ver Logs (Error)"
    echo "7) Testar Configuração"
    echo "0) Sair"
    echo
}

# Status do Nginx
show_status() {
    msg "title" "=== STATUS DO NGINX ==="
    
    if systemctl is-active --quiet nginx; then
        msg "ok" "Nginx está ATIVO"
        echo
        systemctl status nginx --no-pager -l
    else
        msg "err" "Nginx está INATIVO"
    fi
    
    echo
    read -p "Pressione Enter para continuar..."
}

# Reiniciar Nginx
restart_nginx() {
    msg "info" "Reiniciando Nginx..."
    
    if systemctl restart nginx; then
        msg "ok" "Nginx reiniciado com sucesso"
    else
        msg "err" "Falha ao reiniciar Nginx"
    fi
    
    echo
    read -p "Pressione Enter para continuar..."
}

# Ver logs de acesso
view_access_logs() {
    msg "title" "=== LOGS DE ACESSO ==="
    
    if [[ -f "$LOGS_DIR/access.log" ]]; then
        tail -20 "$LOGS_DIR/access.log"
    else
        msg "warn" "Arquivo de log não encontrado: $LOGS_DIR/access.log"
    fi
    
    echo
    read -p "Pressione Enter para continuar..."
}

# Ver logs de erro
view_error_logs() {
    msg "title" "=== LOGS DE ERRO ==="
    
    if [[ -f "$LOGS_DIR/error.log" ]]; then
        tail -20 "$LOGS_DIR/error.log"
    else
        msg "warn" "Arquivo de log não encontrado: $LOGS_DIR/error.log"
    fi
    
    echo
    read -p "Pressione Enter para continuar..."
}

# Testar configuração
test_config() {
    msg "title" "=== TESTE DE CONFIGURAÇÃO ==="
    
    if nginx -t; then
        msg "ok" "Configuração válida"
    else
        msg "err" "Erro na configuração"
    fi
    
    echo
    read -p "Pressione Enter para continuar..."
}

# Processar escolha do menu
process_choice() {
    case "$1" in
        1) full_install ;;
        2) uninstall_nginx ;;
        3) show_status ;;
        4) restart_nginx ;;
        5) view_access_logs ;;
        6) view_error_logs ;;
        7) test_config ;;
        0) msg "info" "Saindo..."; exit 0 ;;
        *) msg "err" "Opção inválida" ;;
    esac
    
    if [[ "$1" != "3" && "$1" != "4" && "$1" != "5" && "$1" != "6" && "$1" != "7" ]]; then
        echo
        read -p "Pressione Enter para continuar..."
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