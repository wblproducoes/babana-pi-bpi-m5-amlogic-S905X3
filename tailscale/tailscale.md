# Script de Gerenciamento do Tailscale para Banana Pi M5 e Ubuntu 24.04 - tailscale.sh

## Histórico de Atualizações

### 📝 **Versão 1.0** - Versão Inicial
**Prompt Original:**
na pasta tailscale crie um script em bash (com menu onde a opção 0 é de sair e/ou voltar) com o mesmo nome para funcionanr no banana pi m5 com arquitetura de aarch64 e no ubuntu 24.04 (noble) que instale e desistale (incluindo a pasta, mesmo que a mesma não esteja vazia) o tailscale e verifique o status do mesmo o ip do mesmo. Crie também um arquivo .md com o mesmo nome com a explicação e com esse prompt original. E no fina do arquivo crie "rm -rf arquivo.sh;nano arquivo.sh;chmod +x arquivo.sh;bash arquivo.sh" trocando arquivo pelo o nome de arquivo

---

## Descrição

Este script foi desenvolvido especificamente para o **Banana Pi M5** com arquitetura **aarch64** e **Ubuntu 24.04 (Noble)**. Ele oferece uma interface de menu interativa para gerenciar completamente o Tailscale, incluindo instalação, desinstalação, verificação de status e gerenciamento de conexões.

### Funcionalidades Principais

#### 1. **Instalação do Tailscale**
- Baixa e instala automaticamente o Tailscale usando o script oficial
- Verifica se já está instalado e oferece opção de reinstalação
- Habilita e inicia o serviço `tailscaled` automaticamente
- Atualiza a lista de pacotes antes da instalação
- Fornece instruções para conectar à rede Tailscale

#### 2. **Desinstalação Completa**
- Remove o pacote Tailscale do sistema
- Para e desabilita o serviço `tailscaled`
- Desconecta da rede Tailscale antes da remoção
- Oferece opção para remover configurações e dados:
  - `/var/lib/tailscale`
  - `/etc/tailscale`
  - `~/.config/tailscale`
  - Arquivos de serviço systemd
- Executa limpeza adicional com `autoremove` e `autoclean`
- Recarrega o daemon do systemd

#### 3. **Verificação de Status**
- Mostra o status do serviço `tailscaled`
- Exibe o status da conexão Tailscale
- Apresenta informações detalhadas sobre dispositivos conectados
- Mostra a versão instalada do Tailscale
- Indica se o serviço está rodando ou parado

#### 4. **Verificação de IP**
- Exibe o IP IPv4 da interface Tailscale
- Mostra o IP IPv6 quando disponível
- Apresenta informações da interface de rede `tailscale0`
- Verifica se o Tailscale está conectado antes de mostrar IPs
- Fornece instruções para conectar se necessário

#### 5. **Gerenciamento de Conexão**
- Permite conectar e desconectar da rede Tailscale
- Detecta automaticamente o status atual da conexão
- Oferece opções contextuais baseadas no estado atual
- Fornece instruções de autenticação durante a conexão
- Confirma operações antes de executá-las

### Menu Interativo

```
========================================
  MENU DO TAILSCALE MANAGER / TAILSCALE MANAGER MENU
  Banana Pi M5 & Ubuntu 24.04
========================================

1) Instalar Tailscale / Install Tailscale
2) Desinstalar Tailscale / Uninstall Tailscale
3) Verificar Status / Check Status
4) Verificar IP / Check IP
5) Conectar/Desconectar / Connect/Disconnect
0) Sair / Exit

========================================
```

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

### Compatibilidade

- **Sistema Operacional**: Ubuntu 24.04 (Noble)
- **Arquitetura**: aarch64 (ARM64)
- **Hardware**: Otimizado para Banana Pi M5
- **Privilégios**: Requer execução como root (sudo)

### Uso

1. Execute o script com privilégios de root:
   ```bash
   sudo bash tailscale.sh
   ```

2. Use o menu interativo para navegar pelas opções

3. A opção 0 sempre retorna ao menu principal ou sai do script

### Notas Importantes

- **Backup**: Recomenda-se fazer backup das configurações antes da desinstalação
- **Conectividade**: Certifique-se de ter conexão com a internet para instalação
- **Autenticação**: Durante a primeira conexão, será necessário autenticar via navegador
- **Firewall**: O Tailscale gerencia automaticamente as regras de firewall necessárias

### Avisos de Segurança

- Execute apenas em sistemas confiáveis
- Verifique a integridade do script antes da execução
- Mantenha o Tailscale atualizado para correções de segurança
- Use senhas fortes para sua conta Tailscale

### Dicas de Uso

- Use `tailscale status` para verificar dispositivos conectados
- Configure ACLs (Access Control Lists) no painel web do Tailscale
- Considere usar subnets para roteamento avançado
- Monitore logs em `/var/log/tailscaled.log` se necessário

### Troubleshooting

#### Problemas Comuns:

1. **Erro de permissão**: Execute com `sudo`
2. **Falha na instalação**: Verifique conexão com internet
3. **Serviço não inicia**: Verifique logs com `journalctl -u tailscaled`
4. **Não consegue conectar**: Verifique firewall e configurações de rede

#### Logs Úteis:
```bash
# Status do serviço
sudo systemctl status tailscaled

# Logs do serviço
sudo journalctl -u tailscaled -f

# Status detalhado
sudo tailscale status --self=false
```

---

## Comandos para Gerenciar o Arquivo

```bash
rm -rf tailscale.sh;nano tailscale.sh;chmod +x tailscale.sh;bash tailscale.sh
```