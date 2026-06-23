01 - Leitura em Chunks (para arquivos grandes)python

from typing import Iterator

def read_file_in_chunks(file_path: str, chunk_size: int = 8 * 1024 * 1024) -> Iterator[str]:
    """
    Lê um arquivo em blocos (chunks) para economizar memória.
    Ideal para processar arquivos muito grandes (>500MB).
    """
    with open(file_path, 'r', encoding='utf-8') as f:
        while chunk := f.read(chunk_size):
            yield chunk