"""
PYTHON06 - Event Emitter (Sistema de Eventos)
===============================================
Sistema pub/sub para desacoplamento de componentes.
Permite registrar listeners, emitir eventos com dados,
e gerenciar ciclo de vida dos handlers.
"""

import asyncio
import functools
import threading
from typing import Any, Callable
from collections import defaultdict


class EventEmitter:
    """
    Sistema de eventos thread-safe com suporte sync e async.

    Recursos:
    - Registro de múltiplos listeners por evento
    - Listeners one-shot (executam uma vez e são removidos)
    - Wildcards com '*' para capturar todos os eventos
    - Suporte a listeners assíncronos
    - Prioridade de execução
    """

    def __init__(self) -> None:
        self._listeners: dict[str, list[dict[str, Any]]] = defaultdict(list)
        self._lock = threading.Lock()
        self._event_count: dict[str, int] = defaultdict(int)

    def on(
        self,
        event: str,
        handler: Callable,
        *,
        priority: int = 0,
        once: bool = False,
    ) -> Callable:
        """
        Registra um listener para um evento.

        Args:
            event: Nome do evento.
            handler: Função a ser chamada quando o evento for emitido.
            priority: Prioridade (maior = executa primeiro).
            once: Se True, remove o listener após primeira execução.

        Returns:
            O handler original (permite uso como decorator).
        """
        with self._lock:
            self._listeners[event].append({
                "handler": handler,
                "priority": priority,
                "once": once,
            })
            self._listeners[event].sort(
                key=lambda x: x["priority"], reverse=True
            )
        return handler

    def once(self, event: str, handler: Callable, **kwargs: Any) -> Callable:
        """Atalho para on(event, handler, once=True)."""
        return self.on(event, handler, once=True, **kwargs)

    def off(self, event: str, handler: Callable | None = None) -> None:
        """
        Remove listener(s) de um evento.

        Args:
            event: Nome do evento.
            handler: Handler específico a remover. Se None, remove todos.
        """
        with self._lock:
            if handler is None:
                self._listeners.pop(event, None)
            else:
                self._listeners[event] = [
                    entry
                    for entry in self._listeners[event]
                    if entry["handler"] is not handler
                ]

    def emit(self, event: str, *args: Any, **kwargs: Any) -> int:
        """
        Emite um evento, chamando todos os listeners registrados.

        Args:
            event: Nome do evento.
            *args, **kwargs: Dados passados aos listeners.

        Returns:
            Número de listeners executados.
        """
        with self._lock:
            listeners = list(self._listeners.get(event, []))
            wildcard = list(self._listeners.get("*", []))
            self._event_count[event] += 1

        executed = 0
        to_remove: list[tuple[str, dict]] = []

        for entry in listeners + wildcard:
            try:
                result = entry["handler"](*args, **kwargs)
                if asyncio.iscoroutine(result):
                    try:
                        loop = asyncio.get_running_loop()
                        loop.create_task(result)
                    except RuntimeError:
                        asyncio.run(result)
                executed += 1
            except Exception as e:
                import logging
                logging.getLogger(__name__).error(
                    f"Erro no listener de '{event}': {e}"
                )

            if entry["once"]:
                source = event if entry in listeners else "*"
                to_remove.append((source, entry))

        with self._lock:
            for ev, entry in to_remove:
                if entry in self._listeners.get(ev, []):
                    self._listeners[ev].remove(entry)

        return executed

    def listener_count(self, event: str) -> int:
        """Retorna o número de listeners para um evento."""
        return len(self._listeners.get(event, []))

    @property
    def stats(self) -> dict[str, Any]:
        """Estatísticas de eventos."""
        return {
            "eventos_registrados": list(self._listeners.keys()),
            "contagem_emissoes": dict(self._event_count),
            "total_listeners": sum(
                len(v) for v in self._listeners.values()
            ),
        }


# ===================== EXEMPLO DE USO =====================
#
# emitter = EventEmitter()
#
# # Registrar listeners
# @emitter.on("usuario:criado", priority=10)
# def enviar_email_boas_vindas(usuario: dict):
#     print(f"📧 Email enviado para {usuario['email']}")
#
# @emitter.on("usuario:criado", priority=5)
# def registrar_analytics(usuario: dict):
#     print(f"📊 Analytics: novo usuário {usuario['nome']}")
#
# # Listener one-shot
# emitter.once("usuario:criado", lambda u: print(f"🎉 Primeiro usuário!"))
#
# # Wildcard (captura tudo)
# emitter.on("*", lambda *a, **kw: print(f"[LOG] Evento emitido"))
#
# # Emitir evento
# emitter.emit("usuario:criado", {"nome": "Ana", "email": "ana@ex.com"})
# >>> [LOG] Evento emitido
# >>> 📧 Email enviado para ana@ex.com
# >>> 📊 Analytics: novo usuário Ana
# >>> 🎉 Primeiro usuário!
#
# print(emitter.stats)
