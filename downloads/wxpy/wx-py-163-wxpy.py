# bool_adv_01.py
# POLYDEV - PYTHON BOOLEAN
# Tema: Operadores booleanos básicos AND, OR e NOT

idade = 25
tem_carteira = True

pode_dirigir = idade >= 18 and tem_carteira
precisa_tirar_carteira = idade >= 18 and not tem_carteira
menor_de_idade = idade < 18

print("Pode dirigir:", pode_dirigir)
print("Precisa tirar carteira:", precisa_tirar_carteira)
print("Menor de idade:", menor_de_idade)
