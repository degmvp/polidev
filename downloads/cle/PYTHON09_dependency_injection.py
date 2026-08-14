"""
PYTHON09 - Dependency Injection Container (Injeção de Dependência)
===================================================================
Container IoC (Inversão de Controle) para gerenciar dependências
em aplicações Python. Suporta singleton, factory, e escopos.
Facilita testes e desacoplamento entre componentes.
"""

import inspect
import threading
from typing import Any, Callable, TypeVar, Type, get_type_hints

T = TypeVar("T")


class DependencyError(Exception):
    """Erro de resolução de dependência."""
    pass


class Container:
    """
    Container de Injeção de Dependência.

    Registra e resolve dependências automaticamente com suporte a:
    - Singleton: uma única instância compartilhada
    - Factory: nova instância a cada resolução
    - Instância: valor fixo pré-construído
    - Auto-wiring: resolução automática via type hints
    """

    def __init__(self) -> None:
        self._bindings: dict[type | str, dict[str, Any]] = {}
        self._singletons: dict[type | str, Any] = {}
        self._lock = threading.Lock()

    def singleton(
        self, abstract: type | str, concrete: type | Callable | None = None
    ) -> "Container":
        """
        Registra um binding singleton (uma instância compartilhada).

        Args:
            abstract: Tipo ou nome do serviço.
            concrete: Classe ou factory para criar a instância.
        """
        self._bindings[abstract] = {
            "concrete": concrete or abstract,
            "scope": "singleton",
        }
        return self

    def factory(
        self, abstract: type | str, concrete: type | Callable | None = None
    ) -> "Container":
        """
        Registra um binding factory (nova instância a cada resolução).

        Args:
            abstract: Tipo ou nome do serviço.
            concrete: Classe ou factory para criar a instância.
        """
        self._bindings[abstract] = {
            "concrete": concrete or abstract,
            "scope": "factory",
        }
        return self

    def instance(self, abstract: type | str, obj: Any) -> "Container":
        """
        Registra uma instância pronta.

        Args:
            abstract: Tipo ou nome do serviço.
            obj: Instância a ser retornada nas resoluções.
        """
        self._bindings[abstract] = {"concrete": None, "scope": "instance"}
        self._singletons[abstract] = obj
        return self

    def resolve(self, abstract: type | str) -> Any:
        """
        Resolve uma dependência pelo tipo ou nome.

        Args:
            abstract: Tipo ou nome do serviço a resolver.

        Returns:
            Instância do serviço.

        Raises:
            DependencyError: Se a dependência não estiver registrada.
        """
        with self._lock:
            if abstract not in self._bindings:
                # Tenta auto-wiring para classes concretas
                if isinstance(abstract, type):
                    return self._auto_wire(abstract)
                raise DependencyError(
                    f"Dependência não registrada: {abstract}"
                )

            binding = self._bindings[abstract]

            if binding["scope"] == "instance":
                return self._singletons[abstract]

            if binding["scope"] == "singleton":
                if abstract not in self._singletons:
                    self._singletons[abstract] = self._build(
                        binding["concrete"]
                    )
                return self._singletons[abstract]

            # factory
            return self._build(binding["concrete"])

    def _build(self, concrete: type | Callable) -> Any:
        """Constrói uma instância resolvendo dependências do construtor."""
        if not callable(concrete):
            return concrete

        return self._auto_wire(concrete)

    def _auto_wire(self, cls_or_func: type | Callable) -> Any:
        """Resolve automaticamente parâmetros via type hints."""
        try:
            hints = get_type_hints(
                cls_or_func.__init__ if isinstance(cls_or_func, type) else cls_or_func
            )
        except Exception:
            hints = {}

        sig = inspect.signature(
            cls_or_func.__init__ if isinstance(cls_or_func, type) else cls_or_func
        )

        kwargs: dict[str, Any] = {}
        for name, param in sig.parameters.items():
            if name == "self":
                continue
            if name in hints and hints[name] in self._bindings:
                kwargs[name] = self.resolve(hints[name])
            elif param.default is not inspect.Parameter.empty:
                continue
            else:
                raise DependencyError(
                    f"Não é possível resolver '{name}' para {cls_or_func}"
                )

        return cls_or_func(**kwargs)

    def has(self, abstract: type | str) -> bool:
        """Verifica se uma dependência está registrada."""
        return abstract in self._bindings

    def reset(self) -> None:
        """Remove todos os bindings e singletons."""
        with self._lock:
            self._bindings.clear()
            self._singletons.clear()

    def __contains__(self, item: type | str) -> bool:
        return self.has(item)

    def __getitem__(self, item: type | str) -> Any:
        return self.resolve(item)


# ===================== EXEMPLO DE USO =====================
#
# from abc import ABC, abstractmethod
#
# # Definir interfaces
# class DatabasePort(ABC):
#     @abstractmethod
#     def query(self, sql: str) -> list: ...
#
# class CachePort(ABC):
#     @abstractmethod
#     def get(self, key: str) -> Any: ...
#
# # Implementações concretas
# class PostgresDatabase(DatabasePort):
#     def query(self, sql: str) -> list:
#         return [{"id": 1, "nome": "teste"}]
#
# class RedisCache(CachePort):
#     def get(self, key: str) -> Any:
#         return None
#
# # Serviço que depende das interfaces
# class UserService:
#     def __init__(self, db: DatabasePort, cache: CachePort):
#         self.db = db
#         self.cache = cache
#
#     def get_user(self, user_id: int) -> dict:
#         cached = self.cache.get(f"user:{user_id}")
#         if cached:
#             return cached
#         return self.db.query(f"SELECT * FROM users WHERE id={user_id}")[0]
#
# # Configurar container
# container = Container()
# container.singleton(DatabasePort, PostgresDatabase)
# container.singleton(CachePort, RedisCache)
# container.factory(UserService, UserService)  # auto-wiring resolve db e cache
#
# # Resolver
# service = container.resolve(UserService)
# print(service.get_user(1))
# >>> {'id': 1, 'nome': 'teste'}
