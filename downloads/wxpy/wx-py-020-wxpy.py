"""
wx-py-020-wxpy.py
Leitura de variáveis de ambiente com tipagem e valores padrão

Para que serve:
    Lê configurações do ambiente (os.environ) convertendo automaticamente
    para os tipos esperados (int, float, bool, str), com valores padrão.
    Evita erros comuns de casting e centraliza o acesso à configuração.

Exemplo de uso:
    config = env_config({"DEBUG": bool, "PORTA": int}, {"PORTA": 8080})
"""

import os


def _converter(valor, tipo):
    if tipo is bool:
        return valor.strip().lower() in ("1", "true", "sim", "yes", "on")
    if tipo is int:
        return int(valor)
    if tipo is float:
        return float(valor)
    return valor


def env_config(tipos, padroes=None):
    """Lê variáveis de ambiente com tipagem e valores padrão.

    Args:
        tipos: dict com nome da variável -> tipo esperado.
        padroes: dict opcional com variável -> valor padrão.
    """
    padroes = padroes or {}
    config = {}
    for nome, tipo in tipos.items():
        valor = os.environ.get(nome, padroes.get(nome))
        if valor is None:
            raise ValueError(
                f"variável de ambiente ausente e sem padrão: '{nome}'")
        try:
            config[nome] = _converter(str(valor), tipo)
        except ValueError as erro:
            raise ValueError(
                f"variável '{nome}' deve ser {tipo.__name__}") from erro
    return config


if __name__ == "__main__":
    os.environ["DEBUG"] = "true"
    os.environ["PORTA"] = "9090"
    # MAX_CONEXOES não está definida -> usa o padrão 5

    config = env_config(
        {"DEBUG": bool, "PORTA": int, "MAX_CONEXOES": int},
        padroes={"MAX_CONEXOES": 5},
    )
    print("configuração:", config)
