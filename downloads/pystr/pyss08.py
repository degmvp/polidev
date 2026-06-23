
# 08 - Slicing com índices dinâmicos + find/rfind
def extract_between(text: str, start: str, end: str) -> str:
    """Extrai texto entre duas marcas (avançado)"""
    start_idx = text.find(start)
    end_idx = text.find(end, start_idx + len(start))
    if start_idx == -1 or end_idx == -1:
        return ""
    return text[start_idx + len(start):end_idx]

 print("08 - Entre marcas:", extract_between("start:conteúdo secreto:end", "start:", ":end"))