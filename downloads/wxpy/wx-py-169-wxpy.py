# bool_adv_08.py
# POLYDEV - PYTHON BOOLEAN
# Tema: Verificar se número é par usando bitwise

numeros = [1, 2, 3, 4, 5, 10, 11, 20]

for n in numeros:
    eh_par = (n & 1) == 0
    print(n, "é par?", eh_par)
