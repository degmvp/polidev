# ==========================================================
# POLYDEV | WX-COLLECTOR
# WX-PY-232
# Retry com Exponential Backoff
# Categoria: wxpy12
# ==========================================================

import time
from functools import wraps

def retry(max_attempts=3, delay=1.0):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            last_error = None
            for attempt in range(1, max_attempts + 1):
                try:
                    return func(*args, **kwargs)
                except Exception as exc:
                    last_error = exc
                    if attempt < max_attempts:
                        time.sleep(delay * (2 ** (attempt - 1)))
            raise last_error
        return wrapper
    return decorator
