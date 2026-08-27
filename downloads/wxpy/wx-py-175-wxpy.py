# bool_adv_14.py
# POLYDEV - PYTHON BOOLEAN
# Tema: Simulação de circuito lógico

def porta_and(a, b):
    return a and b

def porta_or(a, b):
    return a or b

def porta_not(a):
    return not a

entrada_a = True
entrada_b = False

saida = porta_or(porta_and(entrada_a, entrada_b), porta_not(entrada_b))

print("Saída do circuito lógico:", saida)
