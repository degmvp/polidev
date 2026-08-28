# ==========================================================
# POLYDEV | WX-COLLECTOR
# WX-PY-221
# Leitura Otimizada de Grandes Arquivos
# Categoria: wxpy12
# ==========================================================

import pandas as pd

def read_large_csv_optimized(file_path, chunksize=100_000):
    chunks = []
    for chunk in pd.read_csv(file_path, chunksize=chunksize):
        chunks.append(chunk)
    return pd.concat(chunks, ignore_index=True)
