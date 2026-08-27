# ==========================================================
# POLYDEV | Python Engineering
# ==========================================================
#
# Série:
# Python Engineering v1.0
#
# PYENG-02 — Pipeline de Processamento
#
# Tecnologia:
# Python 3.12+
#
# Categoria:
# Arquitetura • Processamento de Dados
#
# Objetivo
# ----------------------------------------------------------
# Construir um Pipeline de Processamento reutilizável para
# executar múltiplas etapas de transformação de dados de
# maneira sequencial, organizada e extensível.
#
# O que é um Pipeline?
# ----------------------------------------------------------
# Pipeline é um padrão de arquitetura onde uma informação
# percorre diversas etapas de processamento.
#
# Cada etapa recebe os dados produzidos pela etapa anterior,
# aplica sua transformação e entrega o resultado para a
# próxima, formando uma cadeia de execução simples e elegante.
#
# Quando utilizar
# ----------------------------------------------------------
# • ETL (Extract, Transform, Load)
# • Processamento de arquivos
# • APIs
# • Normalização de dados
# • Validação de informações
# • Fluxos de transformação
#
# Problema resolvido
# ----------------------------------------------------------
# Evita grandes blocos de código contendo diversas operações
# sequenciais, tornando o processamento modular, reutilizável
# e de fácil manutenção.
#
# Fluxo de execução
# ----------------------------------------------------------
#
#        Dados de Entrada
#               │
#               ▼
#      +-----------------+
#      | Normalizar      |
#      +-----------------+
#               │
#               ▼
#      +-----------------+
#      | Remover Acentos |
#      +-----------------+
#               │
#               ▼
#      +-----------------+
#      | Capitalizar     |
#      +-----------------+
#               │
#               ▼
#        Resultado Final
#
# Principais componentes
# ----------------------------------------------------------
# • typing.Callable
# • functools.reduce
# • Pipeline
# • Operador Pipe (|)
#
# Resultado esperado
# ----------------------------------------------------------
# Criar pipelines reutilizáveis capazes de aplicar diversas
# transformações em sequência utilizando uma sintaxe simples,
# intuitiva e de fácil expansão.
#
# Observações
# ----------------------------------------------------------
# Este exemplo foi desenvolvido para fins educacionais.
# Em ambientes de produção, considere adicionar tratamento
# de exceções, logging, validação das etapas e monitoramento
# da execução conforme a complexidade da aplicação.
#
# ==========================================================
# Implementação
# ==========================================================

from typing import Callable, Any, List
from functools import reduce


class Pipeline:
    def __init__(self):
        self.steps: List[Callable] = []

    def add_step(self, func: Callable) -> 'Pipeline':
        """Adiciona uma etapa ao pipeline."""
        self.steps.append(func)
        return self

    def execute(self, data: Any) -> Any:
        """Executa o pipeline sequencialmente."""
        return reduce(lambda d, step: step(d), self.steps, data)

    def __or__(self, func: Callable) -> 'Pipeline':
        """Permite sintaxe: pipeline | step"""
        self.add_step(func)
        return self


# Etapas do pipeline
def normalizar(texto: str) -> str:
    return texto.strip().lower()


def remover_acentos(texto: str) -> str:
    import unicodedata

    return ''.join(
        c for c in unicodedata.normalize('NFD', texto)
        if unicodedata.category(c) != 'Mn'
    )


def capitalizar(texto: str) -> str:
    return texto.title()


# Uso com operador pipe
pipeline = Pipeline() | normalizar | remover_acentos | capitalizar

resultado = pipeline.execute("  São PAULO  ")

print(f"Resultado: {resultado}")  # "Sao Paulo"

# ==========================================================
# Fim do módulo PYENG-02
# ==========================================================
#
# Resumo
# ----------------------------------------------------------
# Neste módulo você aprendeu como implementar um Pipeline de
# Processamento reutilizável, organizando transformações em
# etapas independentes para produzir código mais limpo,
# modular e de fácil manutenção.
#
# Próximo módulo
# ----------------------------------------------------------
# PYENG-03 — Retry com Backoff Exponencial
#
# POLYDEV | Python Engineering v1.0
#
# Leia • Entenda • Execute seu código.
# ==========================================================