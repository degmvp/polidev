03 - Busca Rápida com Memory Mapping

import mmap

def memory_map_search(file_path: str, search_term: str) -> int:
    """
    Busca texto em arquivo grande usando Memory Mapping (muito rápido).
    """
    with open(file_path, 'r', encoding='utf-8') as f:
        with mmap.mmap(f.fileno(), 0, access=mmap.ACCESS_READ) as mm:
            return mm.find(search_term.encode())