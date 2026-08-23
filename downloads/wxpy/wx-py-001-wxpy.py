"""
PYTHON01 - Decorator de Retry com Backoff Exponencial
=====================================================
Reexecuta uma função automaticamente em caso de falha,
com intervalo crescente entre tentativas (backoff exponencial).
Ideal para chamadas a APIs externas, operações de rede, etc.
"""

import time
import functools
import logging
from typing import Type, Tuple, Callable, Any

logger = logging.getLogger(__name__)


def retry(
    max_attempts: int = 3,
    backoff_factor: float = 2.0,
    initial_delay: float = 1.0,
    exceptions: Tuple[Type[BaseException], ...] = (Exception,),
    on_failure: Callable[[Exception, int], None] | None = None,
):
    """
    Decorator que reexecuta a função em caso de exceção.

    Args:
        max_attempts: Número máximo de tentativas (padrão: 3).
        backoff_factor: Fator multiplicador do delay entre tentativas.
        initial_delay: Delay inicial em segundos antes da primeira retry.
        exceptions: Tupla de exceções que devem acionar a retry.
        on_failure: Callback opcional chamado a cada falha (exceção, tentativa).

    Returns:
        O resultado da função decorada, se bem-sucedida.

    Raises:
        A última exceção capturada, se todas as tentativas falharem.
    """
    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        def wrapper(*args: Any, **kwargs: Any) -> Any:
            delay = initial_delay
            last_exception: Exception | None = None

            for attempt in range(1, max_attempts + 1):
                try:
                    return func(*args, **kwargs)
                except exceptions as e:
                    last_exception = e
                    logger.warning(
                        f"[retry] {func.__name__} falhou na tentativa "
                        f"{attempt}/{max_attempts}: {e}"
                    )
                    if on_failure:
                        on_failure(e, attempt)
                    if attempt < max_attempts:
                        time.sleep(delay)
                        delay *= backoff_factor

            raise last_exception  # type: ignore

        return wrapper
    return decorator


# ===================== EXEMPLO DE USO =====================
#
# import random
#
# @retry(max_attempts=5, backoff_factor=2.0, exceptions=(ConnectionError,))
# def buscar_dados_api(url: str) -> dict:
#     if random.random() < 0.7:
#         raise ConnectionError("Servidor indisponível")
#     return {"status": "ok", "dados": [1, 2, 3]}
#
# resultado = buscar_dados_api("https://api.exemplo.com/dados")
# print(resultado)
# >>> {"status": "ok", "dados": [1, 2, 3]}
