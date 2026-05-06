# bool_adv_09.py
# POLYDEV - PYTHON BOOLEAN
# Tema: Estado de sistema usando flags booleanas

sistema_online = True
usuario_logado = True
manutencao = False

acesso_liberado = sistema_online and usuario_logado and not manutencao

print("Sistema online:", sistema_online)
print("Usuário logado:", usuario_logado)
print("Manutenção:", manutencao)
print("Acesso liberado:", acesso_liberado)
