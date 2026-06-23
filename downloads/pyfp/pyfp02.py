02 - Context Manager Avançado para Arquivos

class SmartFileReader:
    """
    Context manager profissional para leitura de arquivos 
    com tratamento de encoding e erros.
    """
    def __init__(self, file_path: str, encoding: str = 'utf-8'):
        self.file_path = file_path
        self.encoding = encoding
        self.file = None

    def __enter__(self):
        self.file = open(self.file_path, 'r', encoding=self.encoding, errors='replace')
        return self.file

    def __exit__(self, exc_type, exc_val, exc_tb):
        if self.file:
            self.file.close()