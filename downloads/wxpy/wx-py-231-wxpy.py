# ==========================================================
# POLYDEV | WX-COLLECTOR
# WX-PY-231
# Timer Profissional
# Categoria: wxpy12
# ==========================================================

import time
from functools import wraps

def timer(name: str = None):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            start = time.perf_counter()
            result = func(*args, **kwargs)
            end = time.perf_counter()
            label = name or func.__name__
            print(f"{label}: {end - start:.6f} segundos")
            return result
        return wrapper
    return decorator
