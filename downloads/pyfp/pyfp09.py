09 - Leitura Paralela de Múltiplos Arquivos

from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from typing import Dict

def read_multiple_files_parallel(file_list: list) -> Dict[str, str]:
    """
    Lê múltiplos arquivos simultaneamente usando threads.
    Ideal para ler vários arquivos de configuração ou logs.
    """
    def read_file(path):
        try:
            return path, Path(path).read_text(encoding='utf-8')
        except Exception:
            return path, None

    with ThreadPoolExecutor(max_workers=8) as executor:
        return dict(executor.map(read_file, file_list))










