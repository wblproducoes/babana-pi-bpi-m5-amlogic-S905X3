# Script de Gerenciamento de Discos para Banana Pi M5 e Ubuntu 24.04 - disk.sh

## Histórico de Atualizações

### 📝 **Versão 1.0** - Versão Inicial
**Prompt Original:**
na pasta disk crie um script em bash (com menu onde a opção 0 é de sair e/ou voltar) com o mesmo nome para funcionanr no banana pi m5 com arquitetura de aarch64 e no ubuntu 24.04 (noble) que liste, apague, crie partição, formate (com suporte NTFS), monte, desmonte e monte automaticamente. Crie também um arquivo .md com o mesmo nome com a explicação e com esse prompt original. E no fina do arquivo crie "rm -rf arquivo.sh;nano arquivo.sh;chmod +x arquivo.sh;bash arquivo.sh" trocando arquivo pelo o nome de arquivo;

---

## Descrição

Este script foi desenvolvido especificamente para o **Banana Pi M5** com arquitetura **aarch64** e **Ubuntu 24.04 (Noble)**. Ele oferece uma interface de menu interativa para gerenciar completamente discos e partições, incluindo criação, formatação, montagem e configuração de montagem automática.

### Funcionalidades Principais

#### 1. **Listagem de Discos e Partições**
- Exibe todos os discos e partições disponíveis usando `lsblk`
- Mostra informações detalhadas com `fdisk -l`
- Lista partições montadas com `df -h`
- Apresenta informações de tamanho, tipo, ponto de montagem, sistema de arquivos e rótulo

#### 2. **Criação de Partições**
- Suporte para partições primárias, estendidas e lógicas
- Permite especificar tamanho personalizado ou usar todo o espaço disponível
- Utiliza `parted` para operações seguras de particionamento
- Confirmação obrigatória antes de modificar a tabela de partições
- Exibe a nova tabela de partições após criação

#### 3. **Exclusão de Partições**
- Remove partições de forma segura
- Verifica se a partição está montada e oferece desmontagem automática
- Confirmação dupla para evitar exclusões acidentais
- Atualiza automaticamente a tabela de partições

#### 4. **Formatação de Partições**
- **Suporte completo para NTFS** usando `ntfs-3g`
- Suporte adicional para:
  - **ext4** (sistema nativo Linux)
  - **FAT32** (compatibilidade universal)
  - **exFAT** (arquivos grandes)
- Permite definir rótulos personalizados
- Desmontagem automática se necessário
- Verificação de integridade após formatação

#### 5. **Montagem de Partições**
- Montagem manual de partições em pontos específicos
- Criação automática de diretórios de montagem
- Verificação de status de montagem
- Exibição de informações de uso após montagem

#### 6. **Desmontagem de Partições**
- Desmontagem segura de partições
- Suporte para desmontagem forçada em casos problemáticos
- Aceita tanto dispositivos quanto pontos de montagem como entrada

#### 7. **Montagem Automática (fstab)**
- Configuração de montagem automática no boot
- Utiliza UUID para identificação segura de partições
- Opções de montagem personalizáveis ou padrão
- Backup automático do arquivo `/etc/fstab`
- Teste de configuração antes de aplicar
- Rollback automático em caso de erro

### Menu Interativo

```
========================================
  MENU DO DISK MANAGER / DISK MANAGER MENU
  Banana Pi M5 & Ubuntu 24.04
========================================

1) Listar Discos e Partições / List Disks and Partitions
2) Criar Partição / Create Partition
3) Apagar Partição / Delete Partition
4) Formatar Partição / Format Partition
5) Montar Partição / Mount Partition
6) Desmontar Partição / Unmount Partition
7) Configurar Montagem Automática / Configure Auto Mount
0) Sair / Exit

========================================
```

### Dependências e Instalação Automática

O script verifica e instala automaticamente os seguintes pacotes necessários:

- **parted**: Gerenciamento avançado de partições
- **fdisk**: Utilitário de particionamento
- **ntfs-3g**: Suporte completo para NTFS
- **dosfstools**: Ferramentas para FAT32
- **e2fsprogs**: Ferramentas para ext4
- **util-linux**: Utilitários básicos do sistema

### Funções Auxiliares

#### **Detecção de Sistema**
- Detecta automaticamente a arquitetura do sistema
- Verifica a versão e codinome do Ubuntu
- Exibe avisos se o sistema não for o recomendado
- Mostra informações do sistema a cada execução

#### **Verificação de Privilégios**
- Verifica se o script está sendo executado como root
- Exibe mensagens em português e inglês
- Impede execução sem privilégios adequados

#### **Interface Bilíngue**
- Todas as mensagens são exibidas em português e inglês
- Facilita o uso por usuários de diferentes idiomas
- Mantém consistência em toda a interface

### Recursos de Segurança

#### **Confirmações Obrigatórias**
- Todas as operações destrutivas requerem confirmação
- Avisos claros sobre perda de dados
- Verificações de integridade antes de operações críticas

#### **Backup Automático**
- Backup automático do `/etc/fstab` antes de modificações
- Rollback automático em caso de erro na configuração
- Preservação de configurações existentes

#### **Verificações de Integridade**
- Validação de dispositivos e partições antes de operações
- Verificação de status de montagem
- Testes de configuração antes de aplicar mudanças

### Compatibilidade

- **Sistema Operacional**: Ubuntu 24.04 (Noble)
- **Arquitetura**: aarch64 (ARM64)
- **Hardware**: Otimizado para Banana Pi M5
- **Privilégios**: Requer execução como root (sudo)

### Uso

1. Execute o script com privilégios de root:
   ```bash
   sudo bash disk.sh
   ```

2. Use o menu interativo para navegar pelas opções

3. A opção 0 sempre retorna ao menu principal ou sai do script

### Exemplos de Uso

#### **Criar e Formatar Partição NTFS**
1. Escolha opção 2 (Criar Partição)
2. Selecione o dispositivo (ex: /dev/sdb)
3. Escolha tipo primário e tamanho
4. Escolha opção 4 (Formatar Partição)
5. Selecione a nova partição
6. Escolha NTFS e defina um rótulo

#### **Configurar Montagem Automática**
1. Escolha opção 7 (Configurar Montagem Automática)
2. Selecione a partição desejada
3. Defina o ponto de montagem
4. Configure as opções de montagem
5. Confirme a adição ao fstab

### Notas Importantes

- **Backup**: Sempre faça backup de dados importantes antes de operações de particionamento
- **Conectividade**: Certifique-se de ter conexão com a internet para instalação de dependências
- **Espaço**: Verifique espaço disponível antes de criar partições
- **Compatibilidade**: NTFS oferece melhor compatibilidade com Windows

### Avisos de Segurança

- Execute apenas em sistemas confiáveis
- Verifique a integridade do script antes da execução
- Tenha cuidado especial com operações de formatação e exclusão
- Mantenha backups atualizados de dados importantes

### Dicas de Uso

- Use `lsblk` para identificar dispositivos antes de operações
- Prefira UUID para montagem automática (mais estável)
- Configure permissões adequadas para partições NTFS/FAT32
- Monitore logs do sistema em caso de problemas

### Troubleshooting

#### Problemas Comuns:

1. **Erro de permissão**: Execute com `sudo`
2. **Partição ocupada**: Desmonte antes de operações
3. **Dependências faltando**: O script instala automaticamente
4. **Erro no fstab**: Backup é restaurado automaticamente

#### Logs Úteis:
```bash
# Verificar logs do kernel
dmesg | tail

# Verificar montagens
mount | grep /dev/

# Verificar fstab
cat /etc/fstab

# Verificar partições
lsblk -f
```

#### Comandos de Emergência:
```bash
# Reparar fstab corrompido
sudo cp /etc/fstab.backup.* /etc/fstab

# Forçar verificação de disco
sudo fsck /dev/sdXY

# Remover entrada problemática do fstab
sudo nano /etc/fstab
```

---

## Comandos para Gerenciar o Arquivo

```bash
rm -rf disk.sh;nano disk.sh;chmod +x disk.sh;bash disk.sh
```