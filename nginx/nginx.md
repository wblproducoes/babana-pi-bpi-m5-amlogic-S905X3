# Nginx Manager - Banana Pi M5 / Ubuntu 24.04

## Descrição

Script completo para instalação, configuração e gerenciamento do servidor web Nginx no **Banana Pi M5** com arquitetura **aarch64** rodando **Ubuntu 24.04 (Noble)**.

## Características

### 🎯 **Funcionalidades Principais**
- ✅ Instalação automática do Nginx
- ✅ Configuração personalizada para usuário `server`
- ✅ **Detecção automática de IP do servidor com função silenciosa**
- ✅ Geração de certificado SSL auto-assinado com IP dinâmico
- ✅ **Correção de códigos ANSI na configuração do Nginx**
- ✅ **Script de correção de permissões (`fix_nginx_permissions.sh`)**
- ✅ Páginas de erro customizadas com Bootstrap 5.3
- ✅ Estrutura organizada de diretórios
- ✅ Menu interativo para gerenciamento
- ✅ Integração com grupo `www-data` para permissões
- ✅ Desinstalação completa (remove pastas não vazias)

### 🏗️ **Estrutura de Diretórios**
```
/home/server/
├── public_html/     # Documentos web (root do site)
├── logs/           # Logs de acesso e erro
├── ssl/            # Certificados SSL
└── error/          # Páginas de erro personalizadas
```

### 🔒 **Segurança**
- Certificado SSL auto-assinado
- Redirecionamento HTTP → HTTPS
- Headers de segurança configurados
- Permissões adequadas nos diretórios

### 🎨 **Interface Moderna**
- Página inicial responsiva com Bootstrap 5.3
- Páginas de erro (403, 404, 405, 500) estilizadas
- Design moderno e profissional

## Compatibilidade

| Componente | Versão/Especificação |
|------------|---------------------|
| **Hardware** | Banana Pi M5 |
| **Arquitetura** | aarch64 (ARM64) |
| **Sistema** | Ubuntu 24.04 LTS (Noble) |
| **Servidor Web** | Nginx (latest) |
| **SSL/TLS** | OpenSSL |
| **Framework CSS** | Bootstrap 5.3 |

## Instalação e Uso

### 📋 **Pré-requisitos**
- Ubuntu 24.04 instalado no Banana Pi M5
- Acesso root (sudo)
- Conexão com internet

### 🚀 **Execução Rápida**
```bash
# Baixar, editar e executar o script
rm -rf nginx.sh; nano nginx.sh; chmod +x nginx.sh; bash nginx.sh
```

### 🔧 **Correção de Permissões (se necessário)**
```bash
# Se encontrar erro "Permission denied" nos logs:
# 1. Copie o script fix_nginx_permissions.sh para o servidor
sudo nano /tmp/fix_nginx_permissions.sh
# (Cole o conteúdo do arquivo fix_nginx_permissions.sh)

# 2. Execute o script de correção
sudo chmod +x /tmp/fix_nginx_permissions.sh
sudo /tmp/fix_nginx_permissions.sh

# 3. Verifique se o problema foi resolvido
sudo systemctl status nginx
sudo tail -f /home/server/logs/error.log
```

### 📖 **Menu Interativo**
```
==================================================
    NGINX MANAGER - BANANA PI M5 / UBUNTU 24.04
==================================================

Usuário alvo: server
Diretório: /home/server

1) Instalar e Configurar Nginx Completo
2) Desinstalar Nginx (remove tudo)
3) Status do Nginx
4) Reiniciar Nginx
5) Ver Logs (Access)
6) Ver Logs (Error)
7) Testar Configuração
0) Sair
```

## Funcionalidades Detalhadas

### 1️⃣ **Instalação Completa**
- Atualiza o sistema
- Instala Nginx e OpenSSL
- Cria usuário `server` (se não existir)
- Adiciona usuário `server` ao grupo `www-data`
- **Detecta automaticamente o IP do servidor**
- Configura estrutura de diretórios com permissões adequadas
- Gera certificado SSL com IP dinâmico
- Configura Nginx com `server_name` usando IP real
- Cria páginas personalizadas
- Exibe URLs corretas para acesso externo

### 2️⃣ **Desinstalação Segura**
- Para o serviço Nginx
- Remove pacotes completamente
- Apaga configurações do sistema
- Remove diretórios do usuário (mesmo não vazios)
- Confirmação obrigatória

### 3️⃣ **Monitoramento**
- Status em tempo real
- Visualização de logs
- Teste de configuração
- Reinicialização do serviço

## Configuração do Nginx

### 🔍 **Detecção Automática de IP**
O script utiliza duas funções para detecção de IP:

- **`get_server_ip_silent()`**: Versão silenciosa para uso em configurações (sem códigos ANSI)
- **`get_server_ip()`**: Versão com mensagens coloridas para interface do usuário

**Métodos de Detecção (em ordem de prioridade):**
1. `ip route get 8.8.8.8` - IP da interface principal
2. `hostname -I` - Fallback para hostname
3. `ip addr show` - Fallback para interfaces de rede
4. `localhost` - Fallback final se nenhum método funcionar

### 🌐 **Virtual Host**
```nginx
# HTTP (redireciona para HTTPS)
server {
    listen 80;
    listen [::]:80;
    server_name [IP_DETECTADO];
    return 301 https://$server_name$request_uri;
}

# HTTPS
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name [IP_DETECTADO];
    root /home/server/public_html;
    
    # SSL
    ssl_certificate /home/server/ssl/nginx.crt;
    ssl_certificate_key /home/server/ssl/nginx.key;
    
    # Logs
    access_log /home/server/logs/access.log;
    error_log /home/server/logs/error.log;
    
    # Páginas de erro
    error_page 403 /error/403.html;
    error_page 404 /error/404.html;
    error_page 405 /error/405.html;
    error_page 500 502 503 504 /error/500.html;
}
```

### 🔐 **SSL/TLS**
- Protocolo: TLSv1.2 e TLSv1.3
- Cifras modernas e seguras
- Certificado válido por 365 dias
- Chave RSA 2048 bits

### 📊 **Logs Personalizados**
- **Access Log**: `/home/server/logs/access.log`
- **Error Log**: `/home/server/logs/error.log`
- Rotação automática pelo sistema

## Páginas de Erro

Todas as páginas de erro utilizam **Bootstrap 5.3** para design moderno:

| Código | Descrição | Arquivo |
|--------|-----------|---------|
| **403** | Acesso Negado | `/home/server/error/403.html` |
| **404** | Página Não Encontrada | `/home/server/error/404.html` |
| **405** | Método Não Permitido | `/home/server/error/405.html` |
| **500** | Erro Interno do Servidor | `/home/server/error/500.html` |

## Estrutura do Script

### 🔧 **Funções Principais**
```bash
# Instalação
install_nginx()           # Instala Nginx
create_directories()      # Cria estrutura de pastas
create_index_page()       # Página inicial
create_error_pages()      # Páginas de erro
generate_ssl_certificate() # Certificado SSL
configure_nginx()         # Configuração do Nginx

# Gerenciamento
uninstall_nginx()         # Desinstalação completa
show_status()            # Status do serviço
restart_nginx()          # Reiniciar serviço
view_access_logs()       # Ver logs de acesso
view_error_logs()        # Ver logs de erro
test_config()            # Testar configuração
```

### 🎨 **Interface**
- Cores e símbolos para melhor visualização
- Mensagens informativas e de erro
- Confirmações para operações críticas
- Menu intuitivo e responsivo

## Segurança

### 🛡️ **Headers de Segurança**
```nginx
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Referrer-Policy: no-referrer-when-downgrade
Content-Security-Policy: default-src 'self' http: https: data: blob: 'unsafe-inline'
```

### 🔒 **Permissões e Grupos**
- **Usuário**: `server` (membro do grupo `www-data`)
- **Grupo**: `www-data` (grupo padrão do Nginx)
- `public_html/`: 755 + g+w (escrita para grupo www-data)
- `logs/`: 750 + g+w (escrita para grupo www-data)
- `ssl/`: 750 + g+r (leitura para grupo www-data)
- `error/`: 755 + g+r (leitura para grupo www-data)

**Estrutura de Propriedade:**
```bash
/home/server/public_html  → server:www-data (755 + g+w)
/home/server/logs         → server:www-data (750 + g+w)
/home/server/ssl          → server:www-data (750 + g+r)
/home/server/error        → server:www-data (755 + g+r)
```

## Otimizações

### ⚡ **Performance**
- Compressão Gzip habilitada
- HTTP/2 ativado
- Cache de arquivos estáticos
- Otimizado para ARM64

### 📱 **Responsividade**
- Design mobile-first
- Bootstrap 5.3 responsivo
- Viewport configurado
- Imagens otimizadas

## Troubleshooting

### ❌ **Problemas Comuns**

**1. Erro de permissão**
```bash
sudo chmod +x nginx.sh
sudo ./nginx.sh
```

**2. Porta 80/443 ocupada**
```bash
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :443
```

**3. Certificado SSL inválido**
```bash
# Regenerar certificado
sudo openssl genrsa -out /home/server/ssl/nginx.key 2048
sudo openssl req -new -x509 -key /home/server/ssl/nginx.key -out /home/server/ssl/nginx.crt -days 365
```

**4. Configuração inválida**
```bash
sudo nginx -t
sudo systemctl status nginx
```

**5. Problemas de permissão com www-data**
```bash
# Verificar se usuário está no grupo www-data
groups server

# Adicionar usuário ao grupo www-data (se necessário)
sudo usermod -a -G www-data server

# Corrigir permissões dos diretórios
sudo chown -R server:www-data /home/server/{public_html,logs,ssl,error}
sudo chmod 755 /home/server/public_html /home/server/error
sudo chmod 750 /home/server/logs /home/server/ssl
sudo chmod g+w /home/server/public_html /home/server/logs
sudo chmod g+r /home/server/ssl /home/server/error
```

**6. Erro "unknown directive 34mℹ" (CORRIGIDO na v1.3)**
```bash
# PROBLEMA: Códigos ANSI na configuração do Nginx
# SINTOMA: nginx: [emerg] unknown directive "34mℹ" in /etc/nginx/sites-enabled/default:5

# CAUSA: Função get_server_ip() inserindo códigos de cor no arquivo de configuração

# SOLUÇÃO IMPLEMENTADA:
# ✅ Criada função get_server_ip_silent() sem códigos ANSI
# ✅ configure_nginx() usa versão silenciosa
# ✅ generate_ssl_certificate() usa versão silenciosa
# ✅ Interface colorida mantida para o usuário

# VERIFICAÇÃO:
sudo nginx -t  # Deve passar sem erros
```

**7. Erro "Permission denied" nos diretórios (NOVO na v1.4)**
```bash
# PROBLEMA: Nginx não consegue acessar diretórios do usuário
# SINTOMA: stat() "/home/server/public_html/" failed (13: Permission denied)

# SOLUÇÃO AUTOMÁTICA: Script fix_nginx_permissions.sh
# 1. Copie o script para o servidor:
sudo nano /tmp/fix_nginx_permissions.sh
# (Cole o conteúdo do arquivo fix_nginx_permissions.sh)

# 2. Torne executável e execute:
sudo chmod +x /tmp/fix_nginx_permissions.sh
sudo /tmp/fix_nginx_permissions.sh

# O script automaticamente:
# ✅ Adiciona usuário 'server' ao grupo www-data
# ✅ Corrige propriedade dos diretórios (server:www-data)
# ✅ Define permissões corretas (755, 750, g+w, g+r)
# ✅ Cria index.html se não existir
# ✅ Testa configuração e reinicia Nginx
# ✅ Mostra status final das permissões

# VERIFICAÇÃO:
groups server  # Deve mostrar www-data
ls -la /home/server/  # Deve mostrar server:www-data
sudo systemctl status nginx  # Deve estar ativo
```

### 🔍 **Logs de Debug**
```bash
# Ver logs em tempo real
sudo tail -f /home/server/logs/error.log
sudo tail -f /home/server/logs/access.log

# Logs do sistema
sudo journalctl -u nginx -f
```

## URLs de Acesso

Após a instalação, o servidor estará disponível em:

- **HTTP**: http://[IP_DETECTADO] (redireciona para HTTPS)
- **HTTPS**: https://[IP_DETECTADO]
- **Detecção Automática**: O script detecta automaticamente o IP do servidor
- **Fallback**: Se não conseguir detectar, usa `localhost`

> 💡 **Nota**: O script agora detecta automaticamente o IP do servidor e configura as URLs adequadamente. Não é mais necessário usar `localhost` fixo.

## Arquivos Importantes

| Arquivo | Localização | Descrição |
|---------|-------------|-----------|
| **Configuração Principal** | `/etc/nginx/sites-available/default` | Config do Nginx |
| **Página Inicial** | `/home/server/public_html/index.html` | Homepage |
| **Certificado SSL** | `/home/server/ssl/nginx.crt` | Certificado público |
| **Chave Privada** | `/home/server/ssl/nginx.key` | Chave privada SSL |
| **Log de Acesso** | `/home/server/logs/access.log` | Logs de acesso |
| **Log de Erro** | `/home/server/logs/error.log` | Logs de erro |

## Backup e Restauração

### 💾 **Backup**
```bash
# Backup completo
sudo tar -czf nginx_backup_$(date +%Y%m%d).tar.gz \
  /home/server \
  /etc/nginx/sites-available/default

# Backup apenas configurações
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup
```

### 🔄 **Restauração**
```bash
# Restaurar configuração
sudo cp /etc/nginx/sites-available/default.backup /etc/nginx/sites-available/default
sudo nginx -t && sudo systemctl reload nginx
```

## Atualizações

### 🔄 **Atualizar Nginx**
```bash
sudo apt update
sudo apt upgrade nginx
sudo systemctl restart nginx
```

### 📝 **Atualizar Páginas**
- Edite os arquivos em `/home/server/public_html/`
- Não é necessário reiniciar o Nginx

## Suporte

### 📞 **Informações do Sistema**
- **Hardware**: Banana Pi M5
- **Arquitetura**: aarch64 (ARM64)
- **OS**: Ubuntu 24.04 LTS (Noble)
- **Servidor**: Nginx (latest)

### 🐛 **Reportar Problemas**
Para reportar problemas ou sugestões:
1. Verifique os logs de erro
2. Execute teste de configuração
3. Documente o erro encontrado

---

## Histórico de Atualizações

### 📝 **Versão 1.4** - Script de Correção de Permissões
**Problema Identificado:**
- ❌ Erro `stat() "/home/server/public_html/" failed (13: Permission denied)` nos logs do Nginx
- ❌ Nginx não consegue acessar diretórios `/home/server/public_html/` e `/home/server/error/`
- ❌ Páginas não carregam devido a permissões incorretas

**Solução Implementada:**
- ✅ Criado script `fix_nginx_permissions.sh` para correção automática de permissões
- ✅ Script verifica usuário `server` e grupo `www-data`
- ✅ Adiciona usuário ao grupo www-data automaticamente
- ✅ Corrige propriedade dos diretórios (`server:www-data`)
- ✅ Define permissões corretas (755, 750, g+w, g+r)
- ✅ Cria `index.html` se não existir
- ✅ Testa configuração e reinicia Nginx
- ✅ Mostra status final das permissões

**Arquivos Criados:**
- `fix_nginx_permissions.sh`: Script de correção automática de permissões

**Arquivos Modificados:**
- `nginx.md`: Documentação atualizada com novo troubleshooting

**Benefícios:**
- 🔧 Correção automática de problemas de permissão
- ✅ Nginx funciona corretamente após execução do script
- 🛡️ Verificações de segurança antes de aplicar correções
- 📊 Relatório detalhado do status final

---

### 📝 **Versão 1.3** - Correção de Códigos ANSI na Configuração
**Prompt de Atualização:**
```
Note: the user reported an Nginx configuration error during installation, specifically "unknown directive "34mℹ" in /etc/nginx/sites-enabled/default:5", leading to a failed Nginx configuration test.
```

**Problema Identificado:**
- ❌ Códigos de cores ANSI (como `34mℹ`) sendo inseridos na configuração do Nginx
- ❌ Erro `unknown directive "34mℹ"` causando falha no teste de configuração
- ❌ Função `get_server_ip()` com `msg "info"` inserindo códigos coloridos no arquivo de configuração

**Mudanças Implementadas:**
- ✅ Criada função `get_server_ip_silent()` para detecção de IP sem códigos ANSI
- ✅ Refatorada função `get_server_ip()` para usar versão silenciosa + mensagens separadas
- ✅ Atualizada função `configure_nginx()` para usar `get_server_ip_silent()`
- ✅ Atualizada função `generate_ssl_certificate()` para usar versão silenciosa
- ✅ Mantidas mensagens coloridas para interface do usuário

**Arquivos Modificados:**
- `nginx.sh`: Funções `get_server_ip_silent()`, `get_server_ip()`, `configure_nginx()`, `generate_ssl_certificate()`
- `nginx.md`: Documentação atualizada com correção

**Benefícios:**
- 🔧 Configuração do Nginx livre de códigos ANSI
- ✅ Teste de configuração `nginx -t` passa sem erros
- 🎨 Interface colorida mantida para o usuário
- 🛡️ Instalação robusta e confiável

---

### 📝 **Versão 1.2** - Configuração com IP Dinâmico
**Prompt de Atualização:**
```
atualize a documetação
```

**Mudanças Implementadas:**
- ✅ Adicionada função `get_server_ip()` para detecção automática do IP do servidor
- ✅ Atualizada função `configure_nginx()` para usar IP dinâmico em vez de `localhost`
- ✅ Modificada função `generate_ssl_certificate()` para gerar certificados com IP real
- ✅ Atualizada função `full_install()` para exibir URLs corretas com IP detectado
- ✅ Implementados múltiplos métodos de detecção de IP (ip route, hostname -I, ip addr)
- ✅ Configuração automática do `server_name` no Nginx para acesso externo
- ✅ Fallback para `localhost` se detecção de IP falhar

**Arquivos Modificados:**
- `nginx.sh`: Funções `get_server_ip()`, `configure_nginx()`, `generate_ssl_certificate()`, `full_install()`
- `nginx.md`: Atualização da documentação com novas funcionalidades

**Benefícios:**
- 🌐 Acesso externo ao servidor (não apenas localhost)
- 🔄 Detecção automática de IP em diferentes ambientes
- 🔒 Certificados SSL compatíveis com IP real
- 📱 URLs corretas exibidas na instalação

---

### 📝 **Versão 1.1** - Integração com www-data
**Prompt de Atualização:**
```
coloque o usuário dentro do grupo www-data e de permissão correspondente para as pastas public_html, logs, error e ssl. Não esqueça de atualizar a documentação.
```

**Mudanças Implementadas:**
- ✅ Adicionado comando `usermod -a -G www-data server` na função `create_directories()`
- ✅ Alterada propriedade de todos os diretórios para `server:www-data`
- ✅ Configuradas permissões específicas para grupo www-data:
  - `public_html/`: 755 + g+w (grupo pode escrever)
  - `logs/`: 750 + g+w (grupo pode escrever logs)
  - `ssl/`: 750 + g+r (grupo pode ler certificados)
  - `error/`: 755 + g+r (grupo pode ler páginas de erro)
- ✅ Atualizada documentação com seção "Permissões e Grupos"
- ✅ Adicionada seção de troubleshooting para problemas com www-data

**Arquivos Modificados:**
- `nginx.sh`: Funções `create_directories()`, `generate_ssl_certificate()`, `create_index_page()`, `create_error_pages()`
- `nginx.md`: Seções de permissões, instalação e troubleshooting

---

### 📝 **Versão 1.0** - Versão Inicial
**Prompt Original:**

```
na pasta nginx crie um script em bash (com menu onde a opção 0 é de sair e/ou voltar) com o mesmo para funcionar no banana pi m5 com arquitetura de aarch64 e no ubuntu 24.04 (noble) que instale e desistale ( e apague a pasta mesmo que ela não esteja  vazia). Configurando o arquivo padrão para a pasta public_html do usuário server, arquivos de logs para a pasta logs dentro da pasta od usuário, ssl para a pasta ssl dentro da pasta do usuário, error para a pasta error dentro da pasta do usuário (criando os arquivos 403, 404, 405 e 500 .html com o bootstrap 5.3 para ser moderno). Substitundo o arquivo padrão do nginx para apontar a pasta root para public_html dentro da pasta do usuário, personalize os arquivo de logs e access para dentro da pasta logs do usuário, coloque também as pagina de 403, 404, 405 e 500 apontando para a pasta error dentro da pasta do usuário. Crie também um certificado auto assinado colocando o mesmo dentro da pasta ssl dentro da pasta dop usuário, configurando o arquivo do nginx. Crie também um arquivo .md com o mesmo nome com a explicação e com esse prompt original. E no fina do arquivo crie "rm -rf arquivo.sh;nano arquivo.sh;chmod +x arquivo.sh;bash arquivo.sh" trocando arquivo pelo o nome de arquivo;
```

---

## Comando de Execução

```bash
rm -rf nginx.sh;nano nginx.sh;chmod +x nginx.sh;bash nginx.sh
```

---

**Desenvolvido para Banana Pi M5 - Ubuntu 24.04 (aarch64)**  
*Script de gerenciamento completo do Nginx com SSL e interface moderna*