# bool_adv_07.py
# POLYDEV - PYTHON BOOLEAN
# Tema: Shift left e shift right

numero = 5  # 0101

multiplica_por_2 = numero << 1
multiplica_por_4 = numero << 2
divide_por_2 = numero >> 1

print("Número original:", numero, bin(numero))
print("numero << 1:", multiplica_por_2, bin(multiplica_por_2))
print("numero << 2:", multiplica_por_4, bin(multiplica_por_4))
print("numero >> 1:", divide_por_2, bin(divide_por_2))
