#!/bin/bash
# ==========================================================
# POLYDEV | Kali Engineering
# KAL04 - Snapshots, Backup e Restauração de Ambientes
# ==========================================================
#
# TECNOLOGIA:
# Kali Linux / Oracle VirtualBox
#
# LINGUAGEM:
# Bash
#
# OBJETIVO:
# Este documento apresenta comandos críticos para preservação
# e recuperação de estados em laboratórios de segurança.
# Abrange snapshots de máquinas virtuais, compactação de
# diretórios e clonagem bit-a-bit para análise forense.
#
# ATENÇÃO:
# A restauração de um snapshot destrói irreversivelmente
# todos os dados gerados após a data daquele snapshot.
# Nunca restaure um snapshot em uma máquina de produção.
#
# Leia • Entenda • Execute seu código
# ==========================================================

# ==========================================================
# ETAPA 01. Criar Snapshot de Segurança (Pré-Exploração)
# ==========================================================
# Utiliza o VBoxManage via terminal para criar um ponto de restauração
# Substitua "Kali-Polydev" pelo nome exato da sua VM no VirtualBox
VBoxManage snapshot "Kali-Polydev" take "pre_exploit_clean" --description "Estado limpo antes do Pentest"

# ==========================================================
# ETAPA 02. Listar Snapshots Disponíveis
# ==========================================================
# Verifica todos os pontos de restauração existentes para a VM
VBoxManage snapshot "Kali-Polydev" list

# ==========================================================
# ETAPA 03. Restaurar Snapshot (Rollback)
# ==========================================================
# Retorna a máquina virtual exatamente para o estado salvo na ETAPA 01
# A VM deve estar desligada para executar este comando com sucesso
VBoxManage snapshot "Kali-Polydev" restore "pre_exploit_clean"

# ==========================================================
# ETAPA 04. Backup de Diretórios de Trabalho (Tarball)
# ==========================================================
# Compacta um diretório preservando permissões (-p), donos e timestamps
# Ideal para salvar logs, proof-of-concepts (PoC) e configurações customizadas
tar -czpf /mnt/disco_externo/polydev_backup_$(date +%F_%H-%M).tar.gz /root/polydev_workspace

# ==========================================================
# ETAPA 05. Backup de Banco de Dados Local (Metasploit/Postgres)
# ==========================================================
# Gera um arquivo SQL puro do banco de dados do Metasploit Framework
# Útil para não perder credenciais obtidas e tabelas de hosts mapeados
sudo pg_dump -U msf metasploit > /mnt/disco_externo/msf_db_backup_$(date +%F).sql

# ==========================================================
# ETAPA 06. Restauração de Arquivos Compactados
# ==========================================================
# Extrai o backup do Tarball para o diretório original ou um novo alvo
# O parâmetro -C permite especificar onde os arquivos serão extraídos
tar -xzpf /mnt/disco_externo/polydev_backup_2023-10-25_14-30.tar.gz -C /root/

# ==========================================================
# ETAPA 07. Clonagem Bit-a-Bit para Análise Forense (dd)
# ==========================================================
# O comando dd cria uma imagem exata (byte a byte) de um dispositivo ou partição
# ATENÇÃO EXTREMA: Não inverta os valores de "if" (input) e "of" (output)
# Exemplo: Clonar um pendrive suspeito (/dev/sdb) para um arquivo de imagem
# sudo dd if=/dev/sdb of=/mnt/disco_externo/evidencia_forense.img bs=4M status=progress