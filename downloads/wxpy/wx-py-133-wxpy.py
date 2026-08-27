# POLYDEV | Python Professional Functions
# 03 - Funções de ordem superior (recebem ou retornam funções)
#
# Finalidade:
# Criar funções flexíveis para compor lógica de negócio, tratamento de erro, execução condicional, etc.

import random
from functools import wraps

def retry(func=None, attempts=3):
    """
    Decorador de retry para chamadas instáveis.
    Pode ser usado como @retry ou @retry(attempts=5).
    """
    def decorator(inner_func):
        @wraps(inner_func)
        def wrapper(*args, **kwargs):
            last_error = None
            for _ in range(attempts):
                try:
                    return inner_func(*args, **kwargs)
                except Exception as exc:
                    last_error = exc
            raise last_error
        return wrapper

    if func is None:
        return decorator
    return decorator(func)


@retry
def call_api():
    if random.random() < 0.7:
        raise ConnectionError("Falha na conexão")
    return "Sucesso"


print(call_api())
