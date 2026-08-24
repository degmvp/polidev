"""
wx-py-014-wxpy.py
Logging estruturado em JSON com rotação de arquivos

Para que serve:
    Configura o logging da aplicação de forma centralizada: mensagens
    em JSON (fáceis de consumir por ferramentas de monitoramento),
    escrita no console e em arquivo com rotação por tamanho.

Exemplo de uso:
    logger = setup_logging(arquivo="app.log")
    logger.info("serviço iniciado", extra={"servico": "api"})
"""

import json
import logging
from logging.handlers import RotatingFileHandler


class JsonFormatter(logging.Formatter):
    def format(self, record):
        payload = {
            "tempo": self.formatTime(record, "%Y-%m-%dT%H:%M:%S"),
            "nivel": record.levelname,
            "logger": record.name,
            "mensagem": record.getMessage(),
        }
        if hasattr(record, "extra"):
            payload["extra"] = record.extra
        if record.exc_info:
            payload["excecao"] = self.formatException(record.exc_info)
        return json.dumps(payload, ensure_ascii=False)


def setup_logging(nome="app", arquivo="app.log", nivel=logging.INFO):
    """Configura e retorna um logger com saída em JSON."""
    logger = logging.getLogger(nome)
    logger.setLevel(nivel)
    logger.handlers.clear()

    console = logging.StreamHandler()
    console.setFormatter(JsonFormatter())
    logger.addHandler(console)

    if arquivo:
        rotacao = RotatingFileHandler(
            arquivo, maxBytes=1_000_000, backupCount=3, encoding="utf-8")
        rotacao.setFormatter(JsonFormatter())
        logger.addHandler(rotacao)
    return logger


if __name__ == "__main__":
    logger = setup_logging("exemplo", "app.log")
    logger.info("inicializando", extra={"modulo": "main"})
    logger.warning("recurso quase esgotado", extra={"recurso": "disco"})
    try:
        1 / 0
    except ZeroDivisionError:
        logger.error("divisão por zero", exc_info=True)
    print("logs gravados em app.log")
