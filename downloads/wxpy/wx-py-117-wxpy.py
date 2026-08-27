#!/usr/bin/env python3
# ==========================================================
# POLYDEV | Python Engineering
# ==========================================================
#
# Série:
# Python Engineering v1.0
#
# PYENG-05 — Cache TTL Profissional
#
# Tecnologia:
# Python 3.12+
#
# Categoria:
# Performance • Engenharia de Software
#
# Objetivo
# ----------------------------------------------------------
# Implementar um cache em memória utilizando TTL (Time To
# Live), permitindo armazenar informações temporariamente,
# reduzindo acessos repetitivos a APIs, bancos de dados e
# serviços externos.
#
# O que é um Cache TTL?
# ----------------------------------------------------------
# Cache TTL é um mecanismo utilizado para armazenar dados
# durante um período determinado.
#
# Após o tempo de expiração, o item é automaticamente
# considerado inválido, garantindo que informações antigas
# não permaneçam disponíveis indefinidamente.
#
# Quando utilizar
# ----------------------------------------------------------
# • APIs REST
# • Bancos de Dados
# • Microsserviços
# • Consultas Frequentes
# • Configurações
# • Sessões Temporárias
#
# Problema resolvido
# ----------------------------------------------------------
# Reduz chamadas repetitivas para recursos externos,
# melhora o desempenho da aplicação e diminui consumo de
# rede e processamento.
#
# Fluxo de execução
# ----------------------------------------------------------
#
#         Requisição
#              │
#              ▼
#      +---------------+
#      |   Cache TTL   |
#      +---------------+
#         │         │
#         │         │
#      HIT        MISS
#         │         │
#         ▼         ▼
#    Retorna     Busca Origem
#    do Cache         │
#                     ▼
#             Atualiza Cache
#
# Principais componentes
# ----------------------------------------------------------
# • OrderedDict
# • Dataclass
# • TTL (Time To Live)
# • LRU (Least Recently Used)
# • Estatísticas de Cache
#
# Resultado esperado
# ----------------------------------------------------------
# Armazenar dados temporariamente com expiração automática,
# melhorando desempenho e reduzindo chamadas desnecessárias.
#
# Observações
# ----------------------------------------------------------
# Este exemplo foi desenvolvido para fins educacionais.
# Em ambientes de produção recomenda-se integrar métricas,
# monitoramento, persistência distribuída e políticas de
# invalidação conforme a necessidade da aplicação.
#
# ==========================================================
# Implementação
# ==========================================================

import time
from collections import OrderedDict
from typing import Any, Optional
from dataclasses import dataclass


@dataclass
class CacheEntry:
    value: Any
    expires_at: float
    hits: int = 0


class TTLCache:
    def __init__(self, max_size: int = 1000, default_ttl: int = 300):
        self.max_size = max_size
        self.default_ttl = default_ttl
        self._store: OrderedDict[str, CacheEntry] = OrderedDict()
        self._hits = 0
        self._misses = 0

    def get(self, key: str) -> Optional[Any]:
        """Busca valor no cache com verificação de TTL."""
        if key not in self._store:
            self._misses += 1
            return None

        entry = self._store[key]

        if time.time() > entry.expires_at:
            del self._store[key]
            self._misses += 1
            return None

        entry.hits += 1
        self._hits += 1
        self._store.move_to_end(key)

        return entry.value

    def set(self, key: str, value: Any, ttl: Optional[int] = None):
        """Armazena valor com TTL."""
        if len(self._store) >= self.max_size:
            self._store.popitem(last=False)

        expires_at = time.time() + (ttl or self.default_ttl)

        self._store[key] = CacheEntry(
            value=value,
            expires_at=expires_at
        )

    def invalidate(self, key: str):
        """Remove entrada do cache."""
        self._store.pop(key, None)

    @property
    def stats(self) -> dict:
        total = self._hits + self._misses

        return {
            "size": len(self._store),
            "hits": self._hits,
            "misses": self._misses,
            "hit_rate":
                f"{(self._hits / total * 100):.1f}%"
                if total else "0%"
        }


# Uso
cache = TTLCache(
    max_size=100,
    default_ttl=60
)

cache.set(
    "user:123",
    {"nome": "Ana", "role": "admin"},
    ttl=120
)

user = cache.get("user:123")

print(f"User: {user}")
print(f"Stats: {cache.stats}")

# ==========================================================
# Fim do módulo PYENG-05
# ==========================================================
#
# Resumo
# ----------------------------------------------------------
# Neste módulo você aprendeu como implementar um Cache TTL
# profissional com expiração automática, estatísticas de uso
# e política LRU para otimizar o desempenho de aplicações.
#
# Próximo módulo
# ----------------------------------------------------------
# PYENG-06 — Rate Limiter
#
# POLYDEV | Python Engineering v1.0
#
# Leia • Entenda • Execute seu código.
# ==========================================================