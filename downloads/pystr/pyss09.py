# 09 - Uso de splitlines() + list comprehension avançado
def parse_multiline_code(code_block: str):
    """Processa bloco de código multilinha"""
    lines = code_block.splitlines()
    cleaned = [line.strip() for line in lines if line.strip() and not line.strip().startswith('#')]
    return '\n'.join(cleaned)