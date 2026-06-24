# ==========================================================
# POLYDEV | Ubuntu Engineering
# UBU02 - Linux Directory Structure
# ==========================================================
#
# TECNOLOGIA:
# Ubuntu Linux
#
# LINGUAGEM:
# Bash
#
# OBJETIVO:
# Este documento apresenta a estrutura padrão de diretórios
# do Linux e sua finalidade dentro do sistema operacional.
#
# ATENÇÃO:
# Antes de administrar um servidor Linux é fundamental
# compreender a função de cada diretório principal.

#
# Leia • Entenda • Execute seu código
# ==========================================================

# ==========================================================
# ETAPA 01. Identificar diretório atual
# ==========================================================
pwd

# ==========================================================
# ETAPA 02. Listar diretórios da raiz
# ==========================================================

ls /

# ==========================================================
# ETAPA 03. Conhecer o diretório /home
# ==========================================================
# Armazena arquivos dos usuários

ls /home

# ==========================================================
# ETAPA 04. Conhecer o diretório /etc
# ==========================================================
# Contém arquivos de configuração do sistema

ls /etc

# ==========================================================
# ETAPA 05. Conhecer o diretório /var
# ==========================================================
# Contém logs, filas e dados variáveis

ls /var

# ==========================================================
# ETAPA 06. Conhecer o diretório /tmp
# ==========================================================
# Arquivos temporários

ls /tmp

# ==========================================================
# ETAPA 07. Conhecer o diretório /usr
# ==========================================================
#  Aplicações, bibliotecas e utilitários do sistema

ls /usr

# ==========================================================
# ETAPA 08. Conhecer o diretório /bin
# ==========================================================
# Comandos essenciais do sistema

ls /bin

# ==========================================================
# ETAPA 09. Conhecer o diretório /opt
# ==========================================================
# Aplicações opcionais instaladas manualmente

ls /opt

# ==========================================================
# ETAPA 10. Visualizar estrutura completa
# ==========================================================

tree / -L 2

# Caso o comando tree não esteja instalado:

sudo apt install tree -y
