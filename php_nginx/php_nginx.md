# Gerenciador de PHP 8.4 para Banana Pi M5 / Ubuntu 24.04 (Noble)

## Nome do Script
`php_nginx.sh`

## Versão
1.0

## Compatibilidade
* **Hardware:** Banana Pi M5 (aarch64/ARM64)
* **Sistema Operacional:** Ubuntu 24.04 LTS (Noble Numbat)

## Descrição
Este script em Bash foi desenvolvido para automatizar a instalação, configuração e desinstalação do ambiente **PHP 8.4** com **FastCGI Process Manager (FPM)** e **Composer** em um servidor Nginx rodando em um Banana Pi M5.

Ele é um complemento ao script `nginx.sh` e assume que o **Nginx já está instalado** e a estrutura de diretórios (`/home/server/public_html`, etc.) para o usuário `server` já foi criada.

O script utiliza o repositório PPA de **Ondrej Sury** para acessar a versão mais recente do PHP (`8.4`), ainda não disponível nos repositórios padrão do Ubuntu 24.04.

## Funcionalidades Principais

| Opção | Ação | Detalhes |
| :---: | :--- | :--- |
| **1** | Instalar/Configurar PHP 8.4 (FPM) e Composer | Adiciona o PPA de Ondrej Sury, instala o PHP 8.4 e módulos comuns, configura o PHP-FPM com um pool dedicado para o usuário `server`, ajusta a configuração padrão do Nginx (`/etc/nginx/sites-available/default`) para processar arquivos `.php` via socket do FPM, instala o Composer globalmente e cria um arquivo `info.php` de teste. |
| **2** | Desinstalar PHP 8.4 e Composer | Interrompe o serviço FPM, remove todos os pacotes PHP 8.4 (`--purge`), apaga os arquivos de configuração FPM, remove o Composer e **tenta reverter a configuração do Nginx** usando o backup criado durante a instalação do PHP. |
| **3** | Status do PHP-FPM | Exibe o status atual do serviço `php8.4-fpm` via `systemctl`. |
| **4** | Reiniciar PHP-FPM | Reinicia o serviço `php8.4-fpm`. |
| **5** | Testar Configuração Nginx/PHP | Verifica a validade da sintaxe do Nginx (`nginx -t`) e o status do serviço PHP-FPM. |
| **6** | Ver Logs do PHP-FPM | Exibe as últimas 50 linhas de log do serviço FPM via `journalctl`. |
| **0** | Sair | Encerra o script. |

## Instruções de Uso

1.  **Pré-requisito:** Certifique-se de que o Nginx está instalado e funcionando (preferencialmente após executar a opção 1 do `nginx.sh`).
2.  Salve o código acima como `php_nginx.sh`.
3.  Conceda permissão de execução:
    ```bash
    chmod +x php_nginx.sh
    ```
4.  Execute o script como root:
    ```bash
    sudo ./php_nginx.sh
    ```
5.  Selecione a opção **1** para instalar e configurar o ambiente PHP/Composer.

## Prompt Original

> seguindo a base a seguir:
> 
> \[... Conteúdo completo do script nginx.sh ...\]
> 
> crie um script em bash (com menu onde a opção 0 é de sair e/ou voltar) com o mesmo para funcionar no banana pi m5 com arquitetura de aarch64 e no ubuntu 24.04 (noble) que instale e desistale (e apague a pasta, mesmo que ela não esteja vazia) o php8.4. Condigurando o arquivo padrão do ngnix para o para funcionar com o mesmo (analizando o arquivo padrão antes). Instale também o composer. Crie também um arquivo .md com o mesmo nome com a explicação e com esse prompt original. E no fina do arquivo crie "rm -rf arquivo.sh;nano arquivo.sh;chmod +x arquivo.sh;bash arquivo.sh" trocando arquivo pelo o nome de arquivo;

## Comandos Úteis para o `php_nginx.sh`

```bash
rm -rf php_nginx.sh;nano php_nginx.sh;chmod +x php_nginx.sh;sudo bash php_nginx.sh