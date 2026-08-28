# bool_adv_15.py
# POLYDEV - PYTHON BOOLEAN
# Tema: Compactação de vários booleanos em um inteiro

ativo = True
admin = False
premium = True
bloqueado = False

flags = 0
flags |= int(ativo) << 0
flags |= int(admin) << 1
flags |= int(premium) << 2
flags |= int(bloqueado) << 3

print("Flags compactadas:", flags, bin(flags))
print("Ativo:", bool(flags & (1 << 0)))
print("Admin:", bool(flags & (1 << 1)))
print("Premium:", bool(flags & (1 << 2)))
print("Bloqueado:", bool(flags & (1 << 3)))
