

# 06 - Backreferences (Referência a grupos capturados)
def find_duplicate_words(text: str) -> List[str]:
    """Encontra palavras repetidas consecutivas"""
    pattern = r'\b(\w+)\s+\1\b'
    return re.findall(pattern, text, re.IGNORECASE)
