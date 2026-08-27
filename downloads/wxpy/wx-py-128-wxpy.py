08 - Processamento com Arquivos Temporários

from tempfile import TemporaryDirectory
from pathlib import Path

def process_with_temp_files(data: list, filename: str = "temp.txt"):
    """
    Processa dados usando diretório temporário seguro.
    """
    with TemporaryDirectory() as temp_dir:
        temp_file = Path(temp_dir) / filename
        with open(temp_file, 'w', encoding='utf-8') as f:
            for item in data:
                f.write(str(item) + '\n')
        return temp_file.read_text(encoding='utf-8')