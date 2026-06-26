# ==========================================================
# POLYDEV | Kali Engineering
# KAL01 - Reconhecimento Passivo e Ativo de Rede
# ==========================================================
#
# TECNOLOGIA:
# Kali Linux
#
# LINGUAGEM:
# Bash
#
# OBJETIVO:
# Este documento apresenta comandos essenciais para a fase
# inicial de reconhecimento (Recon). O objetivo é mapear
# a topologia de rede, descobrir hosts ativos e identificar
# serviços expostos sem gerar tráfego suspeito inicialmente.
#
# ATENÇÃO:
# Nunca execute ferramentas de reconhecimento em redes,
# servidores ou domínios que você não possui autorização
# formal para testar. Use exclusivamente em laboratórios próprios.
#
# Leia • Entenda • Execute seu código
# ==========================================================

# ==========================================================
# ETAPA 01. Enumeração da própria interface de rede
# ==========================================================
# Identifica seu próprio IP, máscara e gateway antes de escanear
ip a

# ==========================================================
# ETAPA 02. Descoberta de hosts ativos na rede local (Ping Sweep)
# ==========================================================
# Envia pacotes ICMP para descobrir máquinas ligadas na sua sub-rede
# Substitua 192.168.1.0/24 pela sua rede real
nmap -sn 192.168.1.0/24

# ==========================================================
# ETAPA 03. Reconhecimento Passivo de DNS (Sem contato com o alvo)
# ==========================================================
# Consulta registros públicos para descobrir IPs associados a um domínio
dig any polydev.com.br
whois polydev.com.br

# ==========================================================
# ETAPA 04. Escaneamento de Portas e Serviços (Recon Ativo)
# ==========================================================
# -sV: Detecta a versão do serviço rodando na porta
# -sC: Executa scripts padrão de reconhecimento do Nmap
nmap -sV -sC 192.168.1.105

# ==========================================================
# ETAPA 05. Detecção de Sistema Operacional (OS Fingerprinting)
# ==========================================================
# -O: Tenta adivinhar o SO do alvo baseado na resposta da pilha TCP/IP
sudo nmap -O 192.168.1.105

# ==========================================================
# ETAPA 06. Varredura de vulnerabilidades conhecidas (Nmap Vulns)
# ==========================================================
# --script vuln: Busca falhas de segurança conhecidas nos serviços encontrados
nmap --script vuln 192.168.1.105

# ==========================================================
# ETAPA 07. Exportar resultados para análise posterior
# ==========================================================
# -oN: Salva a saída em formato de texto legível
nmap -sV -sC -oN /root/polydev_recon_scan.txt 192.168.1.105