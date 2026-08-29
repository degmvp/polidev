#!/bin/bash
# ==========================================================
# POLYDEV | Kali Engineering
# KAL05 - Monitoramento, Logs e Auditoria de Segurança
# ==========================================================
#
# TECNOLOGIA:
# Kali Linux
#
# LINGUAGEM:
# Bash
#
# OBJETIVO:
# Este documento apresenta comandos e configurações para
# monitorar o ambiente, registrar eventos críticos e
# construir uma trilha de auditoria robusta, permitindo
# a identificação de indícios de comprometimento (IOC).
#
# ATENÇÃO:
# Alterar configurações de logs do sistema (rsyslog/journald)
# pode afetar o desempenho se não houver controle de rotação.
# Em ambientes de produção, envie os logs para um servidor
# centralizado (Syslog/ELK) para evitar adulteração local.
#
# Leia • Entenda • Execute seu código
# ==========================================================

# ==========================================================
# ETAPA 01. Centralização e Leitura de Logs do Sistema
# ==========================================================
# O journalctl lida com os logs do systemd (estruturados e centralizados)
# -f: Segue os logs em tempo real (equivalente ao tail -f)
# -p err: Filtra apenas eventos de nível de erro (críticos para auditoria)
sudo journalctl -f -p err

# ==========================================================
# ETAPA 02. Auditoria de Autenticações e Acessos
# ==========================================================
# Monitora tentativas de login, falhas de senha e sessões abertas em tempo real
sudo tail -f /var/log/auth.log

# Lista as sessões atuais no momento (quem está logado, de onde e o que está rodando)
w

# ==========================================================
# ETAPA 03. Auditoria de Execução de Comandos (PROMPT_COMMAND)
# ==========================================================
# Estratégia avançada: Força o bash a logar TODOS os comandos digitados no terminal
# Adicione a linha abaixo no final do arquivo ~/.bashrc do usuário auditado
echo 'export PROMPT_COMMAND='"'"'RETRN_VAL=$?; logger -p local6.debug "$(whoami) [$$]: $(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//" ) [$RETRN_VAL]"'"'"'' >> ~/.bashrc

# Configura o rsyslog para direcionar esses comandos para um arquivo exclusivo
echo "local6.* /var/log/polydev_command_audit.log" | sudo tee -a /etc/rsyslog.d/50-polydev.conf

# Aplica a configuração do rsyslog
sudo systemctl restart rsyslog

# ==========================================================
# ETAPA 04. Monitoramento de Rede em Tempo Real
# ==========================================================
# O tcpdump captura pacotes na placa de rede
# -i any: Escuta em todas as interfaces
# -w: Salva a captura em formato pcap (para leitura posterior no Wireshark)
sudo tcpdump -i any -w /tmp/captura_suspeita.pcap

# ==========================================================
# ETAPA 05. Rastreamento de Arquivos e Diretórios Críticos
# ==========================================================
# O inotifywait monitora alterações em tempo real (criação, leitura, escrita, deleção)
# Instalação prévia necessária: sudo apt install inotify-tools
# Exemplo: Monitorando o diretório /etc para detectar adulteração de configurações
sudo inotifywait -m -r -e modify,create,delete /etc/

# ==========================================================
# ETAPA 06. Verificação de Integridade de Arquivos (AIDE)
# ==========================================================
# O AIDE cria um "banco de dados" de hashes dos arquivos críticos do sistema
# Inicializa a base de dados limpa (execute isso em um ambiente confiável)
sudo aideinit

# Verifica o sistema atual contra a base de dados para encontrar arquivos alterados
# Se um atacante modificou um binário do sistema, o AIDE irá flagar aqui
sudo aide --check

# ==========================================================
# ETAPA 07. Auditoria de Chamadas de Sistema no Nível do Kernel
# ==========================================================
# O auditd monitora syscalls no nível do kernel (impossível de o usuário comum burlar)
# Cria uma regra para monitorar qualquer tentativa de leitura no arquivo /etc/shadow
sudo auditctl -w /etc/shadow -p r -k shadow_access_read

# Lista as regras de auditoria ativas no momento
sudo auditctl -l

# Visualiza os logs de segurança gerados pelo auditd
sudo ausearch -k shadow_access_read