# ==========================================================
# POLYDEV | Ubuntu Engineering
# UBU12 - Hardening de Rede com Firewall (UFW)
# ==========================================================
#
# TECNOLOGIA:
# Ubuntu Linux
#
# LINGUAGEM:
# Bash
#
# OBJETIVO:
# Este documento apresenta os comandos para implementação
# de segurança de perímetro utilizando o UFW (Uncomplicated
# Firewall), bloqueando acessos indevidos à rede.
#
# ATENÇÃO:
# Nunca ative um firewall sem antes garantir que a porta
# do seu serviço de acesso remoto (SSH) está liberada,
# caso contrário, você perderá o acesso ao servidor.
#
# Leia • Entenda • Execute seu código
# ==========================================================

# ==========================================================
# ETAPA 01. Verificar status atual do firewall
# ==========================================================
sudo ufw status verbose

# ==========================================================
# ETAPA 02. Definir políticas padrão de bloqueio
# ==========================================================
# Bloqueia todo tráfego de entrada que não seja explicitamente liberado
sudo ufw default deny incoming

# Permite todo tráfego de saída do servidor
sudo ufw default allow outgoing

# ==========================================================
# ETAPA 03. Liberar portas essenciais de administração
# ==========================================================
# Libera o serviço SSH (Porta 22)
sudo ufw allow OpenSSH

# ==========================================================
# ETAPA 04. Liberar portas de aplicações (Web / APIs)
# ==========================================================
# Libera HTTP (80) e HTTPS (443)
sudo ufw allow 'Nginx Full'

# ==========================================================
# ETAPA 05. Restringir acesso por endereço IP específico
# ==========================================================
# Libera PostgreSQL apenas para um IP autorizado
sudo ufw allow from 192.168.1.50 to any port 5432

# ==========================================================
# ETAPA 06. Habilitar o firewall
# ==========================================================
sudo ufw enable

# ==========================================================
# ETAPA 07. Validar regras aplicadas
# ==========================================================
sudo ufw status numbered

# ==========================================================
# ETAPA 08. Verificar portas liberadas
# ==========================================================
sudo ufw status verbose

# ==========================================================
# ETAPA 09. Excluir uma regra pelo número
# ==========================================================
sudo ufw delete NUMERO_DA_REGRA

# ==========================================================
# ETAPA 10. Desabilitar temporariamente o firewall
# ==========================================================
sudo ufw disable

# ==========================================================
# ETAPA 11. Reabilitar o firewall
# ==========================================================
sudo ufw enable

# ==========================================================
# ETAPA 12. Confirmar configuração final
# ==========================================================
sudo ufw status verbose