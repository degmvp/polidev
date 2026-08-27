07 - Copiar Arquivo com Progresso

from pathlib import Path

def copy_file_with_progress(src: str, dst: str, chunk_size: int = 64*1024*1024):
    """
    Copia arquivo grande mostrando progresso.
    """
    total_size = Path(src).stat().st_size
    copied = 0

    with open(src, 'rb') as fsrc, open(dst, 'wb') as fdst:
        while chunk := fsrc.read(chunk_size):
            fdst.write(chunk)
            copied += len(chunk)
            print(f"Progresso: {copied / total_size * 100:6.2f}%", end='\r')
    print("\nCópia concluída!")