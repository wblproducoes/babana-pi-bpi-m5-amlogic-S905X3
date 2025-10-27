# Documentação Global dos Scripts / Global Scripts Documentation

## 🇧🇷 Português (Brasil)

### Visão Geral
Esta coleção contém scripts em Bash desenvolvidos especificamente para **Banana Pi M5** com arquitetura **aarch64** e **Ubuntu 24.04 (Noble)**. Cada script oferece um menu interativo para gerenciar diferentes aspectos do servidor.

### Scripts Disponíveis

#### 📁 **baremetal** - `baremetal.sh` (v2.0)
**Função:** Sistema de backup e restauração bare-metal para Linux
- Criação de backups completos do sistema
- Restauração de sistemas bare-metal
- Listagem e exclusão de backups
- Interface simples e compacta

#### 📁 **addSite_CloudFlareTunnelsZeroTrust** - `addsite_cftzt.sh` (v2.0)
**Função:** Gerenciador de Virtual Hosts (VHost) otimizado para Cloudflare Tunnel
- Criação automática de usuários e estrutura de diretórios
- Configuração de Virtual Hosts Nginx otimizada para proxy reverso
- Geração de certificados SSL autoassinados
- Integração com PHP-FPM por usuário
- Link simbólico automático para phpMyAdmin
- Remoção completa de VHosts com confirmação de segurança

#### 📁 **basic** - `basic.sh` (v1.0)
**Função:** Instalação de ferramentas básicas do sistema
- Instala/desinstala: curl, unzip, unrar, git, ufw, wget
- Configuração do firewall UFW
- Interface bilíngue (português/inglês)
- Detecção automática do sistema

#### 📁 **disk** - `disk.sh` (v1.0)
**Função:** Gerenciamento completo de discos e partições
- Listagem de discos e partições
- Criação e exclusão de partições
- Formatação (NTFS, ext4, FAT32, exFAT)
- Montagem e desmontagem
- Configuração de montagem automática

#### 📁 **mariadb** - `mariadb.sh` (v1.0)
**Função:** Gerenciamento do servidor de banco de dados MariaDB
- Instalação do MariaDB Server e Client
- Configuração de segurança (mysql_secure_installation)
- Desinstalação completa com limpeza de dados
- Controle de serviços (status, reiniciar)

#### 📁 **nginx** - `nginx.sh` (v1.4)
**Função:** Servidor web Nginx com configuração SSL
- Instalação e configuração automática do Nginx
- Geração de certificados SSL autoassinados
- Detecção automática de IP
- Páginas de erro personalizadas
- Estrutura de diretórios para usuário 'server'
- Script de correção de permissões (`fix_nginx_permissions.sh`)

#### 📁 **php_nginx** - `php_nginx.sh` (v1.0)
**Função:** Ambiente PHP 8.4 com FastCGI para Nginx
- Instalação do PHP 8.4 e módulos essenciais
- Configuração do PHP-FPM
- Integração com Nginx
- Instalação do Composer
- Arquivo de teste PHP

#### 📁 **phpmyadmin** - `phpmyadmin.sh` (v1.0)
**Função:** Interface web para gerenciamento de banco de dados
- Instalação do phpMyAdmin
- Configuração de link simbólico para Nginx
- Integração com MariaDB
- Acesso via `/phpmyadmin`

#### 📁 **proftpd** - `proftpd.sh` (v1.1)
**Função:** Servidor FTP seguro
- Instalação e configuração do ProFTPD
- Configuração de chroot para segurança
- Restrição de usuários às suas pastas home
- Controle de serviços

#### 📁 **tailscale** - `tailscale.sh` (v1.0)
**Função:** VPN mesh para acesso remoto seguro
- Instalação do Tailscale
- Gerenciamento de conexões
- Verificação de status e IPs
- Desinstalação completa

#### 📁 **update** - `update.sh` (v1.1)
**Função:** Atualização e manutenção do sistema
- Update, upgrade, dist-upgrade
- Correção de dependências
- Limpeza de pacotes (autoremove, autoclean)
- Opções de reinicialização e desligamento

---

## 🇺🇸 English (United States)

### Overview
This collection contains Bash scripts specifically developed for **Banana Pi M5** with **aarch64** architecture and **Ubuntu 24.04 (Noble)**. Each script provides an interactive menu to manage different server aspects.

### Available Scripts

#### 📁 **baremetal** - `baremetal.sh` (v2.0)
**Function:** Bare-metal backup and restore system for Linux
- Complete system backup creation
- Bare-metal system restoration
- Backup listing and deletion
- Simple and compact interface

#### 📁 **addSite_CloudFlareTunnelsZeroTrust** - `addsite_cftzt.sh` (v2.0)
**Function:** Virtual Host (VHost) manager optimized for Cloudflare Tunnel
- Automatic user creation and directory structure
- Nginx Virtual Host configuration optimized for reverse proxy
- Self-signed SSL certificate generation
- Per-user PHP-FPM integration
- Automatic phpMyAdmin symbolic link
- Complete VHost removal with security confirmation

#### 📁 **basic** - `basic.sh` (v1.0)
**Function:** Basic system tools installation
- Install/uninstall: curl, unzip, unrar, git, ufw, wget
- UFW firewall configuration
- Bilingual interface (Portuguese/English)
- Automatic system detection

#### 📁 **disk** - `disk.sh` (v1.0)
**Function:** Complete disk and partition management
- Disk and partition listing
- Partition creation and deletion
- Formatting (NTFS, ext4, FAT32, exFAT)
- Mount and unmount operations
- Automatic mount configuration

#### 📁 **mariadb** - `mariadb.sh` (v1.0)
**Function:** MariaDB database server management
- MariaDB Server and Client installation
- Security configuration (mysql_secure_installation)
- Complete uninstallation with data cleanup
- Service control (status, restart)

#### 📁 **nginx** - `nginx.sh` (v1.4)
**Function:** Nginx web server with SSL configuration
- Automatic Nginx installation and configuration
- Self-signed SSL certificate generation
- Automatic IP detection
- Custom error pages
- Directory structure for 'server' user
- Permission correction script (`fix_nginx_permissions.sh`)

#### 📁 **php_nginx** - `php_nginx.sh` (v1.0)
**Function:** PHP 8.4 environment with FastCGI for Nginx
- PHP 8.4 and essential modules installation
- PHP-FPM configuration
- Nginx integration
- Composer installation
- PHP test file

#### 📁 **phpmyadmin** - `phpmyadmin.sh` (v1.0)
**Function:** Web interface for database management
- phpMyAdmin installation
- Symbolic link configuration for Nginx
- MariaDB integration
- Access via `/phpmyadmin`

#### 📁 **proftpd** - `proftpd.sh` (v1.1)
**Function:** Secure FTP server
- ProFTPD installation and configuration
- Chroot configuration for security
- User restriction to home directories
- Service control

#### 📁 **tailscale** - `tailscale.sh` (v1.0)
**Function:** Mesh VPN for secure remote access
- Tailscale installation
- Connection management
- Status and IP verification
- Complete uninstallation

#### 📁 **update** - `update.sh` (v1.1)
**Function:** System update and maintenance
- Update, upgrade, dist-upgrade
- Dependency fixing
- Package cleanup (autoremove, autoclean)
- Restart and shutdown options

---

## 🚀 Uso Geral / General Usage

### Português
1. Navegue até a pasta do script desejado
2. Execute: `chmod +x nome_do_script.sh`
3. Execute: `sudo ./nome_do_script.sh`
4. Siga o menu interativo

### English
1. Navigate to the desired script folder
2. Run: `chmod +x script_name.sh`
3. Run: `sudo ./script_name.sh`
4. Follow the interactive menu

---

## 📋 Pré-requisitos / Prerequisites

- **Hardware:** Banana Pi M5 (aarch64/ARM64)
- **OS:** Ubuntu 24.04 LTS (Noble Numbat)
- **Privileges:** Root/sudo access required
- **Network:** Internet connection for package downloads

---

## ⚠️ Avisos Importantes / Important Warnings

### 🇧🇷 Português
- Sempre execute os scripts como root ou com sudo
- Faça backup dos dados importantes antes de usar scripts de formatação
- Alguns scripts podem remover dados permanentemente
- Teste em ambiente controlado antes de usar em produção

### 🇺🇸 English
- Always run scripts as root or with sudo
- Backup important data before using formatting scripts
- Some scripts may permanently remove data
- Test in controlled environment before production use

---

## 📝 Licença / License

Estes scripts são fornecidos "como estão" para uso educacional e de desenvolvimento. Use por sua própria conta e risco.

These scripts are provided "as is" for educational and development purposes. Use at your own risk.