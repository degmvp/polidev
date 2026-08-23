"""
PYTHON08 - Profiler de Performance com Contexto
=================================================
Mede tempo de execução, uso de memória e contagem de chamadas.
"""

import time
import tracemalloc
import functools
import threading
from typing import Any, Callable
from contextlib import contextmanager
from dataclasses import dataclass


@dataclass
class ProfileResult:
    name: str
    elapsed_seconds: float
    memory_peak_mb: float
    memory_current_mb: float
    call_count: int = 1

    def __repr__(self) -> str:
        return f"ProfileResult('{self.name}': {self.elapsed_seconds:.4f}s, mem_peak={self.memory_peak_mb:.2f}MB, calls={self.call_count})"


class Profiler:
    def __init__(self) -> None:
        self._results: dict[str, ProfileResult] = {}
        self._lock = threading.Lock()

    @contextmanager
    def measure(self, name: str):
        tracemalloc.start()
        mem_before = tracemalloc.get_traced_memory()
        start = time.perf_counter()
        yield
        elapsed = time.perf_counter() - start
        mem_current, mem_peak = tracemalloc.get_traced_memory()
        tracemalloc.stop()
        result = ProfileResult(
            name=name, elapsed_seconds=elapsed,
            memory_peak_mb=(mem_peak - mem_before[0]) / (1024 * 1024),
            memory_current_mb=(mem_current - mem_before[0]) / (1024 * 1024),
        )
        with self._lock:
            if name in self._results:
                existing = self._results[name]
                existing.elapsed_seconds += elapsed
                existing.call_count += 1
                existing.memory_peak_mb = max(existing.memory_peak_mb, result.memory_peak_mb)
            else:
                self._results[name] = result

    def track(self, name: str | None = None):
        def decorator(func: Callable) -> Callable:
            label = name or func.__qualname__
            @functools.wraps(func)
            def wrapper(*args: Any, **kwargs: Any) -> Any:
                with self.measure(label):
                    return func(*args, **kwargs)
            return wrapper
        return decorator

    def report(self, sort_by: str = "elapsed_seconds") -> list[ProfileResult]:
        with self._lock:
            results = list(self._results.values())
        return sorted(results, key=lambda r: getattr(r, sort_by), reverse=True)

    def print_report(self, sort_by: str = "elapsed_seconds") -> None:
        print(f"\n{'='*70}")
        print(f"{'Nome':<30} {'Tempo (s)':<12} {'Mem Peak (MB)':<15} {'Chamadas'}")
        print(f"{'='*70}")
        for r in self.report(sort_by):
            print(f"{r.name:<30} {r.elapsed_seconds:<12.4f} {r.memory_peak_mb:<15.2f} {r.call_count}")
        print(f"{'='*70}\n")

    def reset(self) -> None:
        with self._lock:
            self._results.clear()


profiler = Profiler()


# ===================== EXEMPLO DE USO =====================
#
# prof = Profiler()
#
# @prof.track()
# def processar_dados(n: int) -> list[int]:
#     return sorted([i ** 2 for i in range(n)], reverse=True)
#
# for _ in range(5):
#     processar_dados(100_000)
#
# prof.print_report()
