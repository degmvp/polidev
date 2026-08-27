#!/usr/bin/env python3
# ==========================================================
# POLYDEV | Python Engineering
# ==========================================================
#
# Série:
# Python Engineering v1.0
#
# PYENG-01 — Worker Pool com Queue
#
# Tecnologia:
# Python 3.12+
#
# Categoria:
# Concorrência • Engenharia de Software
#
# Objetivo
# ----------------------------------------------------------
# Implementar um Worker Pool utilizando queue.Queue e
# ThreadPoolExecutor para executar tarefas paralelas de
# forma organizada, segura e reutilizável.
#
# O que é um Worker Pool?
# ----------------------------------------------------------
# Worker Pool é um padrão de concorrência que mantém um
# conjunto fixo de workers responsáveis por consumir tarefas
# de uma fila compartilhada.
#
# Em vez de criar uma thread para cada solicitação, um
# número limitado de workers executa todas as tarefas,
# reduzindo consumo de memória e melhorando a escalabilidade.
#
# Quando utilizar
# ----------------------------------------------------------
# • Processamento em lote
# • ETL
# • Web Crawlers
# • APIs
# • Automação
# • Processamento paralelo
#
# Problema resolvido
# ----------------------------------------------------------
# Evita a criação excessiva de threads e permite controlar
# a concorrência de maneira eficiente, aumentando a
# estabilidade da aplicação.
#
# Fluxo de execução
# ----------------------------------------------------------
#
#           Producer
#               │
#               ▼
#        +---------------+
#        |     Queue     |
#        +---------------+
#               │
#               ▼
#     +-----------------------+
#     | ThreadPoolExecutor    |
#     +-----------------------+
#               │
#               ▼
#          Resultados
#
# Principais componentes
# ----------------------------------------------------------
# • Queue
# • ThreadPoolExecutor
# • Future
#
# Resultado esperado
# ----------------------------------------------------------
# Executar múltiplas tarefas em paralelo utilizando um
# número controlado de workers, retornando os resultados
# de forma organizada.
#
# Observações
# ----------------------------------------------------------
# Este exemplo foi desenvolvido para fins educacionais.
# Em ambientes de produção, considere adicionar tratamento
# de exceções, logging estruturado, métricas e testes
# automatizados conforme os requisitos do projeto.
#
# ==========================================================
# Implementação
# ==========================================================
import threading
from queue import Queue
from concurrent.futures import ThreadPoolExecutor

class WorkerPool:
    def __init__(self, num_workers=4):
        self.queue = Queue()
        self.num_workers = num_workers
        self.executor = ThreadPoolExecutor(max_workers=num_workers)
        self.results = []

    def submit(self, task, *args):
        """Submete uma tarefa para o pool."""
        self.queue.put((task, args))

    def process(self):
        """Processa todas as tarefas na fila."""
        futures = []
        while not self.queue.empty():
            task, args = self.queue.get()
            future = self.executor.submit(task, *args)
            futures.append(future)
        
        for future in futures:
            self.results.append(future.result())
        return self.results

    def shutdown(self):
        self.executor.shutdown(wait=True)

# Uso
def heavy_task(n):
    return n ** 2

pool = WorkerPool(num_workers=4)
for i in range(10):
    pool.submit(heavy_task, i)

results = pool.process()
print(f"Resultados: {results}")
pool.shutdown()

# ==========================================================
# Fim do módulo PYENG-01
# ==========================================================
