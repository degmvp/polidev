10 - Classe Profissional para Processamento de Arquivos

from pathlib import Path
import json

class RobustFileProcessor:
    """
    Classe completa e robusta para operações com arquivos em produção.
    """
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.base_path.mkdir(parents=True, exist_ok=True)

    def safe_write_json(self, data: dict, filename: str):
        """Escreve JSON de forma segura"""
        full_path = self.base_path / filename
        with open(full_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)

    def read_lines(self, filename: str):
        """Generator para ler linhas com baixo consumo de memória"""
        with open(self.base_path / filename, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if line:
                    yield line










