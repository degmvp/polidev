"""
wx-py-012-wxpy.py
Cache em memória com TTL (tempo de vida)

Para que serve:
    Decorator que guarda o resultado de uma função em memória por um
    período (TTL), evitando recomputações e chamadas repetidas à API.
    É thread-safe, usando uma trava por função.

Exemplo de uso:
    @ttl_cache(ttl_segundos=5)
    def buscar_usuario(usuario_id):
        ...
"""

import threading
import time
from functools import wraps


def ttl_cache(ttl_segundos=60, max_itens=1024):
    """Cacheia resultados de uma função com tempo de vida (TTL)."""
    def decorador(funcao):
        cache = {}
        trava = threading.Lock()

        @wraps(funcao)
        def interno(*args, **kwargs):
            chave = (args, tuple(sorted(kwargs.items())))
            agora = time.monotonic()
            with trava:
                if chave in cache:
                    valor, expira_em = cache[chave]
                    if agora < expira_em:
                        return valor
                    del cache[chave]
                resultado = funcao(*args, **kwargs)
                if len(cache) >= max_itens:
                    cache.clear()
                cache[chave] = (resultado, agora + ttl_segundos)
                return resultado
        return interno
    return decorador


if __name__ == "__main__":
    @ttl_cache(ttl_segundos=2)
    def preco_produto(produto_id):
        print(f"calculando preço do produto {produto_id}...")
        return produto_id * 10

    print(preco_produto(1))  # calcula
    print(preco_produto(1))  # vem do cache
    time.sleep(2.1)
    print(preco_produto(1))  # expirou, calcula de novo
