"""
POLYDEV - State Manager
Gerencia o CORE POLYDEV CONTINUITY FILE automaticamente.

Funções:
- salvar estado atual do projeto
- atualizar contexto incremental
- carregar estado para IA ou logs

Autor: POLYDEV System
"""

import json
from datetime import datetime
from pathlib import Path

CORE_FILE = "core_polydev.md"
STATE_LOG = "polydev_state_log.json"

class StateManager:
    def __init__(self, core_file=CORE_FILE):
        self.core_file = Path(core_file)
        self.log_file = Path(STATE_LOG)

        if not self.log_file.exists():
            self.log_file.write_text(json.dumps([], indent=2), encoding="utf-8")

    def _load_log(self):
        return json.loads(self.log_file.read_text(encoding="utf-8"))

    def _save_log(self, data):
        self.log_file.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")

    def add_state(self, module, file_active, status, next_step):
        """Adiciona um snapshot do estado atual do projeto"""
        log = self._load_log()

        entry = {
            "timestamp": datetime.now().isoformat(),
            "module": module,
            "file_active": file_active,
            "status": status,
            "next_step": next_step
        }

        log.append(entry)
        self._save_log(log)

        print("[OK] Estado salvo com sucesso.")

    def get_last_state(self):
        """Retorna último estado salvo"""
        log = self._load_log()
        if not log:
            return None
        return log[-1]

    def export_core_snapshot(self):
        """Gera uma atualização simples do CORE FILE com último estado"""
        last = self.get_last_state()

        if not last:
            print("[WARN] Nenhum estado encontrado.")
            return

        snapshot = f"""
## AUTO STATE UPDATE

**Última atualização:** {last['timestamp']}
- Módulo: {last['module']}
- Arquivo ativo: {last['file_active']}
- Status: {last['status']}
- Próximo passo: {last['next_step']}
"""

        if self.core_file.exists():
            content = self.core_file.read_text(encoding="utf-8")
        else:
            content = "# CORE POLYDEV CONTINUITY FILE\n"

        # evita duplicação simples
        if "## AUTO STATE UPDATE" in content:
            content = content.split("## AUTO STATE UPDATE")[0].strip()

        updated = content + "\n\n" + snapshot

        self.core_file.write_text(updated, encoding="utf-8")

        print("[OK] CORE FILE atualizado com snapshot.")


# ----------------------
# EXEMPLO DE USO
# ----------------------
if __name__ == "__main__":
    sm = StateManager()

    sm.add_state(
        module="menu_isometrico",
        file_active="menu8.html",
        status="erro 400 em gravação de contador",
        next_step="corrigir SQL delete sem WHERE"
    )

    sm.export_core_snapshot()

    print(sm.get_last_state())
