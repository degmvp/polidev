# ==========================================================
# POLYDEV | WX-COLLECTOR
# WX-PY-235
# Rate Limiter
# Categoria: wxpy12
# ==========================================================

import time
from functools import wraps

def rate_limiter(calls_per_second=1.0):
    if calls_per_second <= 0:
        raise ValueError("calls_per_second deve ser maior que zero")
    min_interval = 1.0 / calls_per_second
    last_call = [0.0]

    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            now = time.time()
            elapsed = now - last_call[0]
            if elapsed < min_interval:
                time.sleep(min_interval - elapsed)
            last_call[0] = time.time()
            return func(*args, **kwargs)
        return wrapper
    return decorator
