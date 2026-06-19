# POLYDEV | Python Professional Functions
# 08 - Função para serializar objetos complexos em JSON, incluindo tipos não suportados nativamente
#
# Finalidade:
# Facilitar troca de dados entre sistemas que usam objetos personalizados.

import json
from datetime import datetime

def custom_serializer(obj):
    if isinstance(obj, datetime):
        return obj.isoformat()
    raise TypeError(f"Tipo {type(obj)} não serializável")

class Pedido:
    def __init__(self, id, data):
        self.id = id
        self.data = data

pedido = Pedido(123, datetime.now())
json_pedido = json.dumps(pedido.__dict__, default=custom_serializer)
print(json_pedido)
