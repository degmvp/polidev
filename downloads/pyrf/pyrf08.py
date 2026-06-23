
# 08 - Split Avançado com múltiplos delimitadores
def smart_split(text: str) -> List[str]:
    """Divide texto por múltiplos separadores mantendo limpeza"""
    # Divide por vírgula, ponto e vírgula, nova linha ou tab
    return re.split(r'[,;\n\t]+', text.strip())
