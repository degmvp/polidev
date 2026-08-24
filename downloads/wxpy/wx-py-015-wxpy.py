"""
wx-py-015-wxpy.py
Cliente HTTP para GET de JSON com timeout e retries

Para que serve:
    Baixa e decodifica um JSON de uma URL com timeout definido,
    tentativas automáticas em caso de erro de rede e tratamento
    centralizado de erros (rede, HTTP e JSON inválido).

Exemplo de uso:
    dados = http_get_json("https://exemplo.com/api/dados", timeout=5)
"""

import json
import urllib.error
import urllib.request


class HttpError(Exception):
    """Erro genérico de HTTP."""


def http_get_json(url, timeout=10, tentativas=3):
    """Retorna o JSON de uma URL, com retry e tratamento de erros."""
    ultimo_erro = None
    for _ in range(tentativas):
        try:
            requisicao = urllib.request.Request(
                url, headers={"User-Agent": "wx-py-015"})
            with urllib.request.urlopen(requisicao, timeout=timeout) as resp:
                if resp.status != 200:
                    raise HttpError(f"status HTTP {resp.status}")
                return json.loads(resp.read().decode("utf-8"))
        except (urllib.error.URLError, TimeoutError,
                json.JSONDecodeError, HttpError) as erro:
            ultimo_erro = erro
    raise HttpError(f"falha ao acessar {url}: {ultimo_erro}")


if __name__ == "__main__":
    # exemplo 100% offline: servidor HTTP local de brinquedo
    import http.server
    import threading

    class Handler(http.server.BaseHTTPRequestHandler):
        def do_GET(self):
            corpo = b'{"ok": true, "itens": [1, 2, 3]}'
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(corpo)))
            self.end_headers()
            self.wfile.write(corpo)

        def log_message(self, *args):
            pass

    servidor = http.server.HTTPServer(("127.0.0.1", 0), Handler)
    porta = servidor.server_address[1]
    threading.Thread(target=servidor.serve_forever, daemon=True).start()

    dados = http_get_json(f"http://127.0.0.1:{porta}/api", timeout=5)
    print("JSON recebido:", dados)
    servidor.shutdown()
