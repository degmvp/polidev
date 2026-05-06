# bool_adv_13.py
# POLYDEV - PYTHON BOOLEAN
# Tema: Operadores all() e any()

validacoes = [True, True, False, True]

print("Todas verdadeiras?", all(validacoes))
print("Alguma verdadeira?", any(validacoes))

campos = ["nome", "email", "telefone"]
formulario_valido = all(campo != "" for campo in campos)

print("Formulário válido:", formulario_valido)
