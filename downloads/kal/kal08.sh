#!/bin/bash
# ==========================================================
# POLYDEV | Kali Engineering
# KAL08 - Automação de Segurança com Bash
# ==========================================================
#
# TECNOLOGIA:
# Kali Linux
#
# LINGUAGEM:
# Bash
#
# OBJETIVO:
# Este documento demonstra como estruturar scripts Shell
# para automatizar tarefas repetitivas de auditoria e
# hardening. Foca em boas práticas de programação:
# validação de raiz, tratamento de erros e modularização.
#
# ATENÇÃO:
# Scripts de automação de segurança possuem grande poder
# de destruição se mal configurados. Sempre teste as
# funções em ambientes isolados antes de aplicar em
# infraestruturas reais de produção.
#
# Leia • Entenda • Execute seu código
# ==========================================================

# ==========================================================
# ETAPA 01. Configuração Rígida do Script (Hardening do Bash)
# ==========================================================
# -e: Sai imediatamente se qualquer comando falhar (Não continua executando cego)
# -u: Encerra o script se tentar usar uma variável não declarada (Previne falhas de lógica)
# -o pipefail: O pipe falha se qualquer comando dentro dele falhar (e não apenas o último)
set -euo pipefail

# ==========================================================
# ETAPA 02. Validação de Privilégios e Variáveis
# ==========================================================
# Verifica se o script está sendo executado como root
if [[ "${EUID}" -ne 0 ]]; then
    echo "[ERRO] Este script de auditoria requer privilégios de root." >&2
    exit 1
fi

# Variáveis de ambiente seguras (Sem espaços, caminhos absolutos)
readonly AUDIT_DIR="/var/log/polydev_audit"
readonly TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
readonly LOG_FILE="${AUDIT_DIR}/audit_${TIMESTAMP}.log"

# ==========================================================
# ETAPA 03. Criação Segura de Diretório de Saída
# ==========================================================
# Cria o diretório com permissões restritas (Apenas root pode ler/escrever)
mkdir -p "${AUDIT_DIR}"
chmod 700 "${AUDIT_DIR}"

# ==========================================================
# ETAPA 04. Modularização com Funções (Separação de Responsabilidades)
# ==========================================================
# Função para auditar usuários com UID 0 (Roots ocultos)
check_root_users() {
    echo "[*] Verificando contas com privilégios de root..." | tee -a "${LOG_FILE}"
    # AWK filtra a primeira coluna (usuário) onde a terceira coluna (UID) é 0
    awk -F: '$3 == 0 {print $1}' /etc/passwd | tee -a "${LOG_FILE}"
}

# Função para auditar permissões SUID perigosas
check_suid_files() {
    echo -e "\n[*] Verificando arquivos com SUID ativo..." | tee -a "${LOG_FILE}"
    # Redireciona erros (stderr) para /dev/null para limpar o output
    find / -perm -4000 -type f 2>/dev/null | tee -a "${LOG_FILE}"
}

# ==========================================================
# ETAPA 05. Tratamento de Sinais (Trap Signals)
# ==========================================================
# Garante que, mesmo que o usuário pressione CTRL+C, os arquivos
# temporários sejam apagados e o log seja finalizado com uma linha de status
cleanup() {
    local exit_code=$?
    echo -e "\n[!] Script interrompido pelo usuário (Sinal SIGINT)." | tee -a "${LOG_FILE}"
    echo "[*] Execução encerrada com código de saída: ${exit_code}" | tee -a "${LOG_FILE}"
    exit ${exit_code}
}

# Associa a função cleanup ao sinal SIGINT (CTRL+C)
trap cleanup SIGINT

# ==========================================================
# ETAPA 06. Execução da Rotina de Automação
# ==========================================================
echo "==================================================" | tee -a "${LOG_FILE}"
echo "POLYDEV Security Audit - Início: ${TIMESTAMP}"     | tee -a "${LOG_FILE}"
echo "==================================================" | tee -a "${LOG_FILE}"

# Chamada das funções modularizadas
check_root_users
check_suid_files

# ==========================================================
# ETAPA 07. Finalização e Assinatura do Log
# ==========================================================
echo -e "\n==================================================" | tee -a "${LOG_FILE}"
echo "Auditoria concluída com sucesso." | tee -a "${LOG_FILE}"
# Gera hash do próprio log para garantir que ele não seja alterado posteriormente
echo "Assinatura SHA256 do log gerado:" | tee -a "${LOG_FILE}"
sha256sum "${LOG_FILE}" | tee -a "${LOG_FILE}"
echo "==================================================" | tee -a "${LOG_FILE}"