#!/bin/bash
# ==========================================================
# POLYDEV | Kali Engineering
# KAL07 - Resposta a Incidentes e Preservação de Evidências
# ==========================================================
#
# TECNOLOGIA:
# Kali Linux
#
# LINGUAGEM:
# Bash
#
# OBJETIVO:
# Este documento estabelece o procedimento padrão para a
# primeira resposta a incidentes (Initial Response). Foca
# na coleta de dados voláteis da memória RAM e processos,
# garantindo que as evidências não sejam contaminadas antes
# da análise forense profunda.
#
# ATENÇÃO:
# NUNCA execute comandos de investigação diretamente na
# máquina comprometida sem redirecionar a saída para um
# repositório externo seguro (ex: HD externo ou servidor
# remoto). Escrever logs no disco da vítima altera seus
# metadados e pode destruir evidências (Anti-Forensics).
#
# Leia • Entenda • Execute seu código
# ==========================================================

# ==========================================================
# ETAPA 01. Isolamento do Ambiente (Sem Desligamento)
# ==========================================================
# Desconecta a máquina da rede imediatamente para evitar
# comunicação com o C2 (Command and Control) do atacante.
# Use o comando ip para derrubar as interfaces de rede.
# NÃO use ifdown, pois ele pode interagir com scripts de rede e alterar logs.
sudo ip link set eth0 down

# ==========================================================
# ETAPA 02. Registrar a Data e Hora Oficial do Incidente
# ==========================================================
# A precisão temporal é a base da cadeia de custódia.
# Grave o horário exato do início da coleta e compare com um servidor NTP confiável.
date -u >> /mnt/disco_externo/evidencias/incidente_timeline.txt
echo "INÍCIO DA COLETA VOLÁTIL" >> /mnt/disco_externo/evidencias/incidente_timeline.txt

# ==========================================================
# ETAPA 03. Captura do Estado da Memória Volátil (RAM)
# ==========================================================
# A RAM contém senhas em texto claro, conexões ativas, malwares em execução.
# Use uma ferramenta como o LiME (Linux Memory Extractor) se disponível.
# Exemplo genérico de extração (requer módulo do kernel carregado):
# sudo insmod lime.ko "path=/mnt/disco_externo/evidencias/memoria_ram.lime format=lime"

# Alternativa de emergência sem ferramentas externas (Menos confiável, mas funcional):
sudo dd if=/dev/mem of=/mnt/disco_externo/evidencias/mem_dump_bruto.dd bs=1M

# ==========================================================
# ETAPA 04. Coleta de Informações de Processos e Conexões
# ==========================================================
# Liste todos os processos em execução com detalhes completos
ps auxefw >> /mnt/disco_externo/evidencias/processos.txt

# Liste todas as conexões de rede ativas e os processos donos (essencial para achar backdoors)
ss -tulpan >> /mnt/disco_externo/evidencias/conexoes_ativas.txt

# ==========================================================
# ETAPA 05. Coleta de Usuários e Sessões Ativas
# ==========================================================
# Quem está logado no momento do incidente?
w >> /mnt/disco_externo/evidencias/usuarios_logados.txt

# Liste o histórico de comandos de todos os usuários
for user_home in /home/*; do
    cat "$user_home/.bash_history" >> /mnt/disco_externo/evidencias/historicos_comandos.txt 2>/dev/null
done

# ==========================================================
# ETAPA 06. Hashing de Integridade das Evidências Coletadas
# ==========================================================
# Gere o hash SHA256 de todos os arquivos coletados.
# Se qualquer evidência for questionada judicialmente, este hash prova que não foi alterada.
sha256sum /mnt/disco_externo/evidencias/* > /mnt/disco_externo/evidencias/hash_integridade.sha256

# ==========================================================
# ETAPA 07. Cálculo de Hash do Sistema de Arquivos (Rápido)
# ==========================================================
# Gere hashes de todos os binários do sistema antes de desligar a máquina.
# Comparando estes hashes com os de um sistema limpo, você descobre quais arquivos foram trocados pelo atacante.
sha256sum /usr/bin/* /usr/sbin/* >> /mnt/disco_externo/evidencias/hash_binarios_sistema.txt