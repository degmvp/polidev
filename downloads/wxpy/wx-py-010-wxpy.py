"""
PYTHON10 - Task Queue Assíncrona com Workers
==============================================
Fila de tarefas in-memory com pool de workers assíncronos,
prioridade, timeout, e retries.
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
        return self.priority > other.priority


class TaskQueue:
    def __init__(self, max_workers: int = 4, default_timeout: float | None = 60.0):
        self._queue: asyncio.PriorityQueue[Task] = asyncio.PriorityQueue()
        self._max_workers = max_workers
        self._default_timeout = default_timeout
        self._tasks: dict[str, Task] = {}
        self._workers: list[asyncio.Task] = []
        self._running = False
        self._on_complete: Callable[[Task], None] | None = None
        self._on_error: Callable[[Task, Exception], None] | None = None

    async def submit(self, func: Callable, *args, name: str = "",
                     priority: int = 0, max_retries: int = 0,
                     timeout: float | None = None, **kwargs) -> str:
        task = Task(name=name or func.__name__, func=func, args=args,
                    kwargs=kwargs, priority=priority, max_retries=max_retries,
                    timeout=timeout or self._default_timeout)
        self._tasks[task.id] = task
        await self._queue.put(task)
        return task.id

    async def _worker(self, worker_id: int) -> None:
        while self._running:
            try:
                task = await asyncio.wait_for(self._queue.get(), timeout=1.0)
            except asyncio.TimeoutError:
                continue
            task.status = TaskStatus.RUNNING
            try:
                coro = task.func(*task.args, **task.kwargs)
                if asyncio.iscoroutine(coro):
                    task.result = await asyncio.wait_for(coro, timeout=task.timeout) if task.timeout else await coro
                else:
                    task.result = coro
                task.status = TaskStatus.COMPLETED
                task.completed_at = time.time()
                if self._on_complete:
                    self._on_complete(task)
            except Exception as e:
                task.retries += 1
                if task.retries <= task.max_retries:
                    task.status = TaskStatus.PENDING
                    await self._queue.put(task)
                else:
                    task.status = TaskStatus.FAILED
                    task.error = str(e)
                    task.completed_at = time.time()
                    if self._on_error:
                        self._on_error(task, e)
            self._queue.task_done()

    async def start(self) -> None:
        self._running = True
        self._workers = [asyncio.create_task(self._worker(i)) for i in range(self._max_workers)]

    async def stop(self, wait: bool = True) -> None:
        self._running = False
        if wait:
            await asyncio.gather(*self._workers, return_exceptions=True)
        self._workers.clear()

    def get_task(self, task_id: str) -> Task | None:
        return self._tasks.get(task_id)

    def on_complete(self, callback): self._on_complete = callback
    def on_error(self, callback): self._on_error = callback

    @property
    def stats(self) -> dict[str, int]:
        by_status = {s.value: 0 for s in TaskStatus}
        for task in self._tasks.values():
            by_status[task.status.value] += 1
        return {"total": len(self._tasks), "queue_size": self._queue.qsize(),
                "workers": self._max_workers, **by_status}


# ===================== EXEMPLO DE USO =====================
#
# async def processar_imagem(url: str) -> dict:
#     await asyncio.sleep(1)
#     return {"url": url, "status": "processada"}
#
# async def main():
#     queue = TaskQueue(max_workers=3)
#     queue.on_complete(lambda t: print(f"Concluída: {t.name}: {t.result}"))
#     await queue.start()
#     await queue.submit(processar_imagem, "https://img.com/1.jpg", name="img_1", priority=10)
#     await asyncio.sleep(3)
#     await queue.stop()
#
# asyncio.run(main())
