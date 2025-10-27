# Script BareMetal.sh v2.0 - Sistema de Backup Bare-Metal Rápido

## Descrição

O `baremetal.sh` v2.0 é um script **simples, rápido e compactado** em Bash para backup/restauração bare-metal em sistemas Linux. Otimizado para **velocidade** e **simplicidade**, oferece backup direto compactado e interface minimalista.

## Funcionalidades Principais

### Menu Simples
- **1) Criar backup**: Backup rápido e compactado automaticamente
- **2) Restaurar backup**: Restauração direta de arquivo compactado
- **3) Criar sistema bare-metal**: Sistema mínimo básico
- **4) Listar backups**: Lista simples de backups disponíveis
- **5) Apagar backup**: Remoção segura de backups
- **0) Sair**: Encerramento do script

### 💾 Backup Completo do Sistema
- Backup de todos os diretórios essenciais do sistema
- Exclusão automática de diretórios temporários e virtuais
- Preservação de permissões, links simbólicos e atributos estendidos
- Geração de checksums MD5 para verificação de integridade
- Opção de compactação automática
- Salvamento de informações de particionamento e montagem

### 🔄 Restauração de Sistema
- Restauração completa a partir de backups existentes
- Verificação de integridade antes da restauração
- Múltiplas confirmações de segurança
- Suporte a backups compactados e descompactados
- Opção de reinicialização automática após restauração

### 🆕 Criação de Sistema Bare-Metal
- Criação de estrutura de diretórios padrão Linux
- Configuração de arquivos essenciais do sistema
- Criação de usuários e grupos básicos
- Script de inicialização personalizado
- Configuração de permissões adequadas

## 🔒 Características de Segurança

### ✅ Validações Obrigatórias
- **Privilégios Root**: Verificação obrigatória de execução como root
- **Dependências**: Verificação de todas as ferramentas necessárias
- **Espaço em Disco**: Verificação de espaço disponível no destino
- **Integridade**: Verificação de checksums MD5 dos backups

### 🛡️ Medidas de Proteção
- Múltiplas confirmações para operações destrutivas
- Logs detalhados de todas as operações
- Backup de informações de sistema antes da restauração
- Exclusão automática de diretórios perigosos durante backup

## 📁 Estrutura de Backup

### 🗂️ Diretórios Incluídos no Backup
- `/etc` - Configurações do sistema
- `/home` - Diretórios dos usuários
- `/root` - Diretório do usuário root
- `/var` - Dados variáveis do sistema
- `/usr/local` - Software instalado localmente
- `/opt` - Pacotes de software opcionais
- `/boot` - Arquivos de inicialização

### 🚫 Diretórios Excluídos do Backup
- `/proc/*` - Sistema de arquivos virtual do processo
- `/sys/*` - Sistema de arquivos virtual do sistema
- `/dev/*` - Arquivos de dispositivo
- `/tmp/*` - Arquivos temporários
- `/run/*` - Dados de tempo de execução
- `/mnt/*` e `/media/*` - Pontos de montagem
- `/var/cache/*` e `/var/tmp/*` - Cache e temporários
- Lixeiras e caches de usuários

## 🔧 Dependências Técnicas

### 📦 Ferramentas Necessárias
- `rsync` - Sincronização e backup de arquivos
- `tar` - Compactação e arquivamento
- `gzip` - Compressão de arquivos
- `mount/umount` - Montagem de sistemas de arquivos
- `fdisk` - Gerenciamento de partições
- `lsblk` - Listagem de dispositivos de bloco
- `df` - Informações de espaço em disco
- `du` - Cálculo de tamanho de arquivos
- `awk` - Processamento de texto

### 🖥️ Compatibilidade
- **Compatibilidade**: Linux (Ubuntu, Debian, CentOS, RHEL)
- **Arquiteturas**: x86_64, aarch64, i386
- **Privilégios**: Execução obrigatória como root
- **Destino**: `/opt/backups` (disco principal)

## 📊 Sistema de Logs

### 📝 Arquivo de Log
- **Localização**: `/var/log/baremetal.log`
- **Formato**: `[YYYY-MM-DD HH:MM:SS] [LEVEL] Mensagem`
- **Níveis**: SUCCESS, ERROR, WARNING, INFO, BACKUP, RESTORE, CREATE

### 🎨 Interface Colorida
- **Verde**: Operações bem-sucedidas
- **Vermelho**: Erros e avisos críticos
- **Amarelo**: Avisos e confirmações
- **Azul**: Informações gerais
- **Roxo**: Operações de backup
- **Ciano**: Operações de restauração

## 🚀 Instalação e Uso

### 📥 Instalação
```bash
# Baixar o script
wget -O baremetal.sh [URL_DO_SCRIPT]

# Dar permissão de execução
chmod +x baremetal.sh

# Verificar se o destino existe
sudo mkdir -p /media/disk0
```

### ▶️ Execução
```bash
# Executar o script (obrigatório como root)
sudo bash baremetal.sh
```

### 🔧 Configuração do Destino
```bash
# Montar dispositivo de backup (exemplo)
sudo mount /dev/sdb1 /media/disk0

# Verificar montagem
df -h /media/disk0
```

## 📋 Exemplos de Uso

### 💾 Criar Backup Completo
1. Execute o script como root
2. Selecione opção **1** - Criar Backup Completo
3. Confirme a operação (pode demorar horas)
4. Escolha se deseja compactar o backup
5. Aguarde a conclusão e verificação de integridade

### 🔄 Restaurar Sistema
1. Execute o script como root
2. Selecione opção **2** - Restaurar Sistema
3. Escolha o backup da lista disponível
4. Confirme múltiplas vezes (operação irreversível)
5. Digite "CONFIRMO" para prosseguir
6. Aguarde restauração e reinicialize se necessário

### 🆕 Criar Sistema Bare-Metal
1. Execute o script como root
2. Selecione opção **3** - Criar Sistema Bare-Metal
3. Confirme a criação
4. Sistema mínimo será criado em `/opt/backups`
5. Configure kernel e bootloader separadamente

## 💡 Exemplos de Uso

### Criar Backup Completo
```bash
sudo ./baremetal.sh
# Escolher opção 1
# Backup será salvo em /opt/backups/backup_YYYYMMDD_HHMMSS.tar.gz
```

### Restaurar Sistema
```bash
sudo ./baremetal.sh
# Escolher opção 2
# Selecionar backup da lista
# Confirmar com "RESTAURAR"
```

### Listar Backups Disponíveis
```bash
sudo ./baremetal.sh
# Escolher opção 4
# Visualizar todos os backups em /opt/backups
```

## ⚠️ Avisos Importantes

### 🚨 Operações Críticas
- **Backup**: Pode consumir muito espaço e tempo
- **Restauração**: Operação IRREVERSÍVEL que sobrescreve o sistema atual
- **Bare-Metal**: Cria sistema mínimo que requer configuração adicional

### 🔐 Requisitos de Segurança
- Sempre execute como root (`sudo`)
- Verifique espaço disponível antes de operações
- Mantenha backups em dispositivos externos seguros
- Teste restaurações em ambiente controlado

### 💡 Recomendações
- Faça backups regulares do sistema
- Mantenha múltiplas versões de backup
- Documente configurações específicas do sistema
- Teste procedimentos de restauração periodicamente

## 🔍 Solução de Problemas

### ❌ Erros Comuns

**"Este script deve ser executado como root"**
```bash
# Solução: Execute com sudo
sudo bash baremetal.sh
```

**"Dependências ausentes"**
```bash
# Solução: Instale as dependências
sudo apt update && sudo apt install -y rsync tar gzip mount fdisk util-linux
```

**"Diretório de backup não existe"**
```bash
# Solução: Crie e monte o diretório
sudo mkdir -p /media/disk0
sudo mount /dev/[DISPOSITIVO] /media/disk0
```

**"Espaço insuficiente"**
```bash
# Solução: Libere espaço ou use dispositivo maior
df -h /media/disk0
sudo rm -rf /media/disk0/backups_antigos/
```

### 🔧 Verificações de Diagnóstico
```bash
# Verificar dependências
which rsync tar gzip mount fdisk lsblk df

# Verificar espaço disponível
df -h /media/disk0

# Verificar logs
tail -f /var/log/baremetal.log

# Verificar integridade de backup
cd /media/disk0/[BACKUP_NAME]
md5sum -c checksums.md5
```

## 📚 Informações Técnicas

### 🏗️ Arquitetura do Script
- **Modular**: Funções separadas para cada operação
- **Robusto**: Verificações extensivas de erro
- **Logging**: Sistema completo de auditoria
- **Interface**: Menu interativo intuitivo

### 🔄 Fluxo de Operações

**Backup**:
1. Verificações de sistema e privilégios
2. Preparação do destino
3. Criação da estrutura de backup
4. Sincronização com rsync
5. Geração de checksums
6. Compactação opcional

**Restauração**:
1. Listagem de backups disponíveis
2. Seleção e verificação do backup
3. Verificação de integridade
4. Confirmações de segurança
5. Restauração com rsync
6. Limpeza e reinicialização

**Bare-Metal**:
1. Criação da estrutura de diretórios
2. Configuração de arquivos essenciais
3. Definição de permissões
4. Criação de scripts de inicialização
5. Documentação do sistema criado

## 📄 Informações do Arquivo

- **Nome**: baremetal.sh
- **Versão**: 1.0
- **Linhas de Código**: ~600+
- **Linguagem**: Bash
- **Licença**: Uso livre para fins educacionais e profissionais
- **Compatibilidade**: Linux Universal

## 🎯 Histórico de Atualizações

### 📝 **Versão 1.0** - Versão Inicial
**Prompt Original:**
"crie um script em base de bare-metal que crie, restaure e faça backup do sistema para /media/disk0 com menu onde o 0 seja sair"

## 🚀 Comandos de Execução

Para editar e executar o script, use a sequência de comandos abaixo:

```bash
rm -rf baremetal.sh;nano baremetal.sh;chmod +x baremetal.sh;bash baremetal.sh
```

### 📝 Explicação dos Comandos:

1. **`rm -rf baremetal.sh`** - Remove o arquivo existente (se houver)
2. **`nano baremetal.sh`** - Abre o editor nano para edição do script
3. **`chmod +x baremetal.sh`** - Torna o script executável
4. **`bash baremetal.sh`** - Executa o script

### ⚠️ Nota Importante:
Lembre-se de executar o script com privilégios de root:
```bash
sudo bash baremetal.sh
```

---

**Desenvolvido para operações críticas de sistema - Use com responsabilidade!** 🔒