# ==========================================================
# POLYDEV | Ubuntu Engineering
# UBU07 - Cron and Job Scheduling
# ==========================================================
#
# TECNOLOGIA:
# Ubuntu Linux
#
# LINGUAGEM:
# Bash
#
# OBJETIVO:
# Este documento apresenta o agendamento de tarefas
# automatizadas utilizando cron no Ubuntu Linux.
#
# ATENÇÃO:
# O cron é amplamente utilizado para automação de rotinas,
# backups, monitoramento e manutenção de servidores.
#
# Leia • Entenda • Execute seu código
# ==========================================================

# ==========================================================
# ETAPA 01. Verificar serviço cron
# ==========================================================
systemctl status cron

# ==========================================================
# ETAPA 02. Iniciar serviço cron
# ==========================================================
sudo systemctl start cron

# ==========================================================
# ETAPA 03. Habilitar cron no boot
# ==========================================================
sudo systemctl enable cron

# ==========================================================
# ETAPA 04. Editar agenda do usuário atual
# ==========================================================
crontab -e

# ==========================================================
# ETAPA 05. Listar tarefas agendadas
# ==========================================================
crontab -l

# ==========================================================
# ETAPA 06. Remover agenda do usuário
# ==========================================================
crontab -r

# ==========================================================
# ETAPA 07. Executar script diariamente às 02:00
# ==========================================================
0 2 * * * /home/usuario/scripts/backup.sh

# ==========================================================
# ETAPA 08. Executar script a cada hora
# ==========================================================
0 * * * * /home/usuario/scripts/monitor.sh

# ==========================================================
# ETAPA 09. Executar script a cada 15 minutos
# ==========================================================
*/15 * * * * /home/usuario/scripts/coleta.sh

# ==========================================================
# ETAPA 10. Executar script toda segunda-feira
# ==========================================================
0 8 * * 1 /home/usuario/scripts/semanal.sh

# ==========================================================
# ETAPA 11. Utilizar diretório cron.daily
# ==========================================================
ls /etc/cron.daily

# ==========================================================
# ETAPA 12. Utilizar diretório cron.weekly
# ==========================================================
ls /etc/cron.weekly

# ==========================================================
# ETAPA 13. Utilizar diretório cron.monthly
# ==========================================================
ls /etc/cron.monthly

# ==========================================================
# ETAPA 14. Consultar logs do cron
# ==========================================================
grep CRON /var/log/syslog

# ==========================================================
# ETAPA 15. Verificar execução de tarefas
# ==========================================================
tail -f /var/log/syslog

# ==========================================================
# ETAPA 16. Testar saída para arquivo de log
# ==========================================================
*/5 * * * * /home/usuario/scripts/teste.sh >> /tmp/teste.log 2>&1

# ==========================================================
# ETAPA 17. Executar comando no reboot
# ==========================================================
@reboot /home/usuario/scripts/startup.sh

# ==========================================================
# ETAPA 18. Verificar sintaxe do crontab
# ==========================================================
man 5 crontab

# ==========================================================
# ETAPA 19. Editar crontab de outro usuário
# ==========================================================
sudo crontab -u usuario01 -e

# ==========================================================
# ETAPA 20. Revisar tarefas agendadas
# ==========================================================
crontab -l
