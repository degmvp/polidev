"""
wx-py-013-wxpy.py
Rate limit (limite de chamadas por intervalo)

Para que serve:
    Decorator que limita quantas vezes uma função pode ser chamada em
    um intervalo de tempo, usando a técnica de janela deslizante. Útil
    para respeitar limites de APIs e evitar sobrecarga do serviço.

Exemplo de uso:
    @rate_limit(chamadas=5, intervalo=60)
    def enviar_mensagem(...):
        ...
"""

import threading
import time
from functools import wraps


class rate_limit:
    """Limita a execução de uma função a N chamadas por intervalo."""

    def __init__(self, chamadas=10, intervalo=60.0):
        self.chamadas = chamadas
        self.intervalo = intervalo
        self._trava = threading.Lock()
        self._timestamps = []

    def __call__(self, funcao):
        @wraps(funcao)
        def interno(*args, **kwargs):
            with self._trava:
                agora = time.monotonic()
                # remove chamadas que já saíram da janela de tempo
                self._timestamps = [
                    t for t in self._timestamps
                    if agora - t < self.intervalo
                ]
                if len(self._timestamps) >= self.chamadas:
                    mais_antiga = min(self._timestamps)
                    espera = self.intervalo - (agora - mais_antiga)
                    raise RuntimeError(
                        f"limite de {self.chamadas} chamadas excedido. "
                        f"aguarde {espera:.2f}s.")
                self._timestamps.append(agora)
            return funcao(*args, **kwargs)
        return interno


if __name__ == "__main__":
    @rate_limit(chamadas=3, intervalo=5)
    def ping():
        return "pong"

    for i in range(1, 5):
        try:
            print(f"chamada {i}:", ping())
        except RuntimeError as erro:
            print(f"chamada {i} bloqueada:", erro)
