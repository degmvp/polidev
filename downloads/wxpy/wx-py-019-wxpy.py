"""
wx-py-019-wxpy.py
Context manager que impõe tempo limite de execução

Para que serve:
    Roda um bloco de código em segundo plano e, se demorar mais que o
    limite, devolve um valor padrão em vez de travar o programa. Útil
    para chamadas de rede, filas e serviços lentos.

Exemplo de uso:
    with timeout_after(limite=5, padrao="não respondeu") as contexto:
        resultado = contexto.executar(consultar_servico)
"""

import concurrent.futures


class timeout_after:
    """Limita o tempo de execução, retornando um valor padrão no estouro."""

    def __init__(self, limite=5.0, padrao=None):
        self.limite = limite
        self.padrao = padrao
        self.executor = None

    def __enter__(self):
        self.executor = concurrent.futures.ThreadPoolExecutor(max_workers=1)
        return self

    def __exit__(self, tipo, valor, traceback):
        if self.executor:
            self.executor.shutdown(wait=False)
        return False

    def executar(self, funcao, *args, **kwargs):
        """Executa funcao dentro do limite de tempo definido."""
        futuro = self.executor.submit(funcao, *args, **kwargs)
        try:
            return futuro.result(timeout=self.limite)
        except concurrent.futures.TimeoutError:
            return self.padrao


if __name__ == "__main__":
    import time

    def lenta():
        time.sleep(2)
        return "concluída"

    with timeout_after(limite=0.5, padrao="tempo esgotado") as contexto:
        print("resultado:", contexto.executar(lenta))
