print('✅' * 50)
print('''
#----------------------------------------------------
# ✅ trick03
# ✅ Python 3.6 alterado: 2018/09/02
# ✅ Objetivo: Operadores e fatiamento de sequências
#----------------------------------------------------''')
print('✅' * 50)

print(''' 
#------------------------------------------------------ 
# ✅ --Sequências são coleções ordenadas embutidas: 
#    --strings, listas, tuplas e buffers.
#    +---+---+---+---+---+---+
#    | p | y | t | h | o | n |
#    +---+---+---+---+---+---+
#      0   1   2   3   4   5
#-------------------------------------------------------''')
print('ao fatiar uma string teremos como resultado\numa nova string fatiada:')
print('python [:3]')
print("python"[:3])
print('-' * 40)

print('ao fatiar uma lista teremos numa nova lista fatiada:')
print(''' ["p", "y", "t", "h", "o", "n"][:3] ''')
print(["p", "y", "t", "h", "o", "n"][:3])
print('-' * 40)

print('''p = "python" ''')
p = "python"

print('''
print(p[0]) 
print(p[1]) 
print(p[2]) 
print(p[3]) 
print(p[4]) 
print(p[5])
''')

print(p[0])
print(p[1])
print(p[2])
print(p[3])
print(p[4])
print(p[5])

print('-' * 40)

print('''
print(p[-1]) 
print(p[-2]) 
print(p[-3]) 
print(p[-4]) 
print(p[-5])
print(p[-6])''')

print(p[-1])
print(p[-2])
print(p[-3])
print(p[-4])
print(p[-5])
print(p[-6])

print(''' 
#--------------------------------------------------------------------------- 
# ✅O operador [a:b] possui o comprimento de a (inclusive) até b(exclusive):
#---------------------------------------------------------------------------''')
print('''
print(p[0:1]) 
print(p[1:2]) 
print(p[2:3]) 
print(p[3:4]) 
print(p[4:5]) 
print(p[5:6]) 
''')

print(p[0:1])
print(p[1:2])
print(p[2:3])
print(p[3:4])
print(p[4:5])
print(p[5:6])

print(''' 
#----------------------------------------------------------- 
# ✅O operador [:b] possui o comprimento até b (exclusive)":
#-----------------------------------------------------------''')
print('''
p[:1] # 'p'
p[:2] # 'py'
p[:3] # 'pyt'
p[:4] # 'pyth'
p[:5] # 'pytho'
p[:6] # 'python'
''')

print(p[:1])
print(p[:2])
print(p[:3])
print(p[:4])
print(p[:5])
print(p[:6])

print(''' 
#---------------------------------------- 
# ✅O operador [a:] possui o comprimento
#   a partir de a(inclusive):
#----------------------------------------''')
print('''
print(p[:]) 
print(p[1:])
print(p[2:])
print(p[3:])
print(p[4:])
print(p[5:])
print(p[6:])
''')

print(p[:])
print(p[1:])
print(p[2:])
print(p[3:])
print(p[4:])
print(p[5:])
print(p[6:])

print(''' 
#------------------------------------------------------ 
# ✅Fatiamento usando dois indices
#-------------------------------------------------------''')
print('''
#------------------------------
x = '0123456789'
print(x[0:2]) #01
print(x[1:2]) #1
print(x[2:4]) #23
print(x[0:5]) #01234
print(x[1:8]) #1234567
#------------------------------
#omitindo indices
print(x[:2]) #01
print(x[4:]) #456789
print(x[4:-1]) #45678
print(x[-4:-1]) #678
print(x[:]) #0123456789
#-------------------------------
''')

print(''' 
#------------------------------------------------------ 
# ✅operador [a:b:n] que representa de n em n itens.
#-------------------------------------------------------''')
print('''
print(x[::2]) #02468
print(x[::1]) #0123456789
print(x[::3]) #0369
print(x[::4]) #048
print(x[::-1])#9876543210 
#----------------------------
''')

print(''' 
#------------------------------------------------------ 
# ✅ Operações com sequências
#    Operadores	Descrição 
#-------------------------------------------------------''')
print('''
       s[-i]	acesso a um item pelo final
       s+z	concatenação
       s*n n	cópias de s concatenadas
       i in s	teste de inclusão
       i not in s teste de inclusão negativo''')

print(''' 
#------------------------------------------------------ 
# ✅Funções nativas p/ sequências
#   Operadores	Descrição
#-------------------------------------------------------''')
print('''
len(s)	número de elementos
min(s)	valores mínimo contido em s
max(s)	valores máximo contido em s
sorted(s)	devolve uma lista com itens de s em ordem ascendente
reversed(s)	retorna um iterador para percorrer os elementos do último ao primeiro
''')

print(''' 
#------------------------------------------------------ 
# ✅ Um dicionário de ações usando lambda 
#-------------------------------------------------------''')

print('''
def func_lambda(operator, x, y):
    return {
        'add': lambda: x + y,
        'sub': lambda: x - y,
        'mul': lambda: x * y,
        'div': lambda: x / y,
    }.get(operator, lambda: None)()

print(func_lambda('add', 12, 8))
print(func_lambda('sub', 12, 8))
print(func_lambda('mul', 12, 8))
print(func_lambda('div', 12, 4))
#-------------------------------------------------------''')
print(''' 
#------------------------------------------------------ 
# ✅ Working With tricks in Python
#------------------------------------------------------
#------------------------------------------------------
#-------------------------------------------------------''')



