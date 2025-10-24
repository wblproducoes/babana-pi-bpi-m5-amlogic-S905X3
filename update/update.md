# Script de Atualização para Banana Pi M5 e Ubuntu 24.04 - update.sh

## Prompt Original

```
na pasta update crie um script em bash (com menu onde a opção 0 é de sair e/ou voltar. Que eu consiga fazer cada um separadamente ou junto) com o mesmo nome para funcionanr no banana pi m5 com arquitetura de aarch64 e no ubuntu 24.04 (noble) que faça: update, upgrade, dist-upgrade, install -f -y, autoremove e autoclean. Crie também um arquivo .md com o mesmo nome com a explicação e com esse prompt original. E no fina do arquivo crie "rm -rf arquivo.sh;nano arquivo.sh;chmod +x arquivo.sh;bash arquivo.sh" trocando arquivo pelo o nome de arquivo

coloque um opção de para desligar e/ou reiniciar, não esquecendo de atualizar o arquivo md e atualizei o nome do arquivo para update
```

## Descrição do Script

Este script foi desenvolvido especificamente para o **Banana Pi M5** com arquitetura **aarch64** e **Ubuntu 24.04 (Noble)**. Ele oferece um menu interativo que permite executar comandos de atualização do sistema de forma individual ou completa.

### Características Principais:

- **Menu Interativo**: Interface amigável com opções numeradas
- **Detecção Automática**: Identifica arquitetura e versão do sistema
- **Execução Individual**: Cada comando pode ser executado separadamente
- **Atualização Completa**: Opção para executar todos os comandos em sequência
- **Verificação de Privilégios**: Garante execução como root/sudo
- **Compatibilidade**: Otimizado para Banana Pi M5 e Ubuntu 24.04

## Estrutura do Menu

```
1) Update (Atualizar lista de pacotes)
2) Upgrade (Atualizar pacotes instalados)
3) Dist-upgrade (Atualização de distribuição)
4) Install -f (Corrigir dependências)
5) Autoremove (Remover pacotes desnecessários)
6) Autoclean (Limpar cache)
7) ATUALIZAÇÃO COMPLETA (Todas as opções acima)
8) Reiniciar Sistema / Restart System
9) Desligar Sistema / Shutdown System
0) Sair / Exit
```

## Explicação das Funções

### 1. `apt update -y`
**Função**: Atualiza a lista de pacotes disponíveis nos repositórios
- Sincroniza os índices de pacotes com as fontes configuradas
- Baixa informações sobre pacotes disponíveis e suas versões
- Não instala ou atualiza pacotes, apenas atualiza a lista

### 2. `apt upgrade -y`
**Função**: Atualiza todos os pacotes instalados para suas versões mais recentes
- Instala versões mais novas dos pacotes já instalados
- Não remove pacotes existentes
- Não instala novos pacotes que não estavam previamente instalados

### 3. `apt dist-upgrade -y`
**Função**: Realiza atualização inteligente com instalação/remoção de pacotes
- Pode instalar novos pacotes ou remover obsoletos
- Resolve dependências complexas
- Mais agressivo que o upgrade simples

### 4. `apt install -f -y`
**Função**: Corrige dependências quebradas no sistema
- O parâmetro `-f` (fix-broken) corrige dependências quebradas
- Útil quando instalações anteriores foram interrompidas
- Resolve conflitos entre pacotes

### 5. `apt autoremove -y`
**Função**: Remove pacotes órfãos (dependências não utilizadas)
- Remove pacotes instalados automaticamente como dependências
- Libera espaço removendo pacotes não mais necessários
- Mantém o sistema limpo

### 6. `apt autoclean -y`
**Função**: Limpa cache de arquivos de pacotes baixados
- Remove arquivos .deb antigos do cache local
- Libera espaço em disco
- Mantém apenas arquivos de pacotes ainda disponíveis

### 7. Atualização Completa
**Função**: Executa todas as operações acima em sequência
- Processo completo de atualização e limpeza
- Garante sistema totalmente atualizado e otimizado

### 8. Reiniciar Sistema
**Função**: Reinicia o sistema operacional
- Conta regressiva de 10 segundos com opção de cancelamento (Ctrl+C)
- Útil após atualizações que requerem reinicialização
- Executa o comando `reboot` para reiniciar o sistema

### 9. Desligar Sistema
**Função**: Desliga completamente o sistema
- Conta regressiva de 10 segundos com opção de cancelamento (Ctrl+C)
- Desligamento seguro do sistema
- Executa o comando `shutdown -h now` para desligar

## Recursos Especiais

### Detecção de Sistema
O script detecta automaticamente:
- Arquitetura do processador (aarch64)
- Versão do Ubuntu (24.04)
- Codinome da distribuição (noble)

### Verificação de Privilégios
- Verifica se está sendo executado como root
- Solicita uso do sudo se necessário
- Previne erros de permissão

### Interface Bilíngue
- Mensagens em Português e Inglês
- Menu e instruções claras
- Feedback detalhado das operações

## Compatibilidade

### Sistemas Suportados:
- **Banana Pi M5** (aarch64)
- **Ubuntu 24.04 LTS** (Noble Numbat)
- Outros sistemas ARM64 com Ubuntu 24.04

### Requisitos:
- Acesso root ou sudo
- Conexão com internet
- Espaço suficiente em disco

## Como Usar

### Preparação e Execução:

```bash
# Remover arquivo existente (se houver)
rm -rf update.sh

# Criar novo arquivo
nano update.sh

# Dar permissão de execução
chmod +x update.sh

# Executar o script
bash update.sh
```

### Execução Direta:
```bash
sudo ./update.sh
```

## Observações Importantes

⚠️ **Avisos de Segurança:**
- Sempre execute com privilégios de administrador (sudo)
- Faça backup do sistema antes de atualizações importantes
- Verifique espaço em disco disponível
- Teste em ambiente controlado primeiro

💡 **Dicas de Uso:**
- Use a opção 7 para atualização completa automática
- Execute opções individuais para controle granular
- Monitore a saída para identificar possíveis problemas
- Reinicie o sistema após atualizações importantes

🔧 **Solução de Problemas:**
- Se houver erros de dependência, use a opção 4
- Para problemas de espaço, use opções 5 e 6
- Em caso de falhas, execute novamente após reinicialização

## Comandos para Gerenciar o Arquivo

```bash
rm -rf update.sh;nano update.sh;chmod +x update.sh;bash update.sh
```