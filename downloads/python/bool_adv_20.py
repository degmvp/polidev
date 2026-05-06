# bool_adv_20.py
# POLYDEV - PYTHON BOOLEAN
# Tema: Mini ALU booleana com operações bitwise

def alu(op, a, b):
    if op == "AND":
        return a & b
    if op == "OR":
        return a | b
    if op == "XOR":
        return a ^ b
    if op == "SHL":
        return a << b
    if op == "SHR":
        return a >> b
    raise ValueError("Operação inválida")

a = 12  # 1100
b = 3   # 0011

for op in ["AND", "OR", "XOR", "SHL", "SHR"]:
    resultado = alu(op, a, b)
    print(op, "=>", resultado, bin(resultado))
