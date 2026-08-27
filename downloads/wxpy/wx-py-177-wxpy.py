# bool_adv_17.py
# POLYDEV - PYTHON BOOLEAN
# Tema: Álgebra booleana - Lei de De Morgan

A = True
B = False

expressao_1 = not (A and B)
expressao_2 = (not A) or (not B)

print("not (A and B):", expressao_1)
print("not A or not B:", expressao_2)
print("São equivalentes?", expressao_1 == expressao_2)
