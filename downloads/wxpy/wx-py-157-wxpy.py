
# 05 - Uso avançado de partition e rpartition
def smart_split(text: str, sep: str):
    """Divide string mantendo o separador e retorna partes úteis"""
    before, separator, after = text.partition(sep)
    return before, separator, after

print("05 - Partition:", smart_split("nome:João Silva", ":"))