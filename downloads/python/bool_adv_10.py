# bool_adv_10.py
# POLYDEV - PYTHON BOOLEAN
# Tema: Validação booleana de senha

senha = "Polydev@2026"

tem_tamanho = len(senha) >= 8
tem_maiuscula = any(c.isupper() for c in senha)
tem_numero = any(c.isdigit() for c in senha)
tem_simbolo = any(not c.isalnum() for c in senha)

senha_valida = tem_tamanho and tem_maiuscula and tem_numero and tem_simbolo

print("Senha válida:", senha_valida)
print("Tamanho:", tem_tamanho)
print("Maiúscula:", tem_maiuscula)
print("Número:", tem_numero)
print("Símbolo:", tem_simbolo)
