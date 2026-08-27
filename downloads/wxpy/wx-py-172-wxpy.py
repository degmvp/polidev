# bool_adv_11.py
# POLYDEV - PYTHON BOOLEAN
# Tema: Filtro com múltiplas condições booleanas

produtos = [
    {"nome": "Notebook", "preco": 3500, "estoque": 5},
    {"nome": "Mouse", "preco": 80, "estoque": 0},
    {"nome": "Monitor", "preco": 900, "estoque": 3},
    {"nome": "Servidor", "preco": 12000, "estoque": 1},
]

for p in produtos:
    disponivel = p["estoque"] > 0
    preco_aceitavel = p["preco"] <= 5000
    aprovado = disponivel and preco_aceitavel
    print(p["nome"], "aprovado?", aprovado)
