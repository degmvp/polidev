#!/usr/bin/env python3
# ==========================================================
# POLYDEV | Python Engineering
# ==========================================================
#
# Série:
# Python Engineering v1.0
#
# PYENG-04 — Circuit Breaker
#
# Tecnologia:
# Python 3.12+
#
# Categoria:
# Resiliência • Engenharia de Software
#
# Objetivo
# ----------------------------------------------------------
# Implementar o padrão Circuit Breaker para proteger
# aplicações contra falhas recorrentes em serviços externos,
# evitando novas chamadas enquanto o serviço estiver
# indisponível e permitindo recuperação automática.
#
# O que é Circuit Breaker?
# ----------------------------------------------------------
# Circuit Breaker é um padrão arquitetural utilizado para
# interromper chamadas para serviços que estão falhando
# repetidamente.
#
# Após atingir um limite de falhas, o circuito é aberto,
# impedindo novas tentativas até o tempo de recuperação
# configurado. Quando esse período termina, o circuito entra
# em HALF_OPEN para validar se o serviço voltou ao normal.
#
# Quando utilizar
# ----------------------------------------------------------
# • APIs REST
# • Microsserviços
# • Bancos de Dados
# • Sistemas Distribuídos
# • Serviços Cloud
# • Integrações Externas
#
# Problema resolvido
# ----------------------------------------------------------
# Evita sobrecarregar serviços indisponíveis, reduz tempo
# de espera para o usuário e aumenta a estabilidade da
# aplicação em ambientes distribuídos.
#
# Fluxo de execução
# ----------------------------------------------------------
#
#          Requisição
#               │
#               ▼
#      +------------------+
#      | Circuit Breaker  |
#      +------------------+
#               │
#      ┌────────┼─────────┐
#      │        │         │
#   CLOSED    OPEN    HALF_OPEN
#      │        │         │
#      ▼        ▼         ▼
# Executa   Bloqueia   Testa Serviço
#
# Principais componentes
# ----------------------------------------------------------
# • Enum
# • State Machine
# • Timeout
# • Failure Counter
# • Recovery Window
#
# Resultado esperado
# ----------------------------------------------------------
# Proteger chamadas críticas contra falhas repetidas,
# aumentando a disponibilidade e a resiliência da aplicação.
#
# Observações
# ----------------------------------------------------------
# Este exemplo foi desenvolvido para fins educacionais.
# Em ambientes de produção recomenda-se integrar métricas,
# logging estruturado e monitoramento para acompanhamento
# do estado do circuito.
#
# ==========================================================
# Implementação
# ==========================================================

import time
from enum import Enum
from typing import Callable


class State(Enum):
    CLOSED = "closed"
    OPEN = "open"
    HALF_OPEN = "half_open"


class CircuitBreaker:
    def __init__(self, failure_threshold=5, recovery_timeout=30):
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.state = State.CLOSED
        self.failure_count = 0
        self.last_failure_time = None
        self.success_count = 0

    def call(self, func: Callable, *args, **kwargs):
        """Executa função protegida pelo circuit breaker."""
        if self.state == State.OPEN:
            if self._should_attempt_reset():
                self.state = State.HALF_OPEN
            else:
                raise CircuitOpenError(
                    f"Circuit OPEN. Retry em "
                    f"{self._time_until_retry():.1f}s"
                )

        try:
            result = func(*args, **kwargs)
            self._on_success()
            return result
        except Exception:
            self._on_failure()
            raise

    def _on_success(self):
        if self.state == State.HALF_OPEN:
            self.success_count += 1
            if self.success_count >= 3:
                self.state = State.CLOSED
                self.failure_count = 0
        self.failure_count = 0

    def _on_failure(self):
        self.failure_count += 1
        self.last_failure_time = time.time()
        if self.failure_count >= self.failure_threshold:
            self.state = State.OPEN

    def _should_attempt_reset(self) -> bool:
        return (
            time.time() - self.last_failure_time
            >= self.recovery_timeout
        )

    def _time_until_retry(self) -> float:
        elapsed = time.time() - self.last_failure_time
        return max(0.0, self.recovery_timeout - elapsed)


class CircuitOpenError(Exception):
    """Exceção lançada quando o circuito permanece aberto."""
    pass


# Uso
breaker = CircuitBreaker(
    failure_threshold=3,
    recovery_timeout=10
)


def external_service():
    """Simula um serviço externo."""
    return {"status": "ok"}


result = breaker.call(external_service)

print(
    f"Estado: {breaker.state.value}, "
    f"Resultado: {result}"
)

# ==========================================================
# Fim do módulo PYENG-04
# ==========================================================
#
# Resumo
# ----------------------------------------------------------
# Neste módulo você aprendeu como implementar o padrão
# Circuit Breaker para proteger aplicações contra falhas
# recorrentes em serviços externos, aumentando a
# disponibilidade e a resiliência do sistema.
#
# Próximo módulo
# ----------------------------------------------------------
# PYENG-05 — Cache TTL Profissional
#
# POLYDEV | Python Engineering v1.0
#
# Leia • Entenda • Execute seu código.
# ==========================================================