# ==========================================================
# POLYDEV | Ubuntu Engineering
# UBU01 - Professional Ubuntu Installation
# ==========================================================
#
# TECNOLOGIA:
# Ubuntu Linux
#
# LINGUAGEM:
# Bash
#
# OBJETIVO:
# Este documento apresenta uma instalação profissional
# do Ubuntu utilizando boas práticas de administração.
#
# ATENÇÃO:
# Este conteúdo é destinado para estudo, consulta e
# reprodução controlada dos comandos apresentados.
#
# Leia • Entenda • Execute seu código
# ==========================================================

# ==========================================================
# ETAPA 01. Verificar versão do Ubuntu
# ==========================================================

lsb_release -a
cat /etc/os-release


# ==========================================================
# ETAPA 02. Atualizar repositórios
# ==========================================================

sudo apt update


# ==========================================================
# ETAPA 03. Atualizar pacotes instalados
# ==========================================================

sudo apt upgrade -y


# ==========================================================
# ETAPA 04. Instalar pacotes essenciais
# ==========================================================

sudo apt install -y curl wget vim git htop net-tools openssh-server


# ==========================================================
# ETAPA 05. Verificar rede
# ==========================================================

ip addr
ip route
ping -c 4 google.com


# ==========================================================
# ETAPA 06. Verificar serviço SSH
# ==========================================================

sudo systemctl status ssh


# ==========================================================
# ETAPA 07. Habilitar SSH no boot
# ==========================================================

sudo systemctl enable ssh