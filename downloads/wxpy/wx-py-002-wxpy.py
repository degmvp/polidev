"""
PYTHON02 - Cache LRU com Expiração por Tempo (TTL)
===================================================
Cache em memória com limite de tamanho e expiração automática.
Substitui functools.lru_cache quando você precisa que entradas
expirem após um tempo definido.
"""

import time
import functools
import threading
from collections import OrderedDict
from typing import Any, Callable, Hashable


class TTLCache:
    """
    Cache thread-safe com Least Recently Used (LRU) e Time-To-Live (TTL).

    Args:
        maxsize: Número máximo de entradas no cache.
        ttl: Tempo de vida de cada entrada, em segundos.
    """

    def __init__(self, maxsize: int = 128, ttl: float = 300.0):
        self._cache: OrderedDict[Hashable, tuple[Any, float]] = OrderedDict()
        self._maxsize = maxsize
        self._ttl = ttl
        self._lock = threading.Lock()
        self.hits = 0
        self.misses = 0

    def get(self, key: Hashable) -> Any | None:
        with self._lock:
            if key in self._cache:
                value, timestamp = self._cache[key]
                if time.monotonic() - timestamp < self._ttl:
                    self._cache.move_to_end(key)
                    self.hits += 1
                    return value
                else:
                    del self._cache[key]
            self.misses += 1
            return None

    def put(self, key: Hashable, value: Any) -> None:
        with self._lock:
            if key in self._cache:
                self._cache.move_to_end(key)
            self._cache[key] = (value, time.monotonic())
            if len(self._cache) > self._maxsize:
                self._cache.popitem(last=False)

    def invalidate(self, key: Hashable) -> None:
        with self._lock:
            self._cache.pop(key, None)

    def clear(self) -> None:
        with self._lock:
            self._cache.clear()
            self.hits = 0
            self.misses = 0

    @property
    def hit_rate(self) -> float:
        total = self.hits + self.misses
        return self.hits / total if total > 0 else 0.0


def ttl_cache(maxsize: int = 128, ttl: float = 300.0):
    """
    Decorator que aplica TTLCache a uma função.

    Args:
        maxsize: Tamanho máximo do cache.
        ttl: Tempo de vida em segundos.
    """
    cache = TTLCache(maxsize=maxsize, ttl=ttl)

    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        def wrapper(*args: Any, **kwargs: Any) -> Any:
            key = (args, tuple(sorted(kwargs.items())))
            result = cache.get(key)
            if result is not None:
                return result
            result = func(*args, **kwargs)
            cache.put(key, result)
            return result

        wrapper.cache = cache  # type: ignore
        return wrapper

    return decorator


# ===================== EXEMPLO DE USO =====================
#
# @ttl_cache(maxsize=256, ttl=60.0)
# def consultar_usuario(user_id: int) -> dict:
#     """Simula consulta ao banco de dados."""
#     import time
#     time.sleep(0.5)  # simulando latência
#     return {"id": user_id, "nome": f"Usuário {user_id}"}
#
# # Primeira chamada: lenta (0.5s)
# print(consultar_usuario(42))
#
# # Segunda chamada: instantânea (cache hit)
# print(consultar_usuario(42))
#
# # Estatísticas do cache
# print(f"Hit rate: {consultar_usuario.cache.hit_rate:.1%}")
# >>> Hit rate: 50.0%
