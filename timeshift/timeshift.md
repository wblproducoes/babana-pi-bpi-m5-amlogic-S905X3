# Script de Gerenciamento do Timeshift para Banana Pi M5 e Ubuntu 24.04 - timeshift.sh

## Prompt Original

"na pasta timeshift crie um script em bash (com menu onde a opção 0 é de sair e/ou voltar) com o mesmo nome para funcionanr no banana pi m5 com arquitetura de aarch64 e no ubuntu 24.04 (noble) que instale e desistale (incluindo a pasta, mesmo que a mesma não esteja vazia) o time timeshift e xauth. Crie também um arquivo .md com o mesmo nome com a explicação e com esse prompt original. E no fina do arquivo crie "rm -rf arquivo.sh;nano arquivo.sh;chmod +x arquivo.sh;bash arquivo.sh" trocando arquivo pelo o nome de arquivo 

no timeshift_manager preciso ser capas de criar, ver e restaurar os backups. inclua essa opções no menu e atualize a documentação"

## Descrição do Script

Este script foi desenvolvido especificamente para o **Banana Pi M5** com arquitetura **aarch64** e **Ubuntu 24.04 (Noble)**. Ele oferece um menu interativo completo para gerenciar o Timeshift, uma ferramenta de backup e restauração de sistema, junto com o xauth para suporte a X11.

### Funcionalidades Principais

- **Instalação de Pacotes**: Instala automaticamente timeshift e xauth
- **Desinstalação Completa**: Remove todos os pacotes com opção de limpar dados
- **Criação de Backups**: Cria snapshots do sistema com comentários personalizados
- **Listagem de Backups**: Visualiza todos os backups disponíveis
- **Restauração de Backups**: Restaura o sistema para um estado anterior
- **Configuração do Timeshift**: Acesso à configuração inicial
- **Interface Bilíngue**: Português e Inglês
- **Detecção de Sistema**: Verifica arquitetura e versão do OS

## Estrutura do Menu

```
1) Instalar Timeshift e Xauth / Install Timeshift and Xauth
2) Desinstalar Timeshift e Xauth / Uninstall Timeshift and Xauth
3) Configurar Timeshift / Configure Timeshift
4) Criar Backup / Create Backup
5) Listar Backups / List Backups
6) Restaurar Backup / Restore Backup
0) Sair / Exit
```

## Explicação das Funções

### 1. Instalação de Pacotes (`install_packages`)
- **Atualiza** a lista de pacotes com `apt update`
- **Instala** timeshift e xauth automaticamente
- **Verifica** o status de instalação de cada pacote
- **Exibe** mensagens de sucesso ou erro para cada operação

**Pacotes instalados:**
- **timeshift**: Ferramenta principal de backup e restauração
- **xauth**: Necessário para interface gráfica via SSH/X11

### 2. Desinstalação de Pacotes (`uninstall_packages`)
- **Solicita confirmação** antes de remover os pacotes
- **Para serviços** relacionados ao Timeshift
- **Remove** pacotes com `apt remove --purge` (remoção completa)
- **Opção adicional** para remover backups e configurações
- **Executa limpeza** com `apt autoremove` e `apt autoclean`

**Diretórios removidos (opcional):**
- `/timeshift` - Diretório principal de backups
- `/home/timeshift` - Backups de usuário
- `~/.config/timeshift` - Configurações do usuário

### 3. Configuração do Timeshift (`configure_timeshift`)
- **Verifica** se Timeshift está instalado
- **Abre interface gráfica** (timeshift-gtk) se disponível
- **Configuração via linha de comando** como alternativa
- **Suporte para agendamento** automático de backups
- **Detecção de X11** para interface gráfica

**Configurações recomendadas:**
- **Tipo**: RSYNC (para sistemas ext4)
- **Localização**: /timeshift (padrão)
- **Agendamento**: Configurável conforme necessidade

### 4. Criar Backup (`create_backup`)
- **Verifica** se Timeshift está instalado
- **Solicita comentário** personalizado para o backup
- **Cria snapshot** com `timeshift --create`
- **Adiciona timestamp** automático se não houver comentário
- **Confirma** sucesso ou falha da operação

**Processo de criação:**
1. Verificação de instalação
2. Solicitação de comentário
3. Execução do backup
4. Confirmação de status

### 5. Listar Backups (`list_backups`)
- **Verifica** se Timeshift está instalado
- **Exibe** todos os snapshots disponíveis com `timeshift --list`
- **Mostra informações** detalhadas de cada backup:
  - Data e hora de criação
  - Comentários associados
  - Tamanho do backup
  - Status do snapshot

### 6. Restaurar Backup (`restore_backup`)
- **Verifica** se Timeshift está instalado
- **Lista** backups disponíveis primeiro
- **Solicita** nome específico do snapshot
- **Confirmação dupla** para segurança
- **Executa restauração** com `timeshift --restore`
- **Aviso** sobre necessidade de reinicialização

**Processo de restauração:**
1. Listagem de backups disponíveis
2. Seleção do snapshot desejado
3. Confirmação de segurança
4. Execução da restauração
5. Verificação de status

## Detecção de Sistema

O script inclui verificação automática de:
- **Arquitetura**: Deve ser aarch64
- **Sistema Operacional**: Ubuntu 24.04 (Noble)
- **Privilégios**: Deve ser executado como root (sudo)
- **Instalação**: Verifica se Timeshift está disponível

## Verificação de Privilégios

- **Verifica** se está rodando como root
- **Exibe** mensagem de erro se não tiver privilégios adequados
- **Encerra** execução se não for root
- **Necessário** para operações de sistema e backup

## Interface Bilíngue

Todas as mensagens são exibidas em:
- **Português**: Idioma principal
- **Inglês**: Idioma secundário

## Compatibilidade

- **Hardware**: Banana Pi M5
- **Arquitetura**: aarch64 (ARM 64-bit)
- **Sistema**: Ubuntu 24.04 LTS (Noble Numbat)
- **Privilégios**: Requer sudo/root
- **Interface**: Suporte a X11 para GUI

## Como Usar

1. **Baixe** ou crie o arquivo `timeshift.sh`
2. **Torne executável**: `chmod +x timeshift.sh`
3. **Execute como root**: `sudo bash timeshift.sh`
4. **Escolha** a opção desejada no menu (0-6)
5. **Siga** as instruções na tela

## Fluxo Recomendado

1. **Instalar** (Opção 1) - Instala Timeshift e xauth
2. **Configurar** (Opção 3) - Configura localização e agendamento
3. **Criar Backup** (Opção 4) - Cria primeiro snapshot
4. **Listar** (Opção 5) - Verifica backups criados
5. **Restaurar** (Opção 6) - Quando necessário

## Notas Importantes

⚠️ **ATENÇÃO**: 
- Este script requer privilégios de root (sudo)
- Backups podem ocupar muito espaço em disco
- Restauração substitui o estado atual do sistema
- Sempre teste em ambiente não-produtivo primeiro
- Mantenha backups em dispositivos externos quando possível

## Dicas de Uso

- **Opção 1**: Use para instalação inicial
- **Opção 2**: Use com cuidado - remove tudo
- **Opção 3**: Configure antes de criar backups
- **Opção 4**: Crie backups antes de mudanças importantes
- **Opção 5**: Monitore espaço em disco regularmente
- **Opção 6**: Use apenas quando necessário

## Solução de Problemas

- **Erro de permissão**: Execute com `sudo`
- **Interface gráfica não abre**: Verifique X11 forwarding
- **Backup falha**: Verifique espaço em disco
- **Restauração falha**: Verifique integridade do snapshot
- **Timeshift não encontrado**: Reinstale usando opção 1

## Comandos para Gerenciar o Arquivo

```bash
rm -rf timeshift.sh;nano timeshift.sh;chmod +x timeshift.sh;bash timeshift.sh
```