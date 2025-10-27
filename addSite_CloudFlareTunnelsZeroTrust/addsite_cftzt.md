# Gerenciador de Virtual Hosts (VHost) - LEMP Stack Otimizado para Cloudflare Tunnel

## Nome do Script
`addsite_cftzt.sh`

## Versão
2.0 (Configuração Nginx Otimizada para Cloudflare Tunnel)

## Compatibilidade
* **Hardware:** Banana Pi M5 (aarch64/ARM64)
* **Sistema Operacional:** Ubuntu 24.04 LTS (Noble Numbat)

## Descrição
Este script automatiza a criação e remoção de um ambiente de Virtual Host (LEMP Stack) para um novo usuário/domínio, com foco na segurança e na otimização para ambientes com proxy reverso ou Cloudflare Zero Trust Tunnel (escuta apenas na porta 80).

---

## Explicação Detalhada do Código (Linha por Linha e Função por Função)

### Configurações Globais (Linhas 6-39)

| Linhas | Código | Explicação |
| :---: | :--- | :--- |
| 6-13 | `#!=...=!` | Cabeçalho padrão do script: Nome, Versão, Descrição e Compatibilidade. |
| 15-18 | `SCRIPT_NAME=...` | Variáveis para identificação do script. |
| 19-22 | `NGINX_...=...` | Define os caminhos essenciais do sistema para o Nginx e o arquivo `/etc/hosts`. |
| 23-39 | `RED=...`, `OK=...` | Definição de códigos ANSI para cores e símbolos (✓, ✗, !) usados nas mensagens de saída (`msg`). |

### FUNÇÕES BÁSICAS

#### 1. `msg()` (Linhas 43-55)

| Linhas | Código | Explicação |
| :---: | :--- | :--- |
| 43-55 | `msg() { ... }` | Função central para exibir mensagens coloridas. Recebe dois argumentos: o tipo de mensagem (`ok`, `err`, `warn`, `info`, `title`, `cyan`) e a string da mensagem. Usa `case` para aplicar a cor e o símbolo correspondente antes de imprimir a mensagem (`echo -e`). |

#### 2. `check_root()` (Linhas 58-64)

| Linhas | Código | Explicação |
| :---: | :--- | :--- |
| 58-64 | `check_root() { ... }` | Verifica a UID (User ID) do usuário atual. Se a UID não for `0` (que é o ID do `root`), exibe uma mensagem de erro e sai do script com código `1`. |

#### 3. `validate_user_name()` (Linhas 70-76)

| Linhas | Código | Explicação |
| :---: | :--- | :--- |
| 70-76 | `validate_user_name() { ... }` | Função de validação de segurança. Usa regex (`=~`) para garantir que o nome de usuário (argumento `$1`) contenha apenas letras minúsculas (`a-z`) e números (`0-9`). |

#### 4. `validate_domain()` (Linhas 79-85)

| Linhas | Código | Explicação |
| :---: | :--- | :--- |
| 79-85 | `validate_domain() { ... }` | Valida se o domínio (argumento `$1`) possui uma estrutura DNS básica (letras, números, hífen, ponto e extensão de pelo menos 2 caracteres). |

#### 5. `get_server_ip_silent()` (Linhas 88-103)

| Linhas | Código | Explicação |
| :---: | :--- | :--- |
| 88-103 | `get_server_ip_silent() { ... }` | Tenta detectar o IP principal do servidor usando métodos robustos (`ip route get`, `hostname -I`). É usado para injetar o IP no `/etc/hosts` e nas mensagens informativas. Retorna `127.0.0.1` como fallback. |

### FUNÇÕES DE CRIAÇÃO (ADD VHOST)

#### 6. `create_user_and_set_password()` (Linhas 109-139)

| Linhas | Código | Explicação |
| :---: | :--- | :--- |
| 109-115 | `if id ... useradd -m ...` | Verifica se o usuário já existe. Se não existir, usa `useradd -m` (cria o diretório home) e define o shell como `/bin/bash`. |
| 118-131 | `while true; do ... chpasswd` | Loop interativo para solicitar e confirmar a senha. Usa `read -s` para ler a senha de forma silenciosa e `chpasswd` para defini-la. |
| 135-138 | `usermod -a -G www-data...` | Adiciona o novo usuário ao grupo `www-data`. Isso é crucial para permitir que o PHP-FPM e o Nginx acessem os arquivos do site. |

#### 7. `create_vhost_directories()` (Linhas 142-161)

| Linhas | Código | Explicação |
| :---: | :--- | :--- |
| 147-150 | `mkdir -p ...` | Cria a estrutura de diretórios padrão: `public_html` (root do site), `logs`, `error` e `ssl`. |
| 153-156 | `chown -R ... chmod ...` | Define a propriedade recursivamente para `USUARIO:www-data` e permissões básicas (755/750). |
| 158-159 | `chmod g+w ... g+r ...` | Permissões específicas: `www-data` precisa de permissão de escrita (`g+w`) nos logs e `public_html` e de leitura (`g+r`) nas pastas `ssl` (para Nginx) e `error`. |

#### 8. `generate_vhost_ssl()` (Linhas 164-183)

| Linhas | Código | Explicação |
| :---: | :--- | :--- |
| 169-173 | `openssl genrsa... openssl req...` | Cria a chave privada (`.key`) e o certificado auto-assinado (`.crt`) para o domínio. O certificado é gerado, mas o Nginx não o usará na configuração final para Cloudflare. |
| 176-180 | `chmod 600... chown...` | Define permissões estritas para o arquivo de chave privada (somente leitura pelo dono) para segurança. |

#### 9. `create_vhost_content()` (Linhas 186-258)

| Linhas | Código | Explicação |
| :---: | :--- | :--- |
| 191-236 | `cat > index.php ...` | Cria o arquivo `index.php` com um template moderno que utiliza Bootstrap 5.3 para um visual limpo e responsivo. |
| 238 | `echo '<?php phpinfo(); ?>' ...` | Cria o arquivo `info.php`, essencial para testar se o PHP-FPM está funcionando após a configuração. |
| 240-255 | `local error_template ...` | Cria um template HTML para as páginas de erro (`403.html`, `404.html`, etc.) e usa `sed` para substituir placeholders (`%CODE%`, `%TITLE%`) e gerar as páginas finais, garantindo a estética com Bootstrap. |

#### 10. `create_phpmyadmin_symlink()` (Linhas 261-279)

| Linhas | Código | Explicação |
| :---: | :--- | :--- |
| 266-267 | `if [[ ! -d ...` | Verifica se o diretório do phpMyAdmin (pré-requisito) existe. |
| 271 | `ln -s "$PHPMYADMIN_DIR" ...` | Cria o link simbólico (`ln -s`) para que o phpMyAdmin seja acessível via `http://dominio/phpmyadmin`. |
| 274 | `chown ...` | Define as permissões do link para o usuário/grupo `www-data`. |

#### 11. `create_nginx_vhost_conf()` (Linhas 282-357)

| Linhas | Código | Explicação |
| :---: | :--- | :--- |
| 289-293 | `local fpm_sock ...` | Define o nome do socket FPM esperado (`php-fpm-USUARIO.sock`). Se o socket não for encontrado, usa o fallback padrão (`php8.4-fpm.sock`) e emite um aviso. |
| 296-302 | `cat > conf_file << EOF` | **INÍCIO DA CONFIGURAÇÃO OTIMIZADA.** Cria um **único** bloco `server`. |
| 303-306 | `listen 80 ... server_name` | Define o Nginx para escutar apenas nas portas 80 (HTTP). **O bloco 443 (HTTPS) é omitido.** |
| 308-310 | `root ... index ...` | Define a raiz do documento e a ordem de arquivos de índice. |
| 312-326 | `access_log ... error_page` | Configura os logs e as páginas de erro para os diretórios do usuário. |
| 329-335 | `location ~ \.php$ ...` | Bloco FastCGI: Passa todas as requisições `.php` para o socket FPM do usuário. |
| 338-349 | `add_header ... gzip ...` | Adiciona cabeçalhos de segurança (HSTS não incluso, pois é gerenciado pelo Cloudflare) e ativa a compressão Gzip. |
| 352 | `ln -s ...` | Cria o link simbólico no `sites-enabled` para ativar a configuração. |
| 355 | `nginx -t; systemctl reload nginx` | Testa a sintaxe do Nginx e recarrega o serviço. |

#### 12. `add_domain_to_hosts()` (Linhas 360-372)

| Linhas | Código | Explicação |
| :---: | :--- | :--- |
| 364-370 | `if grep -q ... echo ...` | Adiciona uma entrada no arquivo `/etc/hosts` do servidor, mapeando o domínio para o IP local. Isso permite que o servidor resolva o próprio domínio, o que é útil para tarefas internas. |

#### 13. `add_vhost()` (Linhas 375-408)

| Linhas | Código | Explicação |
| :---: | :--- | :--- |
| 375-392 | `add_vhost() { ... }` | Função orquestradora que chama todas as subfunções em ordem lógica (criação de usuário, pastas, conteúdo, Nginx, hosts). |

### FUNÇÕES DE REMOÇÃO (DELETE VHOST)

#### 14. `remove_vhost()` (Linhas 411-458)

| Linhas | Código | Explicação |
| :---: | :--- | :--- |
| 420-428 | `read -p ... if [[ "$confirm_user" != ...` | Solicita uma confirmação de segurança digitando o nome do usuário, pois a remoção é destrutiva. |
| 431-438 | `rm -f ... sed -i ... systemctl reload` | Remove o link Nginx em `sites-enabled` e o arquivo de configuração, remove a entrada do `/etc/hosts` e recarrega o Nginx. |
| 441-453 | `userdel -r ... rm -rf ...` | Usa `userdel -r` para remover o usuário e **seu diretório home e todo o seu conteúdo**, garantindo que nenhum dado do VHost permaneça. |

### INTERFACE DO MENU (Linhas 461-558)

As funções `show_menu()`, `manage_vhost_menu()`, `process_choice()` e `main()` lidam com a interface de linha de comando, mostrando as opções e processando as escolhas do usuário, garantindo que o script seja executado como root. O `manage_vhost_menu()` é a função de gerenciamento interativo que permite visualizar e editar o arquivo Nginx do domínio.

---

## Comandos Úteis para o `addsite_cftzt.sh`

```bash
rm -rf addsite_cftzt.sh;nano addsite_cftzt.sh;chmod +x addsite_cftzt.sh;sudo bash addsite_cftzt.sh