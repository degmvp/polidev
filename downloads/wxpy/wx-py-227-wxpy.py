# ==========================================================
# POLYDEV | WX-COLLECTOR
# WX-PY-227
# Processamento em Chunks
# Categoria: wxpy12
# ==========================================================

import pandas as pd

def process_csv_in_chunks(file_path, chunksize=50_000):
    for chunk in pd.read_csv(file_path, chunksize=chunksize):
        numeric = chunk.select_dtypes(include=["number"]).to_numpy()
        yield numeric
