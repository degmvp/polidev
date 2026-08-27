
# 09 - Regex com Unicode e Fronteiras de Palavras
def extract_portuguese_names(text: str) -> List[str]:
    """Extrai nomes próprios em português (suporta acentos)"""
    pattern = r'\b[A-ZÀ-Ú][a-zà-ú]+(?:\s[A-ZÀ-Ú][a-zà-ú]+)*\b'
    return re.findall(pattern, text)
