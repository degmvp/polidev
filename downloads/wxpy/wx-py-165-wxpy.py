# bool_adv_03.py
# POLYDEV - PYTHON BOOLEAN
# Tema: Tabela verdade para AND, OR e XOR

valores = [False, True]

print("A\tB\tAND\tOR\tXOR")
for a in valores:
    for b in valores:
        print(a, b, a and b, a or b, a != b, sep="\t")
