# ==========================================================
# POLYDEV | WX-COLLECTOR
# WX-PY-238
# Deprecated Warning
# Categoria: wxpy12
# ==========================================================

import warnings
from functools import wraps

def deprecated(reason=""):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            message = f"{func.__name__} está depreciada."
            if reason:
                message += f" {reason}"
            warnings.warn(message, DeprecationWarning, stacklevel=2)
            return func(*args, **kwargs)
        return wrapper
    return decorator
