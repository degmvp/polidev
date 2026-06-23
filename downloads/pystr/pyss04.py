
# 04 - Slicing com stride (step) para agrupamento
def group_by_n(s: str, n: int):
    """Agrupa string a cada N caracteres"""
    return [s[i:i+n] for i in range(0, len(s), n)]

print("04 - Agrupar:", group_by_n("abcdefghij", 3))