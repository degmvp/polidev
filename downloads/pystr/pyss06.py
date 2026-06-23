# 06 - Remoção avançada de prefixos e sufixos (Python 3.9+)
def remove_affixes(text: str):
    """Remove prefixos e sufixos de forma segura"""
    text = text.removeprefix("https://")
    text = text.removesuffix(".git")
    text = text.removesuffix("/")
    return text

print("06 - Remove affixes:", remove_affixes("https://github.com/user/repo.git"))