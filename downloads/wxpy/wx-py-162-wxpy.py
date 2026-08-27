
# 10 - Combinação poderosa: regex + slicing (quando slicing não basta)
import re

def advanced_string_parser(text: str):
    """Parser avançado combinando slicing e regex"""
    # Extrai todas as palavras que começam com maiúscula
    capitals = re.findall(r'\b[A-Z][a-z]+\b', text)
    # Pega os últimos 50 caracteres
    tail = text[-50:]
    return {
        'capitals': capitals,
        'length': len(text),
        'last_50': tail,
        'reversed_tail': tail[::-1]
    }

print("10 - Parser avançado:", advanced_string_parser("Python é incrível. JavaScript também."))