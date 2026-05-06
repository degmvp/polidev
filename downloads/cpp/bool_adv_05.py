# bool_adv_05.py
# POLYDEV - PYTHON BOOLEAN
# Tema: Máscaras de bits para permissões

LER = 1       # 001
ESCREVER = 2 # 010
EXECUTAR = 4 # 100

usuario = LER | ESCREVER

print("Permissões do usuário:", bin(usuario))
print("Pode ler:", bool(usuario & LER))
print("Pode escrever:", bool(usuario & ESCREVER))
print("Pode executar:", bool(usuario & EXECUTAR))
