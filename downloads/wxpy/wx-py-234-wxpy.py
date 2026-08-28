# ==========================================================
# POLYDEV | WX-COLLECTOR
# WX-PY-234
# Logging Automático
# Categoria: wxpy12
# ==========================================================

import logging
from functools import wraps

logging.basicConfig(level=logging.INFO)

def log_execution(level="info"):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            logger = logging.getLogger(func.__module__)
            log = getattr(logger, level.lower(), logger.info)
            log(f"Executando {func.__name__}")
            result = func(*args, **kwargs)
            log(f"Retorno: {result}")
            return result
        return wrapper
    return decorator
