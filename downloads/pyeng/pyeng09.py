#!/usr/bin/env python3
# ==========================================================
# POLYDEV | Python Engineering
# ==========================================================
#
# Série:
# Python Engineering v1.0
#
# PYENG-09 — Logging Estruturado
#
# Tecnologia:
# Python 3.12+
#
# Categoria:
# Observabilidade • Engenharia de Software
#
# Objetivo
# ----------------------------------------------------------
# Implementar um sistema de Logging Estruturado utilizando
# JSON para registrar eventos da aplicação de forma
# padronizada, facilitando auditoria, monitoramento e
# integração com plataformas de observabilidade.
#
# O que é Logging Estruturado?
# ----------------------------------------------------------
# Logging Estruturado consiste em registrar eventos da
# aplicação utilizando um formato padronizado, normalmente
# JSON, permitindo que ferramentas de monitoramento e
# observabilidade interpretem automaticamente cada campo.
#
# Diferente do log textual tradicional, cada informação é
# armazenada como um atributo independente, facilitando
# pesquisas, filtros e geração de métricas.
#
# Quando utilizar
# ----------------------------------------------------------
# • APIs REST
# • Microsserviços
# • Kubernetes
# • Sistemas Distribuídos
# • Auditoria
# • Observabilidade
#
# Problema resolvido
# ----------------------------------------------------------
# Facilita o diagnóstico de problemas, rastreamento de
# requisições e integração com plataformas como ELK,
# Grafana, Loki, Datadog e OpenTelemetry.
#
# Fluxo de execução
# ----------------------------------------------------------
#
#         Aplicação
#              │
#              ▼
#      Structured Logger
#              │
#              ▼
#       JSON Formatter
#              │
#              ▼
#      Console / Arquivo
#              │
#              ▼
# Plataforma Observability
#
# Principais componentes
# ----------------------------------------------------------
# • logging
# • JSON
# • ContextVar
# • Formatter
# • Request ID
#
# Resultado esperado
# ----------------------------------------------------------
# Produzir logs estruturados contendo informações completas
# sobre cada operação executada pela aplicação.
#
# Observações
# ----------------------------------------------------------
# Este exemplo foi desenvolvido para fins educacionais.
# Em ambientes de produção recomenda-se integração com
# OpenTelemetry, Elastic Stack, Loki ou outra plataforma
# centralizada de observabilidade.
#
# ==========================================================
# Implementação
# ==========================================================

import json
import logging
import time
import uuid
from contextvars import ContextVar
from typing import Any, Dict

# Context variable para request_id
request_id_var: ContextVar[str] = ContextVar('request_id', default='')


class StructuredFormatter(logging.Formatter):
    """Formatter que gera logs em JSON estruturado."""

    def format(self, record: logging.LogRecord) -> str:
        log_entry = {
            "timestamp": self.formatTime(record),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
            "request_id": request_id_var.get(''),
            "module": record.module,
            "function": record.funcName,
            "line": record.lineno,
        }

        # Adiciona campos extras
        if hasattr(record, 'extra_fields'):
            log_entry.update(record.extra_fields)

        if record.exc_info:
            log_entry["exception"] = self.formatException(
                record.exc_info
            )

        return json.dumps(log_entry, ensure_ascii=False)


class StructuredLogger:
    """Logger estruturado com contexto."""

    def __init__(self, name: str):
        self.logger = logging.getLogger(name)
        self.logger.setLevel(logging.DEBUG)

        handler = logging.StreamHandler()
        handler.setFormatter(StructuredFormatter())
        self.logger.addHandler(handler)

    def info(self, msg: str, **kwargs):
        self._log(logging.INFO, msg, kwargs)

    def error(self, msg: str, **kwargs):
        self._log(logging.ERROR, msg, kwargs)

    def _log(self, level: int, msg: str, extra: Dict[str, Any]):
        record = self.logger.makeRecord(
            self.logger.name,
            level,
            "",
            0,
            msg,
            (),
            None
        )

        record.extra_fields = extra
        self.logger.handle(record)


# Uso
log = StructuredLogger("polydev.api")

request_id_var.set(str(uuid.uuid4())[:8])

log.info(
    "Request recebido",
    path="/api/users",
    method="GET"
)

log.info(
    "Query executada",
    table="users",
    duration_ms=12.5
)

# ==========================================================
# Fim do módulo PYENG-09
# ==========================================================
#
# Resumo
# ----------------------------------------------------------
# Neste módulo você aprendeu como implementar Logging
# Estruturado utilizando JSON, ContextVar e Request ID para
# produzir logs padronizados e preparados para plataformas
# modernas de observabilidade.
#
# Próximo módulo
# ----------------------------------------------------------
# PYENG-10 — Configuração Profissional com ENV
#
# POLYDEV | Python Engineering v1.0
#
# Leia • Entenda • Execute seu código.
# ==========================================================