"""
PYTHON10 - Task Queue Assíncrona com Workers
==============================================
Fila de tarefas in-memory com pool de workers assíncronos,
prioridade, timeout, e retries. Ideal para processamento
em background, jobs agendados e paralelismo controlado.
"""

import asyncio
import logging
import time
import uuid
from dataclasses import dataclass, field
from enum import Enum
from typing import Any, Callable, Awaitable

logger = logging.getLogger(__name__)


class TaskStatus(Enum):
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"


@dataclass
class Task:
    """Representa uma tarefa na fila."""
    id: str = field(default_factory=lambda: uuid.uuid4().hex[:12])
    name: str = ""
    func: Callable[..., Awaitable[Any]] | Callable[..., Any] | None = None
    args: tuple = ()
    kwargs: dict = field(default_factory=dict)
    priority: int = 0
    max_retries: int = 0
    timeout: float | None = None
    status: TaskStatus = TaskStatus.PENDING
    result: Any = None
    error: str | None = None
    retries: int = 0
    created_at: float = field(default_factory=time.time)
    completed_at: float | None = None

    def __lt__(self, other: "Task") -> bool:
        return self.priority > other.priority  # Maior prioridade primeiro


class TaskQueue:
    """
    Fila de tarefas assíncrona com pool de workers.

    Args:
        max_workers: Número máximo de workers concorrentes.
        default_timeout: Timeout padrão por tarefa (segundos).
    """

    def __init__(
        self, max_workers: int = 4, default_timeout: float | None = 60.0
    ):
        self._queue: asyncio.PriorityQueue[Task] = asyncio.PriorityQueue()
        self._max_workers = max_workers
        self._default_timeout = default_timeout
        self._tasks: dict[str, Task] = {}
        self._workers: list[asyncio.Task] = []
        self._running = False
        self._on_complete: Callable[[Task], None] | None = None
        self._on_error: Callable[[Task, Exception], None] | None = None

    async def submit(
        self,
        func: Callable,
        *args: Any,
        name: str = "",
        priority: int = 0,
        max_retries: int = 0,
        timeout: float | None = None,
        **kwargs: Any,
    ) -> str:
        """
        Submete uma tarefa à fila.

        Args:
            func: Função (sync ou async) a executar.
            *args: Argumentos posicionais.
            name: Nome descritivo da tarefa.
            priority: Prioridade (maior = executada antes).
            max_retries: Número de retentativas em caso de falha.
            timeout: Timeout específico para esta tarefa.
            **kwargs: Argumentos nomeados.

        Returns:
            ID da tarefa submetida.
        """
        task = Task(
            name=name or func.__name__,
            func=func,
            args=args,
            kwargs=kwargs,
            priority=priority,
            max_retries=max_retries,
            timeout=timeout or self._default_timeout,
        )
        self._tasks[task.id] = task
        await self._queue.put(task)
        logger.info(f"Tarefa '{task.name}' [{task.id}] adicionada à fila")
        return task.id

    async def _worker(self, worker_id: int) -> None:
        """Worker loop que processa tarefas da fila."""
        while self._running:
            try:
                task = await asyncio.wait_for(self._queue.get(), timeout=1.0)
            except asyncio.TimeoutError:
                continue

            task.status = TaskStatus.RUNNING
            logger.info(
                f"Worker-{worker_id} processando '{task.name}' [{task.id}]"
            )

            try:
                coro = task.func(*task.args, **task.kwargs)
                if asyncio.iscoroutine(coro):
                    if task.timeout:
                        task.result = await asyncio.wait_for(
                            coro, timeout=task.timeout
                        )
                    else:
                        task.result = await coro
                else:
                    task.result = coro

                task.status = TaskStatus.COMPLETED
                task.completed_at = time.time()
                logger.info(f"Tarefa '{task.name}' [{task.id}] concluída")

                if self._on_complete:
                    self._on_complete(task)

            except Exception as e:
                task.retries += 1
                if task.retries <= task.max_retries:
                    logger.warning(
                        f"Tarefa '{task.name}' falhou (tentativa "
                        f"{task.retries}/{task.max_retries}): {e}"
                    )
                    task.status = TaskStatus.PENDING
                    await self._queue.put(task)
                else:
                    task.status = TaskStatus.FAILED
                    task.error = str(e)
                    task.completed_at = time.time()
                    logger.error(
                        f"Tarefa '{task.name}' [{task.id}] falhou "
                        f"definitivamente: {e}"
                    )
                    if self._on_error:
                        self._on_error(task, e)

            self._queue.task_done()

    async def start(self) -> None:
        """Inicia os workers."""
        self._running = True
        self._workers = [
            asyncio.create_task(self._worker(i))
            for i in range(self._max_workers)
        ]
        logger.info(f"TaskQueue iniciada com {self._max_workers} workers")

    async def stop(self, wait: bool = True) -> None:
        """Para os workers."""
        self._running = False
        if wait:
            await asyncio.gather(*self._workers, return_exceptions=True)
        self._workers.clear()
        logger.info("TaskQueue parada")

    def get_task(self, task_id: str) -> Task | None:
        """Retorna uma tarefa pelo ID."""
        return self._tasks.get(task_id)

    def on_complete(self, callback: Callable[[Task], None]) -> None:
        """Registra callback para tarefas concluídas."""
        self._on_complete = callback

    def on_error(self, callback: Callable[[Task, Exception], None]) -> None:
        """Registra callback para tarefas com erro."""
        self._on_error = callback

    @property
    def stats(self) -> dict[str, int]:
        """Estatísticas da fila."""
        by_status = {s.value: 0 for s in TaskStatus}
        for task in self._tasks.values():
            by_status[task.status.value] += 1
        return {
            "total": len(self._tasks),
            "queue_size": self._queue.qsize(),
            "workers": self._max_workers,
            **by_status,
        }


# ===================== EXEMPLO DE USO =====================
#
# import asyncio
#
# async def processar_imagem(url: str, resolucao: str = "1080p") -> dict:
#     """Simula processamento de imagem."""
#     await asyncio.sleep(1)  # simulando trabalho
#     return {"url": url, "resolucao": resolucao, "status": "processada"}
#
# async def enviar_notificacao(usuario_id: int, mensagem: str) -> bool:
#     await asyncio.sleep(0.5)
#     return True
#
# async def main():
#     queue = TaskQueue(max_workers=3, default_timeout=30.0)
#
#     queue.on_complete(lambda t: print(f"✅ {t.name}: {t.result}"))
#     queue.on_error(lambda t, e: print(f"❌ {t.name}: {e}"))
#
#     await queue.start()
#
#     # Submeter tarefas com prioridades diferentes
#     await queue.submit(
#         processar_imagem, "https://img.com/1.jpg",
#         name="img_1", priority=1
#     )
#     await queue.submit(
#         processar_imagem, "https://img.com/2.jpg",
#         name="img_2", priority=10  # alta prioridade
#     )
#     await queue.submit(
#         enviar_notificacao, 42, "Bem-vindo!",
#         name="notif_42", max_retries=3
#     )
#
#     await asyncio.sleep(3)  # esperar processamento
#     print(queue.stats)
#     await queue.stop()
#
# asyncio.run(main())
# >>> ✅ img_2: {'url': 'https://img.com/2.jpg', ...}
# >>> ✅ img_1: {'url': 'https://img.com/1.jpg', ...}
# >>> ✅ notif_42: True
