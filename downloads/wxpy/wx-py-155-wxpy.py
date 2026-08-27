

# 03 - Indexação negativa + verificação de palíndromo otimizada
def is_palindrome(s: str) -> bool:
    """Verifica palíndromo ignorando espaços, pontuação e case"""
    cleaned = ''.join(c.lower() for c in s if c.isalnum())
    return cleaned == cleaned[::-1]

print("03 - Palíndromo:", is_palindrome("A man a plan a canal Panama"))