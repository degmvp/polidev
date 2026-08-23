"""
PYTHON03 - Pipeline de Transformação de Dados
==============================================
Encadeia funções de transformação em sequência, criando
pipelines de processamento declarativos e reutilizáveis.
Inspirado em pipes do Unix e programação funcional.
"""

from typing import Any, Callable, TypeVar, Generic
from copy import deepcopy

T = TypeVar("T")


class Pipeline(Generic[T]):
    """
    Pipeline de transformações encadeadas.

    Permite compor várias funções de transformação e aplicá-las
    sequencialmente a um dado de entrada. Suporta branching,
    error handling e inspeção intermediária.
    """

    def __init__(self) -> None:
        self._steps: list[tuple[str, Callable]] = []
        self._error_handler: Callable[[Exception, str, Any], Any] | None = None
        self._history: list[dict[str, Any]] = []

    def pipe(self, func: Callable, name: str | None = None) -> "Pipeline[T]":
        """Adiciona um passo ao pipeline."""
        step_name = name or func.__name__
        self._steps.append((step_name, func))
        return self

    def on_error(
        self, handler: Callable[[Exception, str, Any], Any]
    ) -> "Pipeline[T]":
        """Define handler global de erros para o pipeline."""
        self._error_handler = handler
        return self

    def execute(self, data: T, *, track: bool = False) -> T:
        """
        Executa o pipeline sobre os dados de entrada.

        Args:
            data: Dado inicial a ser transformado.
            track: Se True, armazena histórico de cada etapa.

        Returns:
            Dado após todas as transformações.
        """
        result: Any = data
        self._history.clear()

        for step_name, func in self._steps:
            try:
                if track:
                    snapshot_before = deepcopy(result)
                result = func(result)
                if track:
                    self._history.append({
                        "step": step_name,
                        "input": snapshot_before,
                        "output": deepcopy(result),
                        "error": None,
                    })
            except Exception as e:
                if self._error_handler:
                    result = self._error_handler(e, step_name, result)
                    if track:
                        self._history.append({
                            "step": step_name,
                            "input": snapshot_before if track else None,
                            "output": deepcopy(result),
                            "error": str(e),
                        })
                else:
                    raise RuntimeError(
                        f"Pipeline falhou no passo '{step_name}': {e}"
                    ) from e

        return result

    def get_history(self) -> list[dict[str, Any]]:
        """Retorna histórico de execução (requer track=True)."""
        return self._history

    def __repr__(self) -> str:
        steps = " -> ".join(name for name, _ in self._steps)
        return f"Pipeline({steps})"


# ===================== EXEMPLO DE USO =====================
#
# pipeline = (
#     Pipeline()
#     .pipe(str.strip, "remover_espacos")
#     .pipe(str.lower, "minusculas")
#     .pipe(lambda s: s.replace("  ", " "), "normalizar_espacos")
#     .pipe(lambda s: s.split(), "tokenizar")
#     .pipe(lambda tokens: [t for t in tokens if len(t) > 2], "filtrar_curtas")
#     .on_error(lambda e, step, data: data)
# )
#
# resultado = pipeline.execute("  Olá   Mundo   Python  É  TOP  ", track=True)
# print(resultado)
# >>> ['olá', 'mundo', 'python', 'top']
