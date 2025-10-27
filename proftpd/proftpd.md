# Gerenciador de ProFTPD Server para Banana Pi M5 / Ubuntu 24.04 (Noble)

## Nome do Script
`proftpd.sh`

## Versão
1.1 (Correção de Chroot)

## Compatibilidade
* **Hardware:** Banana Pi M5 (aarch64/ARM64)
* **Sistema Operacional:** Ubuntu 24.04 LTS (Noble Numbat)

## Descrição
Este script em Bash automatiza a instalação, a configuração de segurança essencial (Chroot) e a desinstalação completa do **ProFTPD Server**.

A versão 1.1 corrige o problema de configuração de segurança, garantindo que os usuários FTP sejam **estritamente restritos** às suas pastas home.

### Correção de Chroot
A função de configuração agora garante duas diretivas cruciais no `/etc/proftpd/proftpd.conf`:
1.  **`DefaultRoot ~`**: Restringe o usuário à sua pasta home.
2.  **`RequireValidShell off`**: Permite que usuários com shells desabilitados (como `/bin/false`, comum para contas FTP seguras) se conectem sem serem bloqueados pelo Chroot.

## Funcionalidades Principais

| Opção | Ação | Detalhes |
| :---: | :--- | :--- |
| **1** | Instalar e Configurar ProFTPD (Com Chroot) | Instala o ProFTPD e configura automaticamente as diretivas `DefaultRoot ~` e `RequireValidShell off` no arquivo de configuração principal. |
| **2** | Desinstalar ProFTPD | **OPERAÇÃO DESTRUTIVA:** Remove completamente o pacote e todos os seus diretórios de configuração e logs. |
| **3** | Status do ProFTPD | Exibe o status do serviço. |
| **4** | Reiniciar ProFTPD | Reinicia o serviço. |
| **5** | Re-aplicar Configuração Chroot | Executa apenas a etapa de configuração de chroot, garantindo que as diretivas de segurança estejam corretas e reinicia o serviço. |
| **0** | Sair | Encerra o script. |

## Instruções de Uso

1.  Salve o código Bash como `proftpd.sh`.
2.  Conceda permissão de execução:
    ```bash
    chmod +x proftpd.sh
    ```
3.  Execute o script como root:
    ```bash
    sudo ./proftpd.sh
    ```
4.  Selecione a opção **1** para instalar e configurar o serviço com segurança. Se já estava instalado, use a opção **5** para aplicar a correção.

## Prompt Original

> seguindo a base a seguir:
> 
> \[... Conteúdo completo do script nginx.sh ...\]
> 
> no arquivo proftpd não limitou o acesso para somente a pasta do usuário

## Comandos Úteis para o `proftpd.sh`

```bash
rm -rf proftpd.sh;nano proftpd.sh;chmod +x proftpd.sh;sudo bash proftpd.sh