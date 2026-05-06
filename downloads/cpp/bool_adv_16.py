# bool_adv_16.py
# POLYDEV - PYTHON BOOLEAN
# Tema: Controle de acesso com papéis

roles_usuario = {"leitor", "editor"}
roles_necessarias = {"admin", "editor"}

pode_acessar = bool(roles_usuario.intersection(roles_necessarias))

print("Roles do usuário:", roles_usuario)
print("Roles necessárias:", roles_necessarias)
print("Pode acessar:", pode_acessar)
