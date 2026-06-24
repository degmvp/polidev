# ==========================================================
# POLYDEV | Ubuntu Engineering
# UBU03 - Users and Groups
# ==========================================================
#
# TECNOLOGIA:
# Ubuntu Linux
#
# LINGUAGEM:
# Bash
#
# OBJETIVO:
# Este documento apresenta o gerenciamento de usuários
# e grupos no Ubuntu Linux utilizando comandos nativos.
#
# ATENÇÃO:
# O controle adequado de usuários e grupos é fundamental
# para a segurança e administração do sistema.
#
# Leia • Entenda • Execute seu código
# ==========================================================

# ==========================================================
# ETAPA 01. Identificar usuário atual
# ==========================================================
whoami

# ==========================================================
# ETAPA 02. Exibir informações do usuário atual
# ==========================================================
id

# ==========================================================
# ETAPA 03. Listar usuários do sistema
# ==========================================================
cat /etc/passwd

# ==========================================================
# ETAPA 04. Listar grupos do sistema
# ==========================================================
cat /etc/group

# ==========================================================
# ETAPA 05. Criar um novo usuário
# ==========================================================
sudo adduser usuario01

# ==========================================================
# ETAPA 06. Criar um novo grupo
# ==========================================================
sudo groupadd desenvolvedores

# ==========================================================
# ETAPA 07. Adicionar usuário ao grupo
# ==========================================================
sudo usermod -aG desenvolvedores usuario01

# ==========================================================
# ETAPA 08. Verificar grupos de um usuário
# ==========================================================
groups usuario01

# ==========================================================
# ETAPA 09. Bloquear uma conta de usuário
# ==========================================================
sudo passwd -l usuario01

# ==========================================================
# ETAPA 10. Remover usuário
# ==========================================================
sudo deluser usuario01

# ==========================================================
# ETAPA 11. Remover grupo
# ==========================================================
sudo groupdel desenvolvedores

# ==========================================================
# ETAPA 12. Verificar usuários conectados
# ==========================================================
who

# ==========================================================
# ETAPA 13. Exibir histórico de logins
# ==========================================================
last
