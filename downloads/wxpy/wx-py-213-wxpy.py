print('✅' * 50)
print('''
#---------------------------------------
# ✅ trick01
# ✅ Python 3.6 alterado: 2018/08/27
# ✅ Objetivo: Transformar 2 dicionarios em 1
#---------------------------------------''')
print('✅' * 50)

print(''' 
#------------------------------------------------------ 
# ✅ Transformar x,y dicionarios em z
#-------------------------------------------------------''')
print('Transformar x,y dicionarios em z')
x = {'a': 1, 'b': 2}
y = {'c': 3, 'd': 4}
z = {**x, **y}
print('x-->', x)
print('y-->', y)
print('atribuir  na variavel z = {**x, **y}')
print('z-->', z)

print(''' 
#------------------------------------------------------ 
# ✅ Passar 2 dicionarios como argumentos
#-------------------------------------------------------''')
print('Passar 2 dicionarios como argumentos')


def proc_data(a, b, c, d):
    print('saida da função', a, b, c, d)


print('x-->', x)
print('y-->', y)
print('z-->', z)

print('arg da função proc_data(a,b,c,d)\ndic x, dic y \nproc_data(**x, **y)')
proc_data(**x, **y)

print(''' 
#------------------------------------------------------ 
# ✅ Transformar uma lista em dicionario
#-------------------------------------------------------''')
print('Transformar uma lista em dicionario')
print('variavel vlist -->')
vlist = ['F0', 'F1', 'F2', 'F3', 'F4']
print(vlist)
print('list_to_dic = {i:f for f, i in zip(vlist, range(len(vlist)))}')
list_to_dic = {i: f for f, i in zip(vlist, range(len(vlist)))}
print(list_to_dic)

print(''' 
#---------------------------------------- 
# ✅ Print - A função enumerate()
#    Retorna uma tupla (indice,elemento) 
#----------------------------------------''')
progs = ['item1', 'item2', 'item3', 'item4']
for i, ref in enumerate(progs):
    print(i, '=>', ref)
print('--------->----------')
vtl = []
vstmes = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez']
lstmes = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez']
vtl = vstmes

print(vtl[0])
print(vtl[11])

(vtl[-1])
print(vtl[-2])
print(vtl[1:])
print(lstmes)

print('vstmes é --> ', type(vstmes))
print('vtl    é --> ', type(vtl))
print('lstmes é --> ', type(lstmes))

print(''' 
#------------------------------------------------------ 
# ✅Transformar vlist em dicionario\nUsando enumerate 
#-------------------------------------------------------''')
print('Transformar vlist em dicionario\nUsando enumerate')
print('list(enumerate(vlist))-->')
print(list(enumerate(vlist)))

print('dict(enumerate(vlist))-->')
print(dict(enumerate(vlist)))

print('{i: f for i, f in enumerate(vlist)}-->')
print({i: f for i, f in enumerate(vlist)})

print(''' 
#------------------------------------------------------ 
# ✅Slicing Trick - Reversing--> 
#-------------------------------------------------------''')

print('Slicing Trick - Reversing-->')


def reverse_string1(s):
    return s[::-1]


print(reverse_string1('asobrab semog ramged'))
for elem in ('DEGMAR'):
    print(elem)

print(''' 
#------------------------------------------------------ 
# ✅--Improved numeric literals-->
#-------------------------------------------------------''')
print('--Improved numeric literals-->')
print(1_000_000_000_000_000)
print('{:_}'.format(18446744073709551616))
print('{:_x}'.format(0xFFFFFFFF))

print(''' 
#------------------------------------------------------ 
# ✅--String interpolation-->
#-------------------------------------------------------''')
print('String interpolation-->')

var = 'string interpolation'
v = f'Novo FORMATTED STRING LITERALS {var} isto e interpolação!'
print(v)

a = 5
b = 10
ab = f'cinco mais dez são {a + b} isto e interpolação!'
print(ab)

print(''' 
#------------------------------------------------------ 
# ✅Decimal fixed point and floating point arithmetic
#-------------------------------------------------------''')
print('Decimal fixed point and floating point arithmetic-->')
from decimal import *

width = 10
precision = 4
value = Decimal("12.34567")
val = f"result: {value:{width}.{precision}}"
print(val)

data = list(map(Decimal, '1.34 1.87 3.45 2.35 1.00 0.03 9.25'.split()))
print(data)
print('valor maximo--> ', max(data))
print('valor minimo--> ', min(data))
print('valor somatorio->', sum(data))

print(''' 
#------------------------------------------------------ 
# ✅ items() Como classificar um dicionario pelo valor 
#-------------------------------------------------------''')
xs = {'a': 4, 'b': 3, 'c': 2, 'd': 1}
print('xs = dicionario')
print(xs)
print('sorted(xs.items(), key=lambda x: x[1])')
print(sorted(xs.items(), key=lambda x: x[1]))
print('xs.items()')
print(xs.items())

xa = {}
xa = sorted(xs.items(), key=lambda x: x[1])
print(list(xa))

print(''' 
#------------------------------------------------------ 
# ✅ Um dicionário de ações usando lambda 
#-------------------------------------------------------''')

print('''
#actions = { 
    'sum': lambda x, y: x + y, 
    'sub': lambda x, y: x - y, 
    'mul': lambda x, y: x * y, 
} 

func = actions['sum'] 
print(func(10, 20)) 

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
# ✅ função emulando switch com lambda
#-------------------------------------------------------''')


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

print(''' 
#------------------------------------------------------ 
# ✅ Permutações de itens in Python 
#-------------------------------------------------------''')
import itertools

for p in itertools.permutations('5678'):
    print(p)
