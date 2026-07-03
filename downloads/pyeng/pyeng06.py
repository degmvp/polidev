#!/usr/bin/env python3
# ==========================================================
# POLYDEV | Python Engineering
# ==========================================================
#
# Série:
# Python Engineering v1.0
#
# PYENG-06 — Rate Limiter
#
# Tecnologia:
# Python 3.12+
#
# Categoria:
# Performance • Engenharia de Software
#
# Objetivo
# ----------------------------------------------------------
# Implementar mecanismos profissionais de Rate Limiting
# utilizando os algoritmos Token Bucket e Sliding Window,
# permitindo controlar o volume de requisições aceitas por
# uma aplicação.
#
# O que é um Rate Limiter?
# ----------------------------------------------------------
# Rate Limiter é um padrão utilizado para limitar a
# quantidade de operações executadas durante um intervalo
# de tempo.
#
# Esse mecanismo protege APIs e serviços contra excesso de
# requisições, garantindo estabilidade e uso equilibrado
# dos recursos disponíveis.
#
# Quando utilizar
# ----------------------------------------------------------
# • APIs REST
# • Gateways
# • Microsserviços
# • Login de Usuários
# • Sistemas Distribuídos
# • Proteção contra abuso
#
# Problema resolvido
# ----------------------------------------------------------
# Evita sobrecarga causada por excesso de requisições,
# reduzindo consumo de CPU, memória e largura de banda,
# aumentando a disponibilidade do serviço.
#
# Fluxo de execução
# ----------------------------------------------------------
#
#          Cliente
#             │
#             ▼
#      +---------------+
#      | Rate Limiter  |
#      +---------------+
#         │         │
#         │         │
#      Permitido  Bloqueado
#         │
#         ▼
#     Processamento
#
# Principais componentes
# ----------------------------------------------------------
# • Token Bucket
# • Sliding Window
# • Lock (Thread Safety)
# • deque
# • Controle Temporal
#
# Resultado esperado
# ----------------------------------------------------------
# Controlar a quantidade de requisições aceitas pela
# aplicação utilizando algoritmos eficientes e seguros para
# ambientes concorrentes.
#
# Observações
# ----------------------------------------------------------
# Este exemplo foi desenvolvido para fins educacionais.
# Em ambientes de produção recomenda-se integrar métricas,
# monitoramento, autenticação e limites específicos para
# diferentes perfis de usuários.
#
# ==========================================================
# Implementação
# ==========================================================

import time
from collections import deque
from threading import Lock


class TokenBucket:
    """Rate limiter com algoritmo Token Bucket."""

    def __init__(self, rate: float, capacity: int):
        self.rate = rate
        self.capacity = capacity
        self.tokens = capacity
        self.last_refill = time.time()
        self._lock = Lock()

    def acquire(self, tokens: int = 1) -> bool:
        """Tenta consumir tokens. Retorna True se permitido."""
        with self._lock:
            self._refill()

            if self.tokens >= tokens:
                self.tokens -= tokens
                return True

            return False

    def _refill(self):
        now = time.time()
        elapsed = now - self.last_refill
        new_tokens = elapsed * self.rate

        self.tokens = min(
            self.capacity,
            self.tokens + new_tokens
        )

        self.last_refill = now


class SlidingWindowLimiter:
    """Rate limiter com Sliding Window."""

    def __init__(self, max_requests: int, window_seconds: int):
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self.requests: deque = deque()
        self._lock = Lock()

    def allow(self) -> bool:
        with self._lock:
            now = time.time()
            cutoff = now - self.window_seconds

            while (
                self.requests and
                self.requests[0] < cutoff
            ):
                self.requests.popleft()

            if len(self.requests) < self.max_requests:
                self.requests.append(now)
                return True

            return False


# Uso
limiter = TokenBucket(
    rate=10,
    capacity=20
)

for i in range(25):
    if limiter.acquire():
        print(f"Request {i + 1}: ✓ Permitido")
    else:
        print(f"Request {i + 1}: ✗ Rate limited")

# ==========================================================
# Fim do módulo PYENG-06
# ==========================================================
#
# Resumo
# ----------------------------------------------------------
# Neste módulo você aprendeu como implementar Rate Limiting
# utilizando Token Bucket e Sliding Window para proteger
# aplicações contra excesso de requisições e melhorar sua
# disponibilidade.
#
# Próximo módulo
# ----------------------------------------------------------
# PYENG-07 — Graceful Shutdown
#
# POLYDEV | Python Engineering v1.0
#
# Leia • Entenda • Execute seu código.
# ==========================================================