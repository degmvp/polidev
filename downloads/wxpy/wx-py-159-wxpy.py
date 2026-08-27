# 07 - Translate + maketrans (muito mais rápido que replace múltiplo)
def clean_text_fast(text: str) -> str:
    """Limpeza ultra-rápida usando maketrans"""
    trans = str.maketrans({
        'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u',
        'ã': 'a', 'õ': 'o', 'ç': 'c', '@': 'a', '#': ''
    })
    return text.translate(trans).lower()

 print("07 - Clean fast:", clean_text_fast("Olá, café & @ção!"))