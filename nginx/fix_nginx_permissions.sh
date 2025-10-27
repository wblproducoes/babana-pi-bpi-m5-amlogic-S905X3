#!/bin/bash

# Script para corrigir permissões do Nginx
# Execute este script no servidor remoto como root

echo "🔧 Corrigindo permissões do Nginx..."

# Verificar se usuário server existe
if ! id "server" &>/dev/null; then
    echo "❌ Usuário 'server' não encontrado!"
    exit 1
fi

# Verificar se grupo www-data existe
if ! getent group www-data &>/dev/null; then
    echo "❌ Grupo 'www-data' não encontrado!"
    exit 1
fi

# Adicionar usuário server ao grupo www-data
echo "👤 Adicionando usuário 'server' ao grupo www-data..."
usermod -a -G www-data server

# Verificar se diretórios existem
if [ ! -d "/home/server" ]; then
    echo "❌ Diretório /home/server não encontrado!"
    exit 1
fi

# Criar diretórios se não existirem
echo "📁 Criando/verificando diretórios..."
mkdir -p /home/server/{public_html,logs,ssl,error}

# Corrigir propriedade dos diretórios
echo "🔐 Corrigindo propriedade dos diretórios..."
chown -R server:www-data /home/server/{public_html,logs,ssl,error}

# Definir permissões corretas
echo "🔑 Definindo permissões corretas..."
chmod 755 /home/server/public_html /home/server/error
chmod 750 /home/server/logs /home/server/ssl
chmod g+w /home/server/public_html /home/server/logs
chmod g+r /home/server/ssl /home/server/error

# Corrigir permissões do diretório home do usuário
echo "🏠 Corrigindo permissões do diretório home..."
chmod 755 /home/server

# Verificar se index.html existe, se não, criar
if [ ! -f "/home/server/public_html/index.html" ]; then
    echo "📄 Criando página index.html..."
    cat > /home/server/public_html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Servidor Nginx</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; margin-top: 50px; }
        .container { max-width: 600px; margin: 0 auto; }
        h1 { color: #2c3e50; }
        p { color: #7f8c8d; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Servidor Nginx Funcionando!</h1>
        <p>Seu servidor Nginx está configurado e funcionando corretamente.</p>
        <p>Data: $(date)</p>
    </div>
</body>
</html>
EOF
    chown server:www-data /home/server/public_html/index.html
    chmod 644 /home/server/public_html/index.html
fi

# Verificar configuração do Nginx
echo "🔍 Verificando configuração do Nginx..."
if nginx -t; then
    echo "✅ Configuração do Nginx está correta!"
    
    # Reiniciar Nginx
    echo "🔄 Reiniciando Nginx..."
    systemctl restart nginx
    
    if systemctl is-active --quiet nginx; then
        echo "✅ Nginx reiniciado com sucesso!"
    else
        echo "❌ Erro ao reiniciar Nginx!"
        systemctl status nginx
        exit 1
    fi
else
    echo "❌ Erro na configuração do Nginx!"
    nginx -t
    exit 1
fi

# Mostrar status final
echo ""
echo "📊 Status final das permissões:"
echo "================================"
ls -la /home/server/
echo ""
echo "📁 Conteúdo dos diretórios:"
echo "================================"
ls -la /home/server/public_html/
echo ""
echo "👥 Grupos do usuário server:"
echo "================================"
groups server
echo ""
echo "🎉 Correção de permissões concluída!"
echo "🌐 Teste o acesso ao servidor: https://$(hostname -I | awk '{print $1}')"