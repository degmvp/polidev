"""
wx-py-016-wxpy.py
Carregador de configuração JSON com validação e valores padrão

Para que serve:
    Lê um arquivo JSON de configuração, valida tipos obrigatórios e
    aplica valores padrão, retornando um dicionário seguro de usar.

Exemplo de uso:
    config = load_config("config.json", padroes={"porta": 8080, "debug": False})
"""

import json
import os
import tempfile


class ConfigError(Exception):
    """Erro de configuração."""


def load_config(caminho, padroes=None, tipos=None):
    """Carrega config JSON aplicando defaults e validando tipos.

    Args:
        caminho: caminho do arquivo JSON.
        padroes: dict com chaves e valores padrão.
        tipos: dict opcional com chave -> tipo esperado (ex.: int).
    """
    padroes = padroes or {}
    tipos = tipos or {}
    try:
        with open(caminho, "r", encoding="utf-8") as arquivo:
            dados = json.load(arquivo)
    except (OSError, json.JSONDecodeError) as erro:
        raise ConfigError(f"não foi possível ler {caminho}: {erro}")

    if not isinstance(dados, dict):
        raise ConfigError("a configuração precisa ser um objeto JSON")

    resultado = dict(padroes)
    resultado.update(dados)

    for chave, tipo in tipos.items():
        if chave not in resultado:
            raise ConfigError(f"campo obrigatório ausente: '{chave}'")
        if not isinstance(resultado[chave], tipo):
            raise ConfigError(
                f"campo '{chave}' deve ser {tipo.__name__}, "
                f"recebeu {type(resultado[chave]).__name__}")
    return resultado


if __name__ == "__main__":
    with tempfile.NamedTemporaryFile(
            "w", suffix=".json", delete=False, encoding="utf-8") as arquivo:
        arquivo.write('{"porta": 9090, "debug": true}')
        caminho = arquivo.name

    config = load_config(
        caminho,
        padroes={"porta": 8080, "debug": False, "nome": "servidor"},
        tipos={"porta": int, "nome": str},
    )
    print("configuração:", config)
    os.unlink(caminho)
