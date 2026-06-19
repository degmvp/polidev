# POLYDEV | Python Professional Functions
# 06 - Função para gerar relatório de performance com decorador para medir tempo de execução
#
# Finalidade:
# Monitorar o desempenho de funções críticas em sistemas para identificar gargalos.

import time

def medir_tempo_execucao(func):
    def wrapper(*args, **kwargs):
        inicio = time.time()
        resultado = func(*args, **kwargs)
        fim = time.time()
        print(f"[Performance] {func.__name__} levou {fim - inicio:.4f} segundos")
        return resultado
    return wrapper

@medir_tempo_execucao
def processar_dados_complexos(dados):
    # Simulação de processamento complexo
    time.sleep(2)
    return sum(dados)

resultado = processar_dados_complexos(range(100000))
