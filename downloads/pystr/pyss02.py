
# 02 - Extração de substrings com múltiplos critérios (técnica avançada)
def extract_parts(text: str):
    """Extrai múltiplas partes usando slicing inteligente"""
    # Pega do início até o primeiro ":", do último ":" até o fim, etc.
    first_part = text[:text.find(':')]
    last_part = text[text.rfind(':')+1:]
    middle = text[text.find(':')+1:text.rfind(':')]
    return first_part.strip(), middle.strip(), last_part.strip()

print("02 - Partes:", extract_parts("Host: localhost:5432/database"))