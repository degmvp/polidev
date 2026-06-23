05 - Processamento de CSV Grande em Lotes

import csv
from typing import List, Dict

def process_large_csv(file_path: str, batch_size: int = 10000):
    """
    Processa CSV grande em lotes (batches) para economizar memória.
    """
    with open(file_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        batch = []
        for row in reader:
            batch.append(row)
            if len(batch) >= batch_size:
                yield batch
                batch = []
        if batch:
            yield batch