# bool_adv_12.py
# POLYDEV - PYTHON BOOLEAN
# Tema: Motor simples de regras booleanas

cliente = {
    "idade": 32,
    "renda": 6500,
    "score": 720,
    "restricao": False
}

regra_idade = cliente["idade"] >= 18
regra_renda = cliente["renda"] >= 3000
regra_score = cliente["score"] >= 700
regra_restricao = not cliente["restricao"]

credito_aprovado = regra_idade and regra_renda and regra_score and regra_restricao

print("Crédito aprovado:", credito_aprovado)
