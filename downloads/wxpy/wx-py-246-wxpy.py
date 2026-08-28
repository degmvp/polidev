# bool_adv_06.py
# POLYDEV - PYTHON BOOLEAN
# Tema: Adicionar, remover e alternar permissões com bits

LER = 1
ESCREVER = 2
EXECUTAR = 4

permissoes = 0
permissoes |= LER
permissoes |= EXECUTAR
permissoes &= ~EXECUTAR
permissoes ^= ESCREVER

print("Permissões finais:", bin(permissoes))
print("LER:", bool(permissoes & LER))
print("ESCREVER:", bool(permissoes & ESCREVER))
print("EXECUTAR:", bool(permissoes & EXECUTAR))
