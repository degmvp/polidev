# ==========================================================
# POLYDEV | Ubuntu Engineering
# UBU06 - Services Management with systemd
# ==========================================================
#
# TECNOLOGIA:
# Ubuntu Linux
#
# LINGUAGEM:
# Bash
#
# OBJETIVO:
# Este documento apresenta os principais comandos para
# gerenciamento de serviços utilizando systemd no Ubuntu.
#
# ATENÇÃO:
# O systemd é o gerenciador de serviços padrão das
# distribuições Linux modernas.
#
# Leia • Entenda • Execute seu código
# ==========================================================

# ==========================================================
# ETAPA 01. Verificar status de um serviço
# ==========================================================
systemctl status ssh

# ==========================================================
# ETAPA 02. Listar serviços ativos
# ==========================================================
systemctl list-units --type=service --state=running

# ==========================================================
# ETAPA 03. Iniciar um serviço
# ==========================================================
sudo systemctl start ssh

# ==========================================================
# ETAPA 04. Parar um serviço
# ==========================================================
sudo systemctl stop ssh

# ==========================================================
# ETAPA 05. Reiniciar um serviço
# ==========================================================
sudo systemctl restart ssh

# ==========================================================
# ETAPA 06. Recarregar configuração de um serviço
# ==========================================================
sudo systemctl reload ssh

# ==========================================================
# ETAPA 07. Habilitar serviço no boot
# ==========================================================
sudo systemctl enable ssh

# ==========================================================
# ETAPA 08. Desabilitar serviço no boot
# ==========================================================
sudo systemctl disable ssh

# ==========================================================
# ETAPA 09. Verificar se serviço está habilitado
# ==========================================================
systemctl is-enabled ssh

# ==========================================================
# ETAPA 10. Verificar se serviço está ativo
# ==========================================================
systemctl is-active ssh

# ==========================================================
# ETAPA 11. Exibir dependências de um serviço
# ==========================================================
systemctl list-dependencies ssh

# ==========================================================
# ETAPA 12. Exibir informações detalhadas
# ==========================================================
systemctl show ssh

# ==========================================================
# ETAPA 13. Consultar logs do serviço
# ==========================================================
journalctl -u ssh

# ==========================================================
# ETAPA 14. Consultar logs em tempo real
# ==========================================================
journalctl -fu ssh

# ==========================================================
# ETAPA 15. Recarregar configurações do systemd
# ==========================================================
sudo systemctl daemon-reload

# ==========================================================
# ETAPA 16. Listar serviços instalados
# ==========================================================
systemctl list-unit-files --type=service

# ==========================================================
# ETAPA 17. Verificar falhas em serviços
# ==========================================================
systemctl --failed

# ==========================================================
# ETAPA 18. Exibir tempo de inicialização
# ==========================================================
systemd-analyze

# ==========================================================
# ETAPA 19. Exibir serviços mais lentos no boot
# ==========================================================
systemd-analyze blame

# ==========================================================
# ETAPA 20. Verificar árvore de dependências do sistema
# ==========================================================
systemd-analyze critical-chain
