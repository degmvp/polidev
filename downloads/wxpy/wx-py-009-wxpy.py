"""
PYTHON09 - Dependency Injection Container
===================================================================
Container IoC para gerenciar dependências em aplicações Python.
Suporta singleton, factory, e auto-wiring via type hints.
"""

import inspect
import threading
from typing import Any, Callable, TypeVar, get_type_hints

T = TypeVar("T")


class DependencyError(Exception):
    pass


class Container:
    def __init__(self) -> None:
        self._bindings: dict[type | str, dict[str, Any]] = {}
        self._singletons: dict[type | str, Any] = {}
        self._lock = threading.Lock()

    def singleton(self, abstract: type | str, concrete: type | Callable | None = None) -> "Container":
        self._bindings[abstract] = {"concrete": concrete or abstract, "scope": "singleton"}
        return self

    def factory(self, abstract: type | str, concrete: type | Callable | None = None) -> "Container":
        self._bindings[abstract] = {"concrete": concrete or abstract, "scope": "factory"}
        return self

    def instance(self, abstract: type | str, obj: Any) -> "Container":
        self._bindings[abstract] = {"concrete": None, "scope": "instance"}
        self._singletons[abstract] = obj
        return self

    def resolve(self, abstract: type | str) -> Any:
        with self._lock:
            if abstract not in self._bindings:
                if isinstance(abstract, type):
                    return self._auto_wire(abstract)
                raise DependencyError(f"Dependência não registrada: {abstract}")
            binding = self._bindings[abstract]
            if binding["scope"] == "instance":
                return self._singletons[abstract]
            if binding["scope"] == "singleton":
                if abstract not in self._singletons:
                    self._singletons[abstract] = self._build(binding["concrete"])
                return self._singletons[abstract]
            return self._build(binding["concrete"])

    def _build(self, concrete: type | Callable) -> Any:
        if not callable(concrete):
            return concrete
        return self._auto_wire(concrete)

    def _auto_wire(self, cls_or_func: type | Callable) -> Any:
        try:
            hints = get_type_hints(cls_or_func.__init__ if isinstance(cls_or_func, type) else cls_or_func)
        except Exception:
            hints = {}
        sig = inspect.signature(cls_or_func.__init__ if isinstance(cls_or_func, type) else cls_or_func)
        kwargs: dict[str, Any] = {}
        for name, param in sig.parameters.items():
            if name == "self":
                continue
            if name in hints and hints[name] in self._bindings:
                kwargs[name] = self.resolve(hints[name])
            elif param.default is not inspect.Parameter.empty:
                continue
            else:
                raise DependencyError(f"Não é possível resolver '{name}' para {cls_or_func}")
        return cls_or_func(**kwargs)

    def has(self, abstract: type | str) -> bool:
        return abstract in self._bindings

    def reset(self) -> None:
        with self._lock:
            self._bindings.clear()
            self._singletons.clear()

    def __contains__(self, item): return self.has(item)
    def __getitem__(self, item): return self.resolve(item)


# ===================== EXEMPLO DE USO =====================
#
# from abc import ABC, abstractmethod
#
# class DatabasePort(ABC):
#     @abstractmethod
#     def query(self, sql: str) -> list: ...
#
# class PostgresDatabase(DatabasePort):
#     def query(self, sql: str) -> list:
#         return [{"id": 1, "nome": "teste"}]
#
# container = Container()
# container.singleton(DatabasePort, PostgresDatabase)
# db = container.resolve(DatabasePort)
# print(db.query("SELECT * FROM users"))
