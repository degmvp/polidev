# ==========================================================
# POLYDEV | WX-COLLECTOR
# WX-PY-236
# Async Timer
# Categoria: wxpy12
# ==========================================================

import time
from functools import wraps

def async_timer(func):
    @wraps(func)
    async def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = await func(*args, **kwargs)
        end = time.perf_counter()
        print(f"[Async] {end - start:.6f}s")
        return result
    return wrapper
