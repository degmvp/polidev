#!/usr/bin/env python3
# ==========================================================
# POLYDEV | Python Engineering
# ==========================================================
#
# Série:
# Python Engineering v1.0
#
# PYENG-07 — Graceful Shutdown
#
# Tecnologia:
# Python 3.12+
#
# Categoria:
# Disponibilidade • Engenharia de Software
#
# Objetivo
# ----------------------------------------------------------
# Implementar um mecanismo de Graceful Shutdown para
# encerrar aplicações de forma segura, permitindo concluir
# tarefas em execução, liberar recursos e executar rotinas
# de limpeza antes do término do processo.
#
# O que é Graceful Shutdown?
# ----------------------------------------------------------
# Graceful Shutdown é um padrão utilizado para finalizar uma
# aplicação de maneira controlada após o recebimento de um
# sinal de encerramento do sistema operacional.
#
# Antes de finalizar o processo, a aplicação aguarda a
# conclusão das tarefas ativas e executa procedimentos de
# limpeza, evitando perda de dados e inconsistências.
#
# Quando utilizar
# ----------------------------------------------------------
# • APIs REST
# • Microsserviços
# • Workers
# • Processamento em Lote
# • Kubernetes
# • Docker
#
# Problema resolvido
# ----------------------------------------------------------
# Evita encerramentos abruptos que podem interromper tarefas,
# corromper dados ou deixar conexões abertas durante a
# finalização da aplicação.
#
# Fluxo de execução
# ----------------------------------------------------------
#
#      Aplicação Executando
#               │
#               ▼
#        Recebe SIGTERM
#               │
#               ▼
#      Aguarda Tasks Ativas
#               │
#               ▼
#      Executa Cleanup
#               │
#               ▼
#      Finaliza Processo
#
# Principais componentes
# ----------------------------------------------------------
# • signal
# • threading.Lock
# • Cleanup Handlers
# • Timeout
# • Controle de Tasks
#
# Resultado esperado
# ----------------------------------------------------------
# Encerrar aplicações de forma segura, garantindo que
# tarefas críticas sejam concluídas e recursos liberados
# corretamente antes do término do processo.
#
# Observações
# ----------------------------------------------------------
# Este exemplo foi desenvolvido para fins educacionais.
# Em ambientes de produção recomenda-se integrar logging,
# monitoramento, métricas e mecanismos de health check.
#
# ==========================================================
# Implementação
# ==========================================================

import signal
import sys
import time
import threading
from typing import Callable, List


class GracefulShutdown:
    """Gerencia encerramento elegante da aplicação."""

    def __init__(self, timeout: int = 30):
        self.timeout = timeout
        self.is_shutting_down = False
        self._cleanup_handlers: List[Callable] = []
        self._active_tasks = 0
        self._lock = threading.Lock()

        signal.signal(signal.SIGTERM, self._signal_handler)
        signal.signal(signal.SIGINT, self._signal_handler)

    def register_cleanup(self, handler: Callable):
        """Registra handler de cleanup."""
        self._cleanup_handlers.append(handler)

    def task_started(self):
        with self._lock:
            self._active_tasks += 1

    def task_completed(self):
        with self._lock:
            self._active_tasks -= 1

    def _signal_handler(self, signum, frame):
        signal_name = signal.Signals(signum).name
        print(f"\n[Shutdown] Sinal {signal_name} recebido.")
        self.is_shutting_down = True
        self._graceful_stop()

    def _graceful_stop(self):
        print(
            f"[Shutdown] Aguardando {self._active_tasks} "
            f"tasks ativas (timeout: {self.timeout}s)..."
        )

        start = time.time()

        while self._active_tasks > 0:
            if time.time() - start > self.timeout:
                print("[Shutdown] Timeout! Forçando encerramento.")
                break

            time.sleep(0.1)

        print("[Shutdown] Executando cleanup handlers...")

        for handler in reversed(self._cleanup_handlers):
            try:
                handler()
            except Exception as e:
                print(f"[Shutdown] Erro no cleanup: {e}")

        print("[Shutdown] Encerramento completo.")
        sys.exit(0)


# Uso
app = GracefulShutdown(timeout=10)


def close_database():
    print("  → Fechando conexões do banco...")


def flush_logs():
    print("  → Flush dos logs...")


app.register_cleanup(close_database)
app.register_cleanup(flush_logs)

print("Aplicação rodando. Pressione Ctrl+C para encerrar.")

# while not app.is_shutting_down:
#     time.sleep(1)

# ==========================================================
# Fim do módulo PYENG-07
# ==========================================================
#
# Resumo
# ----------------------------------------------------------
# Neste módulo você aprendeu como implementar Graceful
# Shutdown utilizando sinais do sistema operacional para
# finalizar aplicações de forma segura e organizada.
#
# Próximo módulo
# ----------------------------------------------------------
# PYENG-08 — Processamento Assíncrono com AsyncIO
#
# POLYDEV | Python Engineering v1.0
#
# Leia • Entenda • Execute seu código.
# ==========================================================