"""
PYTHON05 - Rate Limiter (Limitador de Taxa)
============================================
Controla a frequência de execução de funções, útil para
respeitar limites de APIs, prevenir abuso, ou controlar
fluxo de requisições. Implementa Token Bucket algorithm.
"""

import time
import threading
import functools
from typing import Any, Callable


class RateLimiter:
    """
    Limitador de taxa baseado no algoritmo Token Bucket.
    Thread-safe. Pode ser usado como context manager ou decorator.
    """

    def __init__(self, rate: float, burst: int | None = None):
        self._rate = rate
        self._burst = burst or int(rate)
        self._tokens = float(self._burst)
        self._last_refill = time.monotonic()
        self._lock = threading.Lock()
        self._total_requests = 0
        self._total_throttled = 0

    def _refill(self) -> None:
        now = time.monotonic()
        elapsed = now - self._last_refill
        self._tokens = min(self._burst, self._tokens + elapsed * self._rate)
        self._last_refill = now

    def acquire(self, timeout: float | None = None) -> bool:
        deadline = time.monotonic() + timeout if timeout is not None else None
        while True:
            with self._lock:
                self._refill()
                if self._tokens >= 1.0:
                    self._tokens -= 1.0
                    self._total_requests += 1
                    return True
                wait_time = (1.0 - self._tokens) / self._rate
            if deadline is not None:
                remaining = deadline - time.monotonic()
                if remaining <= 0:
                    self._total_throttled += 1
                    return False
                wait_time = min(wait_time, remaining)
            time.sleep(wait_time)

    def try_acquire(self) -> bool:
        with self._lock:
            self._refill()
            if self._tokens >= 1.0:
                self._tokens -= 1.0
                self._total_requests += 1
                return True
            self._total_throttled += 1
            return False

    @property
    def stats(self) -> dict[str, Any]:
        return {
            "total_requests": self._total_requests,
            "total_throttled": self._total_throttled,
            "available_tokens": self._tokens,
            "rate_per_second": self._rate,
            "burst_capacity": self._burst,
        }

    def __enter__(self) -> "RateLimiter":
        self.acquire()
        return self

    def __exit__(self, *args: Any) -> None:
        pass


def rate_limited(rate: float, burst: int | None = None):
    limiter = RateLimiter(rate=rate, burst=burst)
    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        def wrapper(*args: Any, **kwargs: Any) -> Any:
            limiter.acquire()
            return func(*args, **kwargs)
        wrapper.limiter = limiter
        return wrapper
    return decorator


# ===================== EXEMPLO DE USO =====================
#
# @rate_limited(rate=5.0, burst=10)
# def chamar_api(endpoint: str) -> dict:
#     import requests
#     return requests.get(endpoint).json()
#
# limiter = RateLimiter(rate=10.0, burst=20)
# for i in range(100):
#     with limiter:
#         print(f"Requisição {i} executada")
