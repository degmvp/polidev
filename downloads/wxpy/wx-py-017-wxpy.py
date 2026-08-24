"""
wx-py-017-wxpy.py
Execução paralela com ThreadPoolExecutor e barra de progresso

Para que serve:
    Aplica uma função a uma lista de itens em paralelo (multithreading)
    e mostra o progresso em tempo real. Ideal para tarefas de E/S,
    como downloads e chamadas de API.

Exemplo de uso:
    resultados = parallel_map(download, urls, trabalhadores=5)
"""

import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed


def parallel_map(funcao, itens, trabalhadores=4):
    """Executa funcao(item) em paralelo e retorna os resultados na ordem."""
    resultados = {}
    total = len(itens)
    concluidos = 0
    inicio = time.monotonic()

    with ThreadPoolExecutor(max_workers=trabalhadores) as executor:
        futuros = {executor.submit(funcao, item): item for item in itens}
        for futuro in as_completed(futuros):
            item = futuros[futuro]
            resultados[item] = futuro.result()
            concluidos += 1
            _mostrar_progresso(concluidos, total, inicio)

    return [resultados[item] for item in itens]


def _mostrar_progresso(concluidos, total, inicio):
    pct = concluidos / total * 100
    decorrido = time.monotonic() - inicio
    sys.stdout.write(
        f"\r{concluidos}/{total} ({pct:.0f}%) em {decorrido:.1f}s")
    sys.stdout.flush()
    if concluidos == total:
        sys.stdout.write("\n")


if __name__ == "__main__":
    def tarefa(n):
        time.sleep(0.2)
        return n * n

    resultados = parallel_map(tarefa, list(range(6)), trabalhadores=3)
    print("resultados:", resultados)
