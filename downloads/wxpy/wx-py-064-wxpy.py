"""
PYTHON07 - Circuit Breaker (Disjuntor de Circuito)
====================================================
Padrão de resiliência que protege sistemas contra falhas
em cascata. Quando um serviço falha repetidamente, o
circuit breaker "abre" e rejeita chamadas imediatamente,
dando tempo para o serviço se recuperar.
"""

import time
import threading
import functools
from enum import Enum
from typing import Any, Callable


class CircuitState(Enum):
    CLOSED = "closed"          # Funcionamento normal
    OPEN = "open"              # Rejeitando chamadas
    HALF_OPEN = "half_open"    # Testando recuperação


class CircuitBreakerError(Exception):
    """Exceção lançada quando o circuito está aberto."""
    pass


class CircuitBreaker:
    """
    Implementação do padrão Circuit Breaker.

    Args:
        failure_threshold: Número de falhas consecutivas para abrir o circuito.
        recovery_timeout: Segundos para aguardar antes de testar recuperação.
        success_threshold: Sucessos necessários em half-open para fechar.
        excluded_exceptions: Exceções que NÃO contam como falha.
    """

    def __init__(
        self,
        failure_threshold: int = 5,
        recovery_timeout: float = 30.0,
        success_threshold: int = 2,
        excluded_exceptions: tuple[type, ...] = (),
    ):
        self._failure_threshold = failure_threshold
        self._recovery_timeout = recovery_timeout
        self._success_threshold = success_threshold
        self._excluded = excluded_exceptions

        self._state = CircuitState.CLOSED
        self._failure_count = 0
        self._success_count = 0
        self._last_failure_time: float | None = None
        self._lock = threading.Lock()

        # Métricas
        self._total_calls = 0
        self._total_failures = 0
        self._total_rejected = 0

    @property
    def state(self) -> CircuitState:
        with self._lock:
            if self._state == CircuitState.OPEN:
                if (
                    self._last_failure_time
                    and time.monotonic() - self._last_failure_time
                    >= self._recovery_timeout
                ):
                    self._state = CircuitState.HALF_OPEN
                    self._success_count = 0
            return self._state

    def _record_success(self) -> None:
        with self._lock:
            self._total_calls += 1
            if self._state == CircuitState.HALF_OPEN:
                self._success_count += 1
                if self._success_count >= self._success_threshold:
                    self._state = CircuitState.CLOSED
                    self._failure_count = 0
            else:
                self._failure_count = 0

    def _record_failure(self) -> None:
        with self._lock:
            self._total_calls += 1
            self._total_failures += 1
            self._failure_count += 1
            self._last_failure_time = time.monotonic()

            if self._state == CircuitState.HALF_OPEN:
                self._state = CircuitState.OPEN
            elif self._failure_count >= self._failure_threshold:
                self._state = CircuitState.OPEN

    def call(self, func: Callable, *args: Any, **kwargs: Any) -> Any:
        """
        Executa a função protegida pelo circuit breaker.

        Raises:
            CircuitBreakerError: Se o circuito estiver aberto.
        """
        current_state = self.state

        if current_state == CircuitState.OPEN:
            self._total_rejected += 1
            raise CircuitBreakerError(
                f"Circuito aberto. Próxima tentativa em "
                f"{self._recovery_timeout}s."
            )

        try:
            result = func(*args, **kwargs)
            self._record_success()
            return result
        except self._excluded:
            self._record_success()
            raise
        except Exception:
            self._record_failure()
            raise

    def reset(self) -> None:
        """Reseta o circuit breaker para o estado fechado."""
        with self._lock:
            self._state = CircuitState.CLOSED
            self._failure_count = 0
            self._success_count = 0

    @property
    def stats(self) -> dict[str, Any]:
        return {
            "state": self.state.value,
            "failure_count": self._failure_count,
            "total_calls": self._total_calls,
            "total_failures": self._total_failures,
            "total_rejected": self._total_rejected,
        }


def circuit_breaker(
    failure_threshold: int = 5,
    recovery_timeout: float = 30.0,
    **kwargs: Any,
):
    """Decorator que aplica Circuit Breaker a uma função."""
    cb = CircuitBreaker(
        failure_threshold=failure_threshold,
        recovery_timeout=recovery_timeout,
        **kwargs,
    )

    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        def wrapper(*args: Any, **kw: Any) -> Any:
            return cb.call(func, *args, **kw)

        wrapper.circuit_breaker = cb  # type: ignore
        return wrapper

    return decorator


# ===================== EXEMPLO DE USO =====================
#
# @circuit_breaker(failure_threshold=3, recovery_timeout=10.0)
# def consultar_servico_externo(endpoint: str) -> dict:
#     import requests
#     response = requests.get(endpoint, timeout=5)
#     response.raise_for_status()
#     return response.json()
#
# # Após 3 falhas consecutivas, o circuito abre:
# try:
#     consultar_servico_externo("https://api.instavel.com/dados")
# except CircuitBreakerError as e:
#     print(f"Circuito aberto: {e}")
#
# # Verificar estado e métricas
# cb = consultar_servico_externo.circuit_breaker
# print(cb.stats)
# >>> {'state': 'open', 'failure_count': 3, ...}
#
# # Após recovery_timeout, entra em half_open e testa novamente
