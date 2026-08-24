"""
wx-py-018-wxpy.py
Validação de dicionários contra um esquema (sem dependências)

Para que serve:
    Valida dados recebidos (ex.: payloads de API ou formulários) contra
    um esquema com campos obrigatórios e tipos esperados. Levanta erros
    claros sobre o que está faltando ou errado.

Exemplo de uso:
    valida = validate_schema(dados, {"nome": str, "idade": int}, ("nome",))
"""


class SchemaError(ValueError):
    """Erro de validação de esquema."""


def validate_schema(dados, esquema, obrigatorios=()):
    """Valida um dict contra um esquema {campo: tipo}.

    Args:
        dados: dicionário a validar.
        esquema: dict com campo -> tipo esperado.
        obrigatorios: tupla de campos que precisam estar presentes.
    """
    for campo in obrigatorios:
        if campo not in dados:
            raise SchemaError(f"campo obrigatório ausente: '{campo}'")

    for campo, tipo in esquema.items():
        if campo not in dados:
            continue
        if not isinstance(dados[campo], tipo):
            raise SchemaError(
                f"campo '{campo}' deve ser {tipo.__name__}, "
                f"recebeu {type(dados[campo]).__name__}")
    return True


if __name__ == "__main__":
    esquema = {"nome": str, "idade": int, "email": str}

    valido = {"nome": "Ana", "idade": 30, "email": "ana@exemplo.com"}
    print("válido?", validate_schema(valido, esquema, ("nome", "email")))

    invalido = {"nome": "Ana", "idade": "trinta", "email": "ana@exemplo.com"}
    try:
        validate_schema(invalido, esquema, ("nome", "email"))
    except SchemaError as erro:
        print("erro esperado:", erro)
