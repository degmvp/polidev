# bool_adv_19.py
# POLYDEV - PYTHON BOOLEAN
# Tema: Parser simples de expressão booleana controlada

contexto = {
    "A": True,
    "B": False,
    "C": True
}

# Expressão controlada, sem entrada externa do usuário
resultado = contexto["A"] and (not contexto["B"] or contexto["C"])

print("A:", contexto["A"])
print("B:", contexto["B"])
print("C:", contexto["C"])
print("Resultado:", resultado)
