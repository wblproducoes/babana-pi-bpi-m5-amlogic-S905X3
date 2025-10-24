# Script de Gerenciamento do Timeshift para Banana Pi M5 e Ubuntu 24.04 - timeshift.sh

## Prompt Original

"na pasta timeshift crie um script em bash (com menu onde a opção 0 é de sair e/ou voltar) com o mesmo nome para funcionanr no banana pi m5 com arquitetura de aarch64 e no ubuntu 24.04 (noble) que instale e desistale (incluindo a pasta, mesmo que a mesma não esteja vazia) o time timeshift e xauth. Crie também um arquivo .md com o mesmo nome com a explicação e com esse prompt original. E no fina do arquivo crie "rm -rf arquivo.sh;nano arquivo.sh;chmod +x arquivo.sh;bash arquivo.sh" trocando arquivo pelo o nome de arquivo 

no timeshift_manager preciso ser capas de criar, ver e restaurar os backups. inclua essa opções no menu e atualize a documentação"

"Quero atualizar o script timeshift para incluir um menu interativo com opções para instalar, desinstalar, criar, restaurar e visualizar backups do Timeshift, além de uma opção para sair."

## Descrição do Script

Este script foi desenvolvido especificamente para o **Banana Pi M5** com arquitetura **aarch64** e **Ubuntu 24.04 (Noble)**. Ele oferece um menu interativo completo para gerenciar o Timeshift, uma ferramenta de backup e restauração de sistema baseada em snapshots.

### Funcionalidades Principais

- **Instalação via PPA Oficial**: Instala Timeshift usando o repositório oficial
- **Desinstalação Completa**: Remove Timeshift com opção de limpar diretório /timeshift
- **Criação de Backups**: Cria snapshots do sistema sob demanda com comentários personalizados
- **Restauração com Assistente Gráfico**: Abre interface gráfica para restauração ou modo linha de comando
- **Visualização de Backups**: Lista detalhada de todos os snapshots com informações de espaço
- **Interface Bilíngue**: Português e Inglês
- **Detecção de Sistema**: Verifica arquitetura e versão do OS
- **Verificação de Privilégios**: Controle de acesso root

## Estrutura do Menu Atualizado

```
========================================
  MENU DO TIMESHIFT MANAGER / TIMESHIFT MANAGER MENU
  Banana Pi M5 & Ubuntu 24.04
========================================

1) Instalar Timeshift / Install Timeshift
2) Desinstalar Timeshift / Uninstall Timeshift
3) Criar Backup com Timeshift / Create Backup with Timeshift
4) Restaurar Backup com Timeshift / Restore Backup with Timeshift
5) Ver Backups do Timeshift / View Timeshift Backups
6) Sair / Exit

========================================
```

## Explicação das Funções

### 1. Instalar Timeshift (`install_packages`)
**Nova implementação com PPA oficial:**
- **Verifica** se já está instalado
- **Adiciona** repositório PPA oficial: `ppa:teejee2008/timeshift`
- **Atualiza** lista de pacotes
- **Instala** Timeshift automaticamente
- **Verifica** versão instalada
- **Tratamento de erros** durante adição do PPA

**Processo de instalação:**
1. Verificação de instalação prévia
2. Adição do PPA oficial
3. Atualização de repositórios
4. Instalação do Timeshift
5. Verificação de versão

### 2. Desinstalar Timeshift (`uninstall_packages`)
**Funcionalidade aprimorada:**
- **Verifica** se está instalado antes de tentar remover
- **Solicita confirmação** antes de remover
- **Para serviços** relacionados ao Timeshift
- **Remove** Timeshift com `apt remove --purge`
- **Opção para remover PPA** do sistema
- **⚠️ NOVA: Opção especial para remover diretório /timeshift** com todos os snapshots
- **Remove configurações** do usuário opcionalmente
- **Limpeza automática** do sistema

**Diretórios gerenciados:**
- `/timeshift` - **Diretório principal com todos os snapshots** (NOVA OPÇÃO)
- `~/.config/timeshift` - Configurações do usuário
- `/etc/timeshift` - Configurações do sistema

### 3. Criar Backup com Timeshift (`create_backup`)
**Funcionalidade sob demanda:**
- **Verifica** instalação do Timeshift
- **Configuração automática** se necessário
- **Solicita comentário personalizado** para o backup
- **Comentário padrão** se não fornecido
- **Cria snapshot** com `timeshift --create`
- **Mostra informações** do backup criado
- **Verificações de espaço** e permissões

**Processo de criação:**
1. Verificação de instalação
2. Configuração automática (se necessário)
3. Solicitação de comentário
4. Criação do snapshot
5. Exibição de informações do backup
6. Instruções para visualizar todos os backups

### 4. Restaurar Backup com Timeshift (`restore_backup`)
**Nova funcionalidade com assistente gráfico:**
- **Verifica** instalação do Timeshift
- **Lista** snapshots existentes primeiro
- **Detecta ambiente gráfico** (DISPLAY/WAYLAND_DISPLAY)
- **🆕 Abre assistente gráfico** (`timeshift-gtk`) quando disponível
- **Modo linha de comando** como fallback
- **Confirmações de segurança** múltiplas
- **Avisos sobre perda de dados**

**Assistente gráfico oferece:**
- Visualização de todos os snapshots
- Seleção interativa do snapshot
- Escolha de arquivos específicos para restaurar
- Interface amigável para restauração

**Processo de restauração:**
1. Verificação de instalação
2. Listagem de snapshots disponíveis
3. Detecção de ambiente gráfico
4. Abertura do assistente gráfico OU modo linha de comando
5. Seleção do snapshot
6. Confirmações de segurança
7. Execução da restauração

### 5. Ver Backups do Timeshift (`list_backups`)
**Visualização detalhada:**
- **Verifica** instalação do Timeshift
- **Conta** número de snapshots existentes
- **Lista detalhada** de todos os snapshots
- **Mostra espaço usado** pelos backups
- **Localização** dos backups (/timeshift)
- **Instruções** para criar e restaurar backups
- **Tratamento** quando não há backups

**Informações exibidas:**
- Número total de snapshots
- Data e hora de cada backup
- Comentários associados
- Espaço total usado
- Localização dos arquivos
- Instruções de uso

## Detecção de Sistema

O script inclui verificação automática de:
- **Arquitetura**: Deve ser aarch64
- **Sistema Operacional**: Ubuntu 24.04 (Noble)
- **Privilégios**: Deve ser executado como root (sudo)
- **Ambiente Gráfico**: Detecta DISPLAY/WAYLAND_DISPLAY para GUI
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

Exemplos:
- "Instalar Timeshift / Install Timeshift"
- "Backup criado com sucesso / Backup created successfully"
- "⚠️ ATENÇÃO / WARNING ⚠️"

## Compatibilidade

- **Hardware**: Banana Pi M5
- **Arquitetura**: aarch64 (ARM 64-bit)
- **Sistema**: Ubuntu 24.04 LTS (Noble Numbat)
- **Privilégios**: Requer sudo/root
- **Interface**: Suporte a X11/Wayland para GUI
- **Repositório**: PPA oficial do Timeshift

## Como Usar

1. **Baixe** ou crie o arquivo `timeshift.sh`
2. **Torne executável**: `chmod +x timeshift.sh`
3. **Execute como root**: `sudo bash timeshift.sh`
4. **Escolha** a opção desejada no menu (1-6)
5. **Siga** as instruções na tela

## Fluxo Recomendado

1. **Instalar** (Opção 1) - Instala Timeshift via PPA oficial
2. **Criar Backup** (Opção 3) - Cria primeiro snapshot do sistema
3. **Ver Backups** (Opção 5) - Verifica backups criados e espaço usado
4. **Restaurar** (Opção 4) - Quando necessário, usando assistente gráfico
5. **Desinstalar** (Opção 2) - Remove completamente se não precisar mais

## Novas Funcionalidades Implementadas

### 🆕 Assistente Gráfico para Restauração
- Detecção automática de ambiente gráfico
- Abertura do `timeshift-gtk` para interface visual
- Seleção interativa de snapshots
- Escolha de arquivos específicos para restaurar

### 🆕 Gerenciamento do Diretório /timeshift
- Opção específica para remover diretório com todos os snapshots
- Avisos de segurança sobre perda de dados
- Verificação de existência antes da remoção

### 🆕 Instalação via PPA Oficial
- Uso do repositório oficial do Timeshift
- Verificação de instalação prévia
- Tratamento de erros durante adição do PPA

### 🆕 Informações Detalhadas de Backups
- Contagem de snapshots existentes
- Exibição de espaço usado
- Localização dos arquivos de backup

## Notas Importantes

⚠️ **ATENÇÃO**: 
- Este script requer privilégios de root (sudo)
- Backups podem ocupar muito espaço em disco
- Restauração substitui o estado atual do sistema
- **NOVO**: Remoção do diretório /timeshift apaga TODOS os snapshots permanentemente
- Sempre teste em ambiente não-produtivo primeiro
- Mantenha backups em dispositivos externos quando possível

## Dicas de Uso

- **Opção 1**: Use para instalação inicial via PPA oficial
- **Opção 2**: Use com cuidado - pode remover todos os snapshots
- **Opção 3**: Crie backups antes de mudanças importantes no sistema
- **Opção 4**: Use o assistente gráfico para restaurações mais precisas
- **Opção 5**: Monitore espaço em disco regularmente
- **Opção 6**: Sair do script

## Solução de Problemas

- **Erro de permissão**: Execute com `sudo`
- **Interface gráfica não abre**: Verifique X11/Wayland forwarding
- **Backup falha**: Verifique espaço em disco disponível
- **Restauração falha**: Verifique integridade do snapshot
- **Timeshift não encontrado**: Reinstale usando opção 1
- **PPA não adiciona**: Verifique conexão com internet
- **Snapshots não aparecem**: Verifique se /timeshift existe

## Comandos para Gerenciar o Arquivo

```bash
rm -rf timeshift.sh;nano timeshift.sh;chmod +x timeshift.sh;bash timeshift.sh
```