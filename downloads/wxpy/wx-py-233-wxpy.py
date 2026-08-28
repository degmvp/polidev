# ==========================================================
# POLYDEV | WX-COLLECTOR
# WX-PY-233
# TTL Cache Inteligente
# Categoria: wxpy12
# ==========================================================

import time
from functools import wraps

def ttl_cache(seconds=60):
    def decorator(func):
        cache = {}
        @wraps(func)
        def wrapper(*args, **kwargs):
            key = args + tuple(sorted(kwargs.items()))
            now = time.time()
            if key in cache:
                result, timestamp = cache[key]
                if now - timestamp < seconds:
                    return result
            result = func(*args, **kwargs)
            cache[key] = (result, now)
            return result
        return wrapper
    return decorator
