# ==========================================================
# POLYDEV | Ubuntu Engineering
# UBU14 - Rastreamento de Processos e Troubleshooting
# ==========================================================
#
# TECNOLOGIA:
# Ubuntu Linux
#
# LINGUAGEM:
# Bash
#
# OBJETIVO:
# Este documento apresenta comandos avançados para análise
# profunda de processos. Foca em rastrear chamadas de sistema
# (syscalls) e sinais do sistema operacional para identificar
# gargalos de I/O, deadlocks e falhas silenciosas em código
# compilado ou interpretado.
#
# ATENÇÃO:
# Ferramentas como strace geram um volume massivo de dados
# em milissegundos. Utilize os filtros (-e) para isolar
# exatamente o comportamento que você está investigando.
#
# Leia • Entenda • Execute seu código
# ==========================================================

# ==========================================================
# ETAPA 01. Monitorar chamadas de sistema em tempo real
# ==========================================================
sudo strace -p 1234

# ==========================================================
# ETAPA 02. Rastrear apenas operações de Rede (I/O)
# ==========================================================
sudo strace -p 1234 -e trace=network

# ==========================================================
# ETAPA 03. Rastrear interações com o Sistema de Arquivos
# ==========================================================
sudo strace -p 1234 -e trace=file

# ==========================================================
# ETAPA 04. Rastrear desde o início e salvar em log
# ==========================================================
sudo strace -o /tmp/polydev_trace.log ./meu_programa_em_c

# ==========================================================
# ETAPA 05. Analisar o consumo de memória em detalhes
# ==========================================================
sudo pmap -x 1234

# ==========================================================
# ETAPA 06. Inspecionar descritores de arquivos abertos
# ==========================================================
sudo lsof -p 1234

# ==========================================================
# ETAPA 07. Capturar sinais do sistema operacional
# ==========================================================
sudo strace -p 1234 -e trace=signal

# ==========================================================
# ETAPA 08. Verificar bibliotecas carregadas pelo processo
# ==========================================================
sudo ldd ./meu_programa_em_c

# ==========================================================
# ETAPA 09. Monitorar consumo em tempo real
# ==========================================================
top -p 1234

# ==========================================================
# ETAPA 10. Revisar arquivo de rastreamento gerado
# ==========================================================
less /tmp/polydev_trace.log