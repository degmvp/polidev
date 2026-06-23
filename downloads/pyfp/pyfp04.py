04 - Escrita Atômica (Atomic Write)

import os
from pathlib import Path

def atomic_write(data: str, file_path: str):
    """
    Escreve arquivo de forma atômica (seguro contra falhas).
    Evita arquivos corrompidos.
    """
    temp_path = Path(file_path + '.tmp')
    try:
        with open(temp_path, 'w', encoding='utf-8') as f:
            f.write(data)
            f.flush()
            os.fsync(f.fileno())
        os.replace(temp_path, file_path)
    except Exception:
        temp_path.unlink(missing_ok=True)
        raise