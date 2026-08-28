# ==========================================================
# POLYDEV | WX-COLLECTOR
# WX-PY-239
# Validate Input Types
# Categoria: wxpy12
# ==========================================================

import inspect
from functools import wraps

def validate_types(**type_hints):
    def decorator(func):
        signature = inspect.signature(func)

        @wraps(func)
        def wrapper(*args, **kwargs):
            bound = signature.bind(*args, **kwargs)
            bound.apply_defaults()

            for name, expected_type in type_hints.items():
                if name in bound.arguments and not isinstance(
                    bound.arguments[name], expected_type
                ):
                    actual = type(bound.arguments[name]).__name__
                    expected = getattr(expected_type, "__name__", str(expected_type))
                    raise TypeError(
                        f"{name} deve ser {expected}; recebido {actual}"
                    )

            return func(*args, **kwargs)

        return wrapper
    return decorator
