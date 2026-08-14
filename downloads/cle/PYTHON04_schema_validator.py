"""
PYTHON04 - Validador de Esquema (Schema Validator)
===================================================
Valida estruturas de dados (dicts, listas) contra um esquema
definido em Python puro, sem dependências externas.
Útil para validar payloads de API, configs, formulários.
"""

from typing import Any, Callable


class ValidationError(Exception):
    """Erro de validação com caminho do campo."""

    def __init__(self, path: str, message: str):
        self.path = path
        self.message = message
        super().__init__(f"[{path}] {message}")


class SchemaValidator:
    """
    Validador de esquemas declarativo.

    Esquema é um dicionário onde cada chave mapeia para uma regra:
    - type: tipo esperado (str, int, float, bool, list, dict)
    - required: se o campo é obrigatório (padrão: True)
    - default: valor padrão se ausente
    - min_length / max_length: para strings e listas
    - min_value / max_value: para números
    - pattern: regex para strings
    - choices: lista de valores permitidos
    - validator: função customizada (value) -> bool
    - items: esquema para itens de lista
    - schema: sub-esquema para dicts aninhados
    """

    def __init__(self, schema: dict[str, dict[str, Any]]):
        self._schema = schema

    def validate(self, data: dict[str, Any], path: str = "") -> dict[str, Any]:
        """
        Valida os dados contra o esquema.

        Args:
            data: Dicionário de dados a validar.
            path: Caminho atual (uso interno para recursão).

        Returns:
            Dados validados e normalizados (com defaults aplicados).

        Raises:
            ValidationError: Se alguma regra for violada.
        """
        import re

        if not isinstance(data, dict):
            raise ValidationError(path or "root", "Esperado um dicionário")

        result: dict[str, Any] = {}
        errors: list[ValidationError] = []

        for field, rules in self._schema.items():
            field_path = f"{path}.{field}" if path else field
            value = data.get(field)

            # Campo ausente
            if value is None:
                if "default" in rules:
                    result[field] = rules["default"]
                    continue
                if rules.get("required", True):
                    errors.append(
                        ValidationError(field_path, "Campo obrigatório ausente")
                    )
                continue

            # Verificar tipo
            expected_type = rules.get("type")
            if expected_type and not isinstance(value, expected_type):
                errors.append(
                    ValidationError(
                        field_path,
                        f"Tipo inválido: esperado {expected_type.__name__}, "
                        f"recebido {type(value).__name__}",
                    )
                )
                continue

            # Validações de string
            if isinstance(value, str):
                if "min_length" in rules and len(value) < rules["min_length"]:
                    errors.append(
                        ValidationError(
                            field_path,
                            f"Comprimento mínimo: {rules['min_length']}",
                        )
                    )
                if "max_length" in rules and len(value) > rules["max_length"]:
                    errors.append(
                        ValidationError(
                            field_path,
                            f"Comprimento máximo: {rules['max_length']}",
                        )
                    )
                if "pattern" in rules and not re.match(rules["pattern"], value):
                    errors.append(
                        ValidationError(field_path, "Formato inválido")
                    )

            # Validações numéricas
            if isinstance(value, (int, float)):
                if "min_value" in rules and value < rules["min_value"]:
                    errors.append(
                        ValidationError(
                            field_path, f"Valor mínimo: {rules['min_value']}"
                        )
                    )
                if "max_value" in rules and value > rules["max_value"]:
                    errors.append(
                        ValidationError(
                            field_path, f"Valor máximo: {rules['max_value']}"
                        )
                    )

            # Choices
            if "choices" in rules and value not in rules["choices"]:
                errors.append(
                    ValidationError(
                        field_path,
                        f"Valor deve ser um de: {rules['choices']}",
                    )
                )

            # Validador customizado
            if "validator" in rules and not rules["validator"](value):
                errors.append(
                    ValidationError(field_path, "Validação customizada falhou")
                )

            # Sub-esquema (dict aninhado)
            if "schema" in rules and isinstance(value, dict):
                sub_validator = SchemaValidator(rules["schema"])
                try:
                    value = sub_validator.validate(value, field_path)
                except ValidationError as e:
                    errors.append(e)

            # Itens de lista
            if "items" in rules and isinstance(value, list):
                for i, item in enumerate(value):
                    item_path = f"{field_path}[{i}]"
                    item_rules = rules["items"]
                    if "type" in item_rules and not isinstance(
                        item, item_rules["type"]
                    ):
                        errors.append(
                            ValidationError(item_path, "Tipo de item inválido")
                        )

            result[field] = value

        if errors:
            messages = "; ".join(str(e) for e in errors)
            raise ValidationError(path or "root", messages)

        return result


# ===================== EXEMPLO DE USO =====================
#
# schema = SchemaValidator({
#     "nome": {"type": str, "min_length": 2, "max_length": 100},
#     "email": {"type": str, "pattern": r"^[\w.+-]+@[\w-]+\.[\w.]+$"},
#     "idade": {"type": int, "min_value": 0, "max_value": 150},
#     "role": {"type": str, "choices": ["admin", "user", "moderator"]},
#     "bio": {"type": str, "required": False, "default": ""},
#     "endereco": {
#         "type": dict,
#         "schema": {
#             "rua": {"type": str},
#             "cidade": {"type": str},
#             "cep": {"type": str, "pattern": r"^\d{5}-?\d{3}$"},
#         },
#     },
# })
#
# dados = {
#     "nome": "Maria Silva",
#     "email": "maria@exemplo.com",
#     "idade": 28,
#     "role": "admin",
#     "endereco": {"rua": "Rua A, 123", "cidade": "São Paulo", "cep": "01234-567"},
# }
#
# validado = schema.validate(dados)
# print(validado)
# >>> {'nome': 'Maria Silva', 'email': 'maria@exemplo.com', ...}
