"""
wx-py-011-wxpy.py
Retry com backoff exponencial e jitter

Para que serve:
    Decorator que tenta executar uma função várias vezes quando ela
    levanta exceções, aplicando um atraso crescente (backoff exponencial)
    e um fator aleatório (jitter) para evitar picos de retry simultâneos.

Exemplo de uso:
    @retry(tentativas=3, atraso_inicial=0.1)
    def chamada_instavel():
        ...
"""

import random
import time
from functools import wraps


def retry(tentativas=3, atraso_inicial=0.5, fator=2.0, excecoes=(Exception,)):
    """Tenta a função novamente em caso de erro.

    Args:
        tentativas: número máximo de execuções.
        atraso_inicial: atraso (s) da primeira espera.
        fator: multiplicador do atraso a cada tentativa.
        excecoes: tupla de exceções que disparam o retry.
    """
    def decorador(funcao):
        @wraps(funcao)
        def interno(*args, **kwargs):
            atraso = atraso_inicial
            for tentativa in range(1, tentativas + 1):
                try:
                    return funcao(*args, **kwargs)
                except excecoes as erro:
                    if tentativa == tentativas:
                        raise
                    espera = atraso * random.uniform(0.5, 1.5)  # jitter
                    print(f"[retry] tentativa {tentativa} falhou: {erro}. "
                          f"Aguardando {espera:.2f}s...")
                    time.sleep(espera)
                    atraso *= fator
        return interno
    return decorador


if __name__ == "__main__":
    tentativa = {"n": 0}

    @retry(tentativas=3, atraso_inicial=0.1)
    def chamada_instavel():
        tentativa["n"] += 1
        if tentativa["n"] < 3:
            raise ConnectionError("erro temporário de rede")
        return "sucesso!"

    print(chamada_instavel())
