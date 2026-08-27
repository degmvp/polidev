#!/usr/bin/env python3
# ==========================================================
# POLYDEV | Python Engineering
# ==========================================================
#
# Série:
# Python Engineering v1.0
#
# PYENG-03 — Retry com Backoff Exponencial
#
# Tecnologia:
# Python 3.12+
#
# Categoria:
# Resiliência • Engenharia de Software
#
# Objetivo
# ----------------------------------------------------------
# Implementar um mecanismo automático de Retry utilizando
# Backoff Exponencial para aumentar a confiabilidade de
# operações sujeitas a falhas temporárias, como chamadas
# HTTP, APIs, bancos de dados e serviços distribuídos.
#
# O que é Retry com Backoff Exponencial?
# ----------------------------------------------------------
# Retry é um padrão utilizado para repetir automaticamente
# operações que falharam devido a erros transitórios.
#
# Em vez de tentar novamente imediatamente, o algoritmo
# aumenta progressivamente o intervalo entre as tentativas,
# reduzindo carga sobre o serviço e aumentando a chance de
# recuperação.
#
# Quando utilizar
# ----------------------------------------------------------
# • APIs REST
# • Microsserviços
# • Bancos de Dados
# • Filas de Mensagens
# • Serviços em Nuvem
# • Comunicação Distribuída
#
# Problema resolvido
# ----------------------------------------------------------
# Evita falhas causadas por indisponibilidade momentânea,
# reduz tentativas excessivas e melhora a estabilidade das
# aplicações em ambientes distribuídos.
#
# Fluxo de execução
# ----------------------------------------------------------
#
#        Requisição
#             │
#             ▼
#      Operação Executada
#             │
#      ┌──────┴──────┐
#      │             │
#   Sucesso       Falhou
#      │             │
#      ▼             ▼
#  Resultado     Aguarda Delay
#                    │
#                    ▼
#             Nova Tentativa
#                    │
#                    ▼
#            Máximo de Retries
#
# Principais componentes
# ----------------------------------------------------------
# • Decorators
# • functools.wraps
# • Backoff Exponencial
# • Jitter Aleatório
# • Tratamento de Exceções
#
# Resultado esperado
# ----------------------------------------------------------
# Executar automaticamente novas tentativas utilizando
# atrasos progressivos, aumentando a resiliência da
# aplicação diante de falhas temporárias.
#
# Observações
# ----------------------------------------------------------
# Este exemplo foi desenvolvido para fins educacionais.
# Em ambientes de produção recomenda-se integrar logging,
# métricas, monitoramento e políticas específicas para cada
# tipo de exceção.
#
# ==========================================================
# Implementação
# ==========================================================

import time
import random
from functools import wraps
from typing import Tuple, Type


def retry(
    max_attempts: int = 3,
    base_delay: float = 1.0,
    max_delay: float = 60.0,
    exceptions: Tuple[Type[Exception], ...] = (Exception,),
    jitter: bool = True
):
    """Decorator de retry com backoff exponencial."""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(1, max_attempts + 1):
                try:
                    return func(*args, **kwargs)
                except exceptions as e:
                    if attempt == max_attempts:
                        raise

                    delay = min(
                        base_delay * (2 ** (attempt - 1)),
                        max_delay
                    )

                    if jitter:
                        delay *= random.uniform(0.5, 1.5)

                    print(
                        f"[Retry {attempt}/{max_attempts}] "
                        f"Erro: {e}. "
                        f"Aguardando {delay:.2f}s..."
                    )

                    time.sleep(delay)

        return wrapper

    return decorator


# Uso
@retry(
    max_attempts=5,
    base_delay=0.5,
    exceptions=(ConnectionError,)
)
def fetch_api(url: str) -> dict:
    """Simula chamada a API externa."""
    if random.random() < 0.7:
        raise ConnectionError("Timeout na conexão")

    return {
        "status": "success",
        "data": [1, 2, 3]
    }


resultado = fetch_api(
    "https://api.exemplo.com/dados"
)

print(f"Sucesso: {resultado}")

# ==========================================================
# Fim do módulo PYENG-03
# ==========================================================
#
# Resumo
# ----------------------------------------------------------
# Neste módulo você aprendeu como implementar Retry com
# Backoff Exponencial utilizando decorators para tornar
# aplicações mais resilientes diante de falhas temporárias
# em APIs, bancos de dados e serviços distribuídos.
#
# Próximo módulo
# ----------------------------------------------------------
# PYENG-04 — Circuit Breaker
#
# POLYDEV | Python Engineering v1.0
#
# Leia • Entenda • Execute seu código.
# ==========================================================