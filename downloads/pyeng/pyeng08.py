#!/usr/bin/env python3
# ==========================================================
# POLYDEV | Python Engineering
# ==========================================================
#
# Série:
# Python Engineering v1.0
#
# PYENG-08 — Processamento Assíncrono com AsyncIO
#
# Tecnologia:
# Python 3.12+
#
# Categoria:
# Concorrência • Engenharia de Software
#
# Objetivo
# ----------------------------------------------------------
# Implementar processamento assíncrono utilizando AsyncIO,
# permitindo executar múltiplas tarefas de I/O em paralelo
# com controle de concorrência através de semáforos.
#
# O que é AsyncIO?
# ----------------------------------------------------------
# AsyncIO é o framework de programação assíncrona do Python.
#
# Diferente do uso tradicional de threads, o AsyncIO permite
# executar milhares de operações de entrada e saída utilizando
# um único event loop, tornando aplicações muito mais
# eficientes para workloads baseados em I/O.
#
# Quando utilizar
# ----------------------------------------------------------
# • APIs REST
# • Web Crawlers
# • ETL
# • Download de Arquivos
# • Processamento em Lote
# • Microsserviços
#
# Problema resolvido
# ----------------------------------------------------------
# Evita bloqueios durante operações de entrada e saída,
# aumentando significativamente o throughput da aplicação
# sem necessidade de criar diversas threads.
#
# Fluxo de execução
# ----------------------------------------------------------
#
#         Event Loop
#              │
#              ▼
#     +------------------+
#     |  Semaphore       |
#     +------------------+
#              │
#              ▼
#      Processa Tasks
#              │
#              ▼
#         Coleta Resultados
#
# Principais componentes
# ----------------------------------------------------------
# • asyncio
# • Event Loop
# • Semaphore
# • gather()
# • Dataclass
#
# Resultado esperado
# ----------------------------------------------------------
# Processar diversos itens simultaneamente utilizando
# programação assíncrona com controle de concorrência e
# coleta organizada dos resultados.
#
# Observações
# ----------------------------------------------------------
# Este exemplo foi desenvolvido para fins educacionais.
# Em ambientes de produção recomenda-se integrar logging,
# tratamento de exceções, métricas e monitoramento do Event
# Loop para aplicações de alta disponibilidade.
#
# ==========================================================
# Implementação
# ==========================================================

import asyncio
from typing import List, Any
from dataclasses import dataclass


@dataclass
class TaskResult:
    task_id: str
    data: Any
    duration: float


class AsyncProcessor:
    """Processador assíncrono com controle de concorrência."""

    def __init__(self, max_concurrent: int = 10):
        self.semaphore = asyncio.Semaphore(max_concurrent)
        self.results: List[TaskResult] = []

    async def process_item(self, item_id: str, data: Any):
        """Processa um item com limite de concorrência."""
        async with self.semaphore:
            start = asyncio.get_event_loop().time()

            # Simula processamento assíncrono
            await asyncio.sleep(0.1)

            result = f"processed_{data}"

            duration = (
                asyncio.get_event_loop().time() - start
            )

            task_result = TaskResult(
                task_id=item_id,
                data=result,
                duration=duration
            )

            self.results.append(task_result)

            return task_result

    async def process_batch(
        self,
        items: dict
    ) -> List[TaskResult]:
        """Processa lote de items em paralelo."""

        tasks = [
            self.process_item(item_id, data)
            for item_id, data in items.items()
        ]

        await asyncio.gather(
            *tasks,
            return_exceptions=True
        )

        return self.results


# Uso
async def main():

    processor = AsyncProcessor(
        max_concurrent=5
    )

    items = {
        f"task_{i}": f"data_{i}"
        for i in range(20)
    }

    results = await processor.process_batch(items)

    print(f"Processados: {len(results)} items")

    for r in results[:3]:
        print(
            f"  {r.task_id}: "
            f"{r.data} "
            f"({r.duration:.3f}s)"
        )


asyncio.run(main())

# ==========================================================
# Fim do módulo PYENG-08
# ==========================================================
#
# Resumo
# ----------------------------------------------------------
# Neste módulo você aprendeu como utilizar AsyncIO para
# processar tarefas concorrentes de forma eficiente,
# utilizando Event Loop, Semaphore e gather() para obter
# alto desempenho em operações de I/O.
#
# Próximo módulo
# ----------------------------------------------------------
# PYENG-09 — Logging Estruturado
#
# POLYDEV | Python Engineering v1.0
#
# Leia • Entenda • Execute seu código.
# ==========================================================