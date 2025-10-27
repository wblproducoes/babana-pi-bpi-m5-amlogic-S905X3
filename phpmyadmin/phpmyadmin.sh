# Gerenciador de phpMyAdmin para Banana Pi M5 / Ubuntu 24.04 (Noble)

## Nome do Script
`phpmyadmin.sh`

## Versão
1.0

## Compatibilidade
* **Hardware:** Banana Pi M5 (aarch64/ARM64)
* **Sistema Operacional:** Ubuntu 24.04 LTS (Noble Numbat)

## Pré-requisitos
* Nginx Server instalado e configurado (via `nginx.sh`).
* PHP 8.4 (ou superior) com PHP-FPM instalado e configurado para Nginx (via `phpmanager.sh`).
* MariaDB Server instalado e ativo (via `mariadbmanager.sh`).

## Descrição
Este script em Bash automatiza a instalação do **phpMyAdmin** via `apt` e realiza a configuração necessária para que ele seja acessível através da sua configuração de host virtual Nginx, especificamente no subdiretório `/phpmyadmin` da raiz do seu usuário `server`.

O acesso é garantido pela criação de um **link simbólico** (`symlink`) dentro do diretório `/home/server/public_html`.

**Detalhes da Configuração:**
* **Origem da Instalação:** `/usr/share/phpmyadmin`
* **Link Simbólico Criado:** `/home/server/public_html/phpmyadmin`
* **URL de Acesso:** `https://[IP_DO_SEU_BPI_M5]/phpmyadmin`

## Funcionalidades Principais

| Opção | Ação | Detalhes |
| :---: | :--- | :--- |
| **1** | Instalar phpMyAdmin e Criar Link Simbólico | Instala o pacote `phpmyadmin` via APT (usando `DEBIAN_FRONTEND=noninteractive` para evitar prompts de configuração do servidor web), e cria o link simbólico `phpmyadmin` apontando para `/usr/share/phpmyadmin` dentro do `public_html` do usuário `server`. |
| **2** | Desinstalar phpMyAdmin | Remove completamente o pacote `phpmyadmin` e seus arquivos de configuração (`--purge`), além de apagar o link simbólico criado no `public_html`. |
| **3** | Re-criar Link Simbólico | Recria o link simbólico. Útil se o link foi acidentalmente apagado, ou se a instalação inicial do Nginx/PHP não estava completa. |
| **0** | Sair | Encerra o script. |

## Instruções de Uso

1.  Salve o código Bash como `phpmyadmin.sh`.
2.  Conceda permissão de execução:
    ```bash
    chmod +x phpmyadmin.sh
    ```
3.  Execute o script como root:
    ```bash
    sudo ./phpmyadmin.sh
    ```
4.  Selecione a opção **1** para instalar o phpMyAdmin.

## Prompt Original

> seguindo a base a seguir:
> 
> \[... Conteúdo completo do script nginx.sh ...\]
> 
> agora crie um script em bash (com menu onde a opção 0 é de sair e/ou voltar) com o mesmo para funcionar no banana pi m5 com arquitetura de aarch64 e no ubuntu 24.04 (noble) que instale e desistale ( e apague a pasta mesmo que ela não esteja vazia) o phpmyadmin (atraves do apt). criando o link simbolico do phpmyadmin para dentro da pasta public_html dentro da pasta do usuário "server". Crie também um arquivo .md com o mesmo nome com a explicação e com esse prompt original. E no fina do arquivo crie "rm -rf arquivo.sh;nano arquivo.sh;chmod +x arquivo.sh;bash arquivo.sh" trocando arquivo pelo o nome de arquivo;

## Comandos Úteis para o `phpmyadmin.sh`

```bash
rm -rf phpmyadmin.sh;nano phpmyadmin.sh;chmod +x phpmyadmin.sh;sudo bash phpmyadmin.sh