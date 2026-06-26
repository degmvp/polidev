#!/bin/bash
# ==========================================================
# POLYDEV | Kali Engineering
# KAL02 - Análise de Vulnerabilidades Web
# ==========================================================
#
# TECNOLOGIA:
# Kali Linux
#
# LINGUAGEM:
# Bash
#
# OBJETIVO:
# Este documento apresenta comandos para identificar falhas
# de segurança em aplicações web. O foco é descobrir
# tecnologias ocultas, diretórios sensíveis e
# vulnerabilidades conhecidas em servidores expostos.
#
# ATENÇÃO:
# Ferramentas de escaneamento web geram muito tráfego e
# ruído em logs (WAF/IDS). Execute apenas em ambientes
# de laboratório ou com autorização explícita de pentest.
#
# Leia • Entenda • Execute seu código
# ==========================================================

# ==========================================================
# ETAPA 01. Identificação de Tecnologias (Fingerprinting)
# ==========================================================
# Descobre CMS, frameworks, servidores web e plugins ativos
whatweb -v http://192.168.1.105

# ==========================================================
# ETAPA 02. Escaneamento Geral de Vulnerabilidades (Nikto)
# ==========================================================
# Verifica configurações inseguras, arquivos antigos e falhas conhecidas
# O parâmetro -Tuning 1 foca em itens interessantes, reduzindo o ruído
nikto -h http://192.168.1.105 -Tuning 1

# ==========================================================
# ETAPA 03. Descoberta de Diretórios e Arquivos Ocultos
# ==========================================================
# Utiliza o Gobuster para forçar bruto e encontrar rotas não mapeadas
# Requer um dicionário (Kali já vem com o /usr/share/wordlists/dirb/common.txt)
gobuster dir -u http://192.168.1.105 -w /usr/share/wordlists/dirb/common.txt -x .php,.txt,.bak

# ==========================================================
# ETAPA 04. Escaneamento Específico para WordPress (WPScan)
# ==========================================================
# Se a ETAPA 01 identificar WordPress, use o WPScan para enumeração
# -e ap: Enumera plugins vulneráveis
# -e u: Enumera usuários
wpscan --url http://192.168.1.105/wordpress -e ap,u

# ==========================================================
# ETAPA 05. Teste de Segurança de Cabeçalhos HTTP
# ==========================================================
# Verifica a existência de cabeçalhos de segurança (X-Frame-Options, CSP, etc)
curl -sI http://192.168.1.105 | grep -i "strict-transport\|x-frame\|x-content-type\|content-security-policy"

# ==========================================================
# ETAPA 06. Interceptação Rápida de Requisições (cURL POST)
# ==========================================================
# Simula o envio de dados para testar endpoints de login contra injeção básica
curl -X POST http://192.168.1.105/login.php -d "user=admin'&pass=test"

# ==========================================================
# ETAPA 07. Exportar resultados para análise posterior
# ==========================================================
# Salva o relatório do Nikto em formato HTML para revisão no navegador
nikto -h http://192.168.1.105 -o /root/polydev_nikto_report.html -Format htm