# ==========================================================
# POLYDEV | Ubuntu Engineering
# UBU15 - Sintonia Fina do Kernel e Performance (sysctl)
# ==========================================================
#
# TECNOLOGIA:
# Ubuntu Linux
#
# LINGUAGEM:
# Bash
#
# OBJETIVO:
# Este documento apresenta comandos para ajustar parâmetros
# profundos do kernel Linux em tempo real. O foco é otimizar
# a pilha de rede e gerenciamento de memória para suportar
# aplicações de altíssima concorrência (Backends e Bancos de Dados).
#
# ATENÇÃO:
# Ajustes de kernel alteram o comportamento crítico do SO.
# Altere apenas os parâmetros que você compreende totalmente.
# Valores incorretos podem comprometer a estabilidade do servidor.
#
# Leia • Entenda • Execute seu código
# ==========================================================

# ==========================================================
# ETAPA 01. Consultar o valor atual de um parâmetro
# ==========================================================
sysctl net.core.somaxconn

# ==========================================================
# ETAPA 02. Aumentar limite de conexões concorrentes (TCP)
# ==========================================================
sudo sysctl -w net.core.somaxconn=65535

# ==========================================================
# ETAPA 03. Otimizar buffers de rede (TCP R/W)
# ==========================================================
sudo sysctl -w net.ipv4.tcp_rmem="4096 87380 16777216"
sudo sysctl -w net.ipv4.tcp_wmem="4096 65536 16777216"

# ==========================================================
# ETAPA 04. Habilitar reutilização de sockets
# ==========================================================
sudo sysctl -w net.ipv4.tcp_tw_reuse=1

# ==========================================================
# ETAPA 05. Ajustar limite de descritores de arquivos
# ==========================================================
sudo sysctl -w fs.file-max=2097152

# ==========================================================
# ETAPA 06. Ajustar comportamento da Swap
# ==========================================================
sudo sysctl -w vm.swappiness=10

# ==========================================================
# ETAPA 07. Aplicar configurações de forma persistente
# ==========================================================
sudo sysctl -p /etc/sysctl.d/99-polydev-performance.conf

# ==========================================================
# ETAPA 08. Confirmar parâmetros aplicados
# ==========================================================
sysctl net.core.somaxconn
sysctl net.ipv4.tcp_tw_reuse
sysctl fs.file-max
sysctl vm.swappiness

# ==========================================================
# ETAPA 09. Exibir todos os parâmetros ativos
# ==========================================================
sysctl -a

# ==========================================================
# ETAPA 10. Confirmar arquivo de configuração
# ==========================================================
cat /etc/sysctl.d/99-polydev-performance.conf