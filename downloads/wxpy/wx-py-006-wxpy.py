"""
PYTHON06 - Event Emitter (Sistema de Eventos)
===============================================
Sistema pub/sub para desacoplamento de componentes.
"""

import asyncio
import threading
from typing import Any, Callable
from collections import defaultdict


class EventEmitter:
    def __init__(self) -> None:
        self._listeners: dict[str, list[dict[str, Any]]] = defaultdict(list)
        self._lock = threading.Lock()
        self._event_count: dict[str, int] = defaultdict(int)

    def on(self, event: str, handler: Callable, *, priority: int = 0, once: bool = False) -> Callable:
        with self._lock:
            self._listeners[event].append({"handler": handler, "priority": priority, "once": once})
            self._listeners[event].sort(key=lambda x: x["priority"], reverse=True)
        return handler

    def once(self, event: str, handler: Callable, **kwargs: Any) -> Callable:
        return self.on(event, handler, once=True, **kwargs)

    def off(self, event: str, handler: Callable | None = None) -> None:
        with self._lock:
            if handler is None:
                self._listeners.pop(event, None)
            else:
                self._listeners[event] = [e for e in self._listeners[event] if e["handler"] is not handler]

    def emit(self, event: str, *args: Any, **kwargs: Any) -> int:
        with self._lock:
            listeners = list(self._listeners.get(event, []))
            wildcard = list(self._listeners.get("*", []))
            self._event_count[event] += 1
        executed = 0
        to_remove = []
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
            except Exception:
                pass
            if entry["once"]:
                source = event if entry in listeners else "*"
                to_remove.append((source, entry))
        with self._lock:
            for ev, entry in to_remove:
                if entry in self._listeners.get(ev, []):
                    self._listeners[ev].remove(entry)
        return executed

    def listener_count(self, event: str) -> int:
        return len(self._listeners.get(event, []))

    @property
    def stats(self) -> dict[str, Any]:
        return {
            "eventos_registrados": list(self._listeners.keys()),
            "contagem_emissoes": dict(self._event_count),
            "total_listeners": sum(len(v) for v in self._listeners.values()),
        }


# ===================== EXEMPLO DE USO =====================
#
# emitter = EventEmitter()
#
# @emitter.on("usuario:criado", priority=10)
# def enviar_email(usuario: dict):
#     print(f"Email enviado para {usuario['email']}")
#
# emitter.emit("usuario:criado", {"nome": "Ana", "email": "ana@ex.com"})
