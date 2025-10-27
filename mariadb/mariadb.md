# Gerenciador de MariaDB Server para Banana Pi M5 / Ubuntu 24.04 (Noble)

## Nome do Script
`mariadb.sh`

## Versão
1.0

## Compatibilidade
* **Hardware:** Banana Pi M5 (aarch64/ARM64)
* **Sistema Operacional:** Ubuntu 24.04 LTS (Noble Numbat)

## Descrição
Este script em Bash foi desenvolvido para automatizar a instalação, configuração de segurança (via `mysql_secure_installation`) e desinstalação completa do **MariaDB Server** e **Client** em um servidor rodando no Banana Pi M5.

O processo de instalação de segurança é interativo e altamente recomendado para proteger a instalação do banco de dados imediatamente após a instalação.

## Funcionalidades Principais

| Opção | Ação | Detalhes |
| :---: | :--- | :--- |
| **1** | Instalar MariaDB Server e Cliente + Segurança | Instala os pacotes `mariadb-server` e `mariadb-client` via APT, inicia e habilita o serviço e, em seguida, executa o script interativo `mysql_secure_installation`. |
| **2** | Desinstalar MariaDB | **OPERAÇÃO DESTRUTIVA:** Para e remove completamente todos os pacotes MariaDB (`--purge`) e **apaga o diretório de dados principal (`/var/lib/mysql`) e o diretório de logs (`/var/log/mysql`)**, garantindo que nenhum resíduo permaneça no sistema. |
| **3** | Executar Instalação de Segurança | Permite executar o script `mysql_secure_installation` manualmente após a instalação (útil se o passo foi interrompido). |
| **4** | Status do MariaDB | Exibe o status atual do serviço MariaDB via `systemctl`. |
| **5** | Reiniciar MariaDB | Reinicia o serviço MariaDB. |
| **0** | Sair | Encerra o script. |

## Instruções de Uso

1.  Salve o código Bash como `mariadb.sh`.
2.  Conceda permissão de execução:
    ```bash
    chmod +x mariadb.sh
    ```
3.  Execute o script como root (necessário para manipulação de serviços e pacotes):
    ```bash
    sudo ./mariadb.sh
    ```
4.  Selecione a opção **1** para instalar o MariaDB e iniciar a configuração de segurança.
    * **Nota sobre a segurança (Opção 3):** No Ubuntu 24.04, o login do root é geralmente gerenciado via **unix_socket**. Quando o script `mysql_secure_installation` solicitar a senha atual do root, basta pressionar **ENTER** (já que não há senha inicial) e prosseguir com a definição de senhas e remoção de privilégios.

## Prompt Original

> seguindo a base a seguir:
> 
> \[... Conteúdo completo do script nginx.sh ...\]
> 
> agora crie um script em bash (com menu onde a opção 0 é de sair e/ou voltar) com o mesmo para funcionar no banana pi m5 com arquitetura de aarch64 e no ubuntu 24.04 (noble) que instale e desistale ( e apague a pasta mesmo que ela não esteja vazia) o mariadb. Depois da instalação do mesmo execute o comandao de mysql_security_installation. Crie também um arquivo .md com o mesmo nome com a explicação e com esse prompt original. E no fina do arquivo crie "rm -rf arquivo.sh;nano arquivo.sh;chmod +x arquivo.sh;bash arquivo.sh" trocando arquivo pelo o nome de arquivo;

## Comandos Úteis para o `mariadb.sh`

```bash
rm -rf mariadb.sh;nano mariadb.sh;chmod +x mariadb.sh;sudo bash mariadb.sh