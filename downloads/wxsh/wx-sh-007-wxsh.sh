#!/bin/bash
# ==========================================================
# POLYDEV | Kali Engineering
# KAL06 - Análise de Tráfego e Captura de Pacotes
# ==========================================================
#
# TECNOLOGIA:
# Kali Linux
#
# LINGUAGEM:
# Bash
#
# OBJETIVO:
# Este documento apresenta comandos para captura e filtragem
# de pacotes no nível da placa de rede (Layer 2/3). O foco é
# utilizar o tcpdump para isolar comportamentos anômalos e
# gerar arquivos pcap para investigação forense detalhada.
#
# ATENÇÃO:
# Em redes corporativas, a captura de tráfego de terceiros
# sem autorização é ilegal. Aplique estas técnicas apenas
# em tráfego gerado por você ou em laboratórios controlados.
#
# Leia • Entenda • Execute seu código
# ==========================================================

# ==========================================================
# ETAPA 01. Descoberta de Interfaces de Captura
# ==========================================================
# Lista todas as interfaces disponíveis para captura (incluindo modo monitor)
# Identifique qual interface você vai usar (ex: eth0, wlan0)
tcpdump -D

# ==========================================================
# ETAPA 02. Captura Básica em Tempo Real
# ==========================================================
# Captura pacotes na interface eth0 em formato hexadecimal e ASCII (-X)
# Ideal para ver exatamente o que está sendo enviado em requisições simples
# Use CTRL+C para parar a captura
sudo tcpdump -i eth0 -X -c 10

# ==========================================================
# ETAPA 03. Filtro por Host Específico (Origem e Destino)
# ==========================================================
# Isola todo o tráfego que tem como origem OU destino o IP alvo
sudo tcpdump -i eth0 host 192.168.1.105

# ==========================================================
# ETAPA 04. Filtro por Porta e Protocolo
# ==========================================================
# Captura apenas tráfego TCP na porta 80 (HTTP) ou 443 (HTTPS)
# Útil para analisar comunicação web sem o ruído de DNS ou SSH
sudo tcpdump -i eth0 tcp port 80

# ==========================================================
# ETAPA 05. Filtro Avançado por Comportamento (Flags TCP)
# ==========================================================
# Captura apenas pacotes TCP que têm as flags SYN e ACK ativadas
# Isso isola tentativas de conexão que estão sendo aceitas pelo servidor
sudo tcpdump -i eth0 'tcp[tcpflags] & (tcp-syn) != 0 and (tcp[tcpflags] & (tcp-ack) != 0)'

# ==========================================================
# ETAPA 06. Captura Silenciosa (Sem Resolução de Nomes)
# ==========================================================
# O parâmetro -n impede o tcpdump de tentar resolver IPs para nomes DNS
# O parâmetro -nn impede a resolução de portas para nomes de serviço
# ESTRATÉGIA: Isso torna a captura instantânea, essencial em redes rápidas ou sob ataque
sudo tcpdump -i eth0 -nn -s 0 -w /tmp/investigacao_poli.pcap

# ==========================================================
# ETAPA 07. Leitura Pós-Captura e Extração de Payload
# ==========================================================
# Lê o arquivo pcap gerado na ETAPA 06
# -A: Imprime o payload (conteúdo) dos pacotes em ASCII
# 'http': Filtra apenas o conteúdo do protocolo HTTP (mostra senhas, cookies, GET/POST)
sudo tcpdump -r /tmp/investigacao_poli.pcap -A 'http'