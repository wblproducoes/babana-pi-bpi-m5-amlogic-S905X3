# Script de Pacotes Básicos para Banana Pi M5 e Ubuntu 24.04 - basic.sh

## Prompt Original

"na pasta basic crie um script em bash (com menu onde a opção 0 é de sair e/ou voltar) com o mesmo nome para funcionanr no banana pi m5 com arquitetura de aarch64 e no ubuntu 24.04 (noble) que instale e desistale (incluindo a pasta, mesmo que a mesma não esteja vazia) o curl, unzip, unrar, git, ufw (configurando o mesmo para as portas: 20,21,40000:50000, 80, 443, 22, 1305, 465, 587, 993, 995, 143, 110) e mostrando o status e reiniciando, wget. Crie também um arquivo .md com o mesmo nome com a explicação e com esse prompt original. E no fina do arquivo crie "rm -rf arquivo.sh;nano arquivo.sh;chmod +x arquivo.sh;bash arquivo.sh" trocando arquivo pelo o nome de arquivo"

## Descrição do Script

Este script foi desenvolvido especificamente para o **Banana Pi M5** com arquitetura **aarch64** e **Ubuntu 24.04 (Noble)**. Ele oferece um menu interativo para gerenciar pacotes básicos essenciais e configurar o firewall UFW.

### Funcionalidades Principais

- **Instalação de Pacotes**: Instala automaticamente curl, unzip, unrar, git, ufw e wget
- **Desinstalação Completa**: Remove todos os pacotes com purge e limpeza adicional
- **Configuração UFW**: Configura o firewall com portas específicas
- **Gerenciamento UFW**: Mostra status e permite reiniciar o firewall
- **Interface Bilíngue**: Português e Inglês
- **Detecção de Sistema**: Verifica arquitetura e versão do OS

## Estrutura do Menu

```
1) Instalar todos os pacotes / Install all packages
2) Desinstalar todos os pacotes / Uninstall all packages  
3) Configurar UFW (portas específicas) / Configure UFW (specific ports)
4) Mostrar status do UFW / Show UFW status
5) Reiniciar UFW / Restart UFW
0) Sair / Exit
```

## Explicação das Funções

### 1. Instalação de Pacotes (`install_packages`)
- **Atualiza** a lista de pacotes com `apt update`
- **Instala** cada pacote individualmente: curl, unzip, unrar, git, ufw, wget
- **Verifica** o status de instalação de cada pacote
- **Exibe** mensagens de sucesso ou erro para cada operação

### 2. Desinstalação de Pacotes (`uninstall_packages`)
- **Solicita confirmação** antes de remover os pacotes
- **Remove** cada pacote com `apt remove --purge` (remoção completa)
- **Executa limpeza** adicional com `apt autoremove` e `apt autoclean`
- **Remove** dependências desnecessárias e cache

### 3. Configuração UFW (`configure_ufw`)
- **Instala UFW** se não estiver presente
- **Reseta** configurações anteriores com `ufw --force reset`
- **Define políticas padrão**: deny incoming, allow outgoing
- **Configura portas específicas**:
  - **FTP**: 20 (dados), 21 (controle), 40000:50000 (passivo)
  - **Web**: 80 (HTTP), 443 (HTTPS)
  - **SSH**: 22
  - **Email**: 465 (SMTP SSL), 587 (SMTP TLS), 993 (IMAP SSL), 995 (POP3 SSL), 143 (IMAP), 110 (POP3)
  - **Personalizada**: 1305

### 4. Status UFW (`show_ufw_status`)
- **Verifica** se UFW está instalado
- **Exibe** status detalhado com `ufw status verbose`
- **Mostra** todas as regras configuradas

### 5. Reiniciar UFW (`restart_ufw`)
- **Desabilita** UFW temporariamente
- **Reabilita** UFW forçadamente
- **Garante** que as configurações sejam aplicadas

## Detecção de Sistema

O script inclui verificação automática de:
- **Arquitetura**: Deve ser aarch64
- **Sistema Operacional**: Ubuntu 24.04 (Noble)
- **Privilégios**: Deve ser executado como root (sudo)

## Verificação de Privilégios

- **Verifica** se está rodando como root
- **Exibe** mensagem de erro se não tiver privilégios adequados
- **Encerra** execução se não for root

## Interface Bilíngue

Todas as mensagens são exibidas em:
- **Português**: Idioma principal
- **Inglês**: Idioma secundário

## Compatibilidade

- **Hardware**: Banana Pi M5
- **Arquitetura**: aarch64 (ARM 64-bit)
- **Sistema**: Ubuntu 24.04 LTS (Noble Numbat)
- **Privilégios**: Requer sudo/root

## Como Usar

1. **Baixe** ou crie o arquivo `basic.sh`
2. **Torne executável**: `chmod +x basic.sh`
3. **Execute como root**: `sudo bash basic.sh`
4. **Escolha** a opção desejada no menu (0-5)
5. **Siga** as instruções na tela

## Notas Importantes

⚠️ **ATENÇÃO**: 
- Este script requer privilégios de root (sudo)
- A desinstalação remove completamente os pacotes
- A configuração UFW reseta regras anteriores
- Sempre faça backup antes de executar

## Dicas de Uso

- **Opção 1**: Use para instalação inicial do sistema
- **Opção 2**: Use com cuidado - remove todos os pacotes
- **Opção 3**: Configure após instalar UFW
- **Opção 4**: Verifique regras antes de modificar
- **Opção 5**: Use após mudanças na configuração

## Solução de Problemas

- **Erro de permissão**: Execute com `sudo`
- **Pacote não encontrado**: Verifique conexão com internet
- **UFW não funciona**: Verifique se está instalado
- **Arquitetura incompatível**: Verifique se é aarch64

## Comandos para Gerenciar o Arquivo

```bash
rm -rf basic.sh;nano basic.sh;chmod +x basic.sh;bash basic.sh
```