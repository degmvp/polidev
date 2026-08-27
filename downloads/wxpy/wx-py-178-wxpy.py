# bool_adv_18.py
# POLYDEV - PYTHON BOOLEAN
# Tema: Comparação de conjuntos com lógica booleana

permissoes_usuario = {"ler", "escrever", "exportar"}
permissoes_minimas = {"ler", "escrever"}

possui_todas = permissoes_minimas.issubset(permissoes_usuario)
possui_alguma = bool(permissoes_usuario & permissoes_minimas)

print("Possui todas:", possui_todas)
print("Possui alguma:", possui_alguma)
