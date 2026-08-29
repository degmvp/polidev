# ==========================================================
# POLYDEV | Ubuntu Engineering
# UBU11 - Gerenciamento de Rede e Resolução DNS
# ==========================================================
#
# TECNOLOGIA:
# Ubuntu Linux
#
# LINGUAGEM:
# Bash
#
# OBJETIVO:
# Este documento apresenta os comandos essenciais para
# configuração, análise e troubleshoot de rede utilizando
# o padrão moderno do Ubuntu (Netplan) e resolução DNS.
#
# ATENÇÃO:
# Alterações na rede podem derrubar conexões remotas (SSH).
# Sempre teste localmente ou garanta acesso via console (KVM)
# antes de aplicar mudanças em servidores de produção.
#
# Leia • Entenda • Execute seu código
# ==========================================================

# ==========================================================
# ETAPA 01. Identificar interfaces de rede e IPs atuais
# ==========================================================
ip a

# ==========================================================
# ETAPA 02. Verificar arquivos de configuração do Netplan
# ==========================================================
ls /etc/netplan/

# ==========================================================
# ETAPA 03. Aplicar configuração de IP Estático via Netplan
# ==========================================================
# Cria um arquivo de configuração seguro para a interface eth0
sudo bash -c 'cat <<EOF > /etc/netplan/01-polydev-static.yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 192.168.1.100/24
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
EOF'

# Aplica a configuração
sudo netplan apply

# Confirmar configuração aplicada
ip a
ip route

# ==========================================================
# ETAPA 04. Analisar tabela de roteamento
# ==========================================================
ip route

# ==========================================================
# ETAPA 05. Verificar status da resolução de nomes (DNS)
# ==========================================================
resolvectl status

# ==========================================================
# ETAPA 06. Testar conectividade e rota de pacotes
# ==========================================================
# Teste de latência
ping -c 4 8.8.8.8

# Rastreamento da rota
tracepath 8.8.8.8

# ==========================================================
# ETAPA 07. Analisar portas e conexões ativas
# ==========================================================
ss -tulnp

# ==========================================================
# ETAPA 08. Verificar interfaces em modo resumido
# ==========================================================
ip -br addr

# ==========================================================
# ETAPA 09. Consultar servidores DNS configurados
# ==========================================================
cat /etc/resolv.conf

# ==========================================================
# ETAPA 10. Testar resolução de nomes
# ==========================================================
ping -c 4 google.com

# ==========================================================
# ETAPA 11. Confirmar configuração final da rede
# ==========================================================
hostname -I
ip route
resolvectl status