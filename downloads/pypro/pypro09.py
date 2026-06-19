# POLYDEV | Python Professional Functions
# 09 - Função para tratamento centralizado de exceções em chamadas API REST
#
# Finalidade:
# Uniformizar resposta de erros em sistemas distribuídos.

from functools import wraps
from flask import Flask, jsonify

app = Flask(__name__)

def tratar_excecoes(func):
    """
    Decorador para padronizar respostas de erro em APIs Flask.
    """
    @wraps(func)
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except ValueError as exc:
            return jsonify({"erro": str(exc)}), 400
        except Exception:
            return jsonify({"erro": "Erro interno"}), 500
    return wrapper


@app.route("/processar")
@tratar_excecoes
def processar():
    raise ValueError("Dado inválido")


# app.run(debug=True)
