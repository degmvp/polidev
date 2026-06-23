10 - Classe Profissional para Processamento de Arquivos

from pathlib import Path
import json

class RobustFileProcessor:
    """
    Classe completa e robusta para processamento de arquivos em produção.
    """
    def __init__(self, base_path: str):
        self.base_path = Path(base_path)
        self.base_path.mkdir(parents=True, exist_ok=True)

    def safe_write_json(self, data, filename: str):
        full_path = self.base_path / filename
        # Aqui você pode chamar atomic_write()
        with open(full_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)