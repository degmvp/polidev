# POLYDEV | Python Professional Functions
# 15 - Função para monitoramento e retry automático em chamadas HTTP
#
# Finalidade:
# Aumentar a robustez do sistema ao lidar com falhas temporárias.

import time
import requests

def chamada_com_retry(url, tentativas=3, delay=2, timeout=10):
    """
    Executa chamada HTTP com retry simples para falhas temporárias.
    """
    ultima_falha = None

    for tentativa in range(1, tentativas + 1):
        try:
            resposta = requests.get(url, timeout=timeout)
            resposta.raise_for_status()
            return resposta.json()
        except requests.RequestException as exc:
            ultima_falha = exc
            if tentativa == tentativas:
                raise
            time.sleep(delay)

    raise ultima_falha


dados = chamada_com_retry("https://api.exemplo.com/dados")
print(dados)
