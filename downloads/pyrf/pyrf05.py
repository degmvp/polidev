
# 05 - Greedy vs Non-Greedy + Quantifiers
def extract_html_tags(html: str) -> List[str]:
    """Extrai conteúdo entre tags sem capturar tags aninhadas"""
    # Non-greedy (.*?)
    return re.findall(r'<title>(.*?)</title>', html, re.DOTALL | re.IGNORECASE)