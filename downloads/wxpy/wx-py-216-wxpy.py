print('✅' * 50)
print('''
#----------------------------------------------------
# ✅ trick04
# ✅ Python 3.6 alterado: 2018/09/07
# ✅ Objetivo: Operadores e fatiamento de sequências
#----------------------------------------------------''')
print('✅' * 50)

print(''' 
#------------------------------------------------------ 
# ✅ --Built-in Dictionary Methods
#-------------------------------------------------------''')
d = {(1, 1): 'a', (1, 2): 'b', (2, 1): 'c', (2, 2): 'd'}
print(d[(1, 1)])
print(d[(2, 1)])

print(''' 
#--------------------------------------------------------------------------- 
# ✅The .items(), .keys(), and .values() .get() methods actually return
#   something called a view object
#---------------------------------------------------------------------------''')
e = {'a': 10, 'b': 20, 'c': 30, 'y': 50, 'w': 70, }
print(e.get('a'))
print(e.get('c'))
print(e.get('z', -1))

print(list(d.items()))
print(list(e.items()))

print(list(d.keys()))
print(list(e.keys()))

print(list(d.values()))
print(list(e.values()))

print(e.pop('a'))
print(e.popitem())

d1 = {'a': 10, 'b': 20, 'c': 30}
d2 = {'d': 200, 'e': 400}

d1.update(d2)
print(d1)

print('-' * 40)
print(''' 
#--------------------------------------------------------------------------- 
# ✅Basic Data Types in Python
#---------------------------------------------------------------------------''')
print('Integers', 100)
print(123123123123123123123123123123123123123123123123 + 1)

print('Binary-->0b')
print('Binary-->0B')
print(0b100)
print(0B100)

print('Hexadecimal-->0x')
print('Hexadecimal-->0X')
print(0x10)
print(0X10)

print(''' 
#----------------------------------------------------------- 
# ✅Itertools functions Py3: accumulate(iterable[, func])
#-----------------------------------------------------------''')
import operator


def accumulate(iterable, func=operator.add):
    'Return running totals'
    # accumulate([1,2,3,4,5]) --> 1 3 6 10 15
    # accumulate([1,2,3,4,5], operator.mul) --> 1 2 6 24 120
    it = iter(iterable)
    try:
        total = next(it)
    except StopIteration:
        return
    yield total
    for element in it:
        total = func(total, element)
        yield total


data = [3, 4, 6, 2, 1, 9, 0, 7, 5, 8]
xop_add = list(accumulate(data))
print(xop_add)

xop_mul = list(accumulate(data, operator.mul))
print(xop_mul)

print(list(accumulate(data, max)))
print(list(accumulate(data, min)))

print(''' 
#---------------------------------------- 
# ✅Amortize a 5% loan of 1000 with 4
#   annual payments of 90
# cashflows = [1000, -90, -90, -90, -90]
# print(list(accumulate(cashflows, lambda bal, pmt: bal*1.05 + pmt)))
#----------------------------------------''')
cashflows = [1000, -90, -90, -90, -90]
print(list(accumulate(cashflows, lambda bal, pmt: bal * 1.05 + pmt)))

print(''' 
#------------------------------------------------------ 
# ✅functools.reduce(function, iterable[, initializer])
#    initializer = None, or 1.....N
#-------------------------------------------------------''')


def reduce(function, iterable, initializer=None):
    it = iter(iterable)
    if initializer is None:
        value = next(it)
    else:
        value = initializer
    for element in it:
        value = function(value, element)
    return value


print(reduce(lambda x, y: x + y, [1, 2, 3, 4, 5]))

print(''' 
#------------------------------------------------------ 
# ✅functools.partial(func, *args, **keywords)
#-------------------------------------------------------''')
from functools import partial

basetwo = partial(int, base=2)
print(basetwo('10010'))

basehexa = partial(int, base=16)
print(basehexa('10010'))

print(''' 
#------------------------------------------------------ 
# ✅ use itertools.zip_longest() 
#-------------------------------------------------------''')
import itertools as it


def grouper(inputs, n, fillvalue=None):
    iters = [iter(inputs)] * n
    return it.zip_longest(*iters, fillvalue=fillvalue)


nums = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
print(list(grouper(nums, 4)))
print(list(grouper(nums, 2)))

print(''' 
#------------------------------------------------------ 
# ✅Funções nativas p/ sequências
#   Operadores	Descrição
#-------------------------------------------------------''')

print(''' 
#------------------------------------------------------ 
# ✅ Um dicionário de ações usando lambda 
#-------------------------------------------------------''')

print(''' 
#------------------------------------------------------ 
# ✅ Working With tricks in Python
#------------------------------------------------------''')
print(''' 
#------------------------------------------------------ 
# ✅ Um dicionário de operações bitwise usando lambda 
#-------------------------------------------------------''')


def fcbit(operator, x, y):
    return {
        'and': lambda x, y: x & y,
        'or': lambda x, y: x | y,
        'xor': lambda x, y: x ^ y,
    }.get(operator, lambda: None)(x, y)


print('expressões and - or - xor ')

print(fcbit('and', 100, 20))

print(fcbit('or', 50, 20))

print(fcbit('xor', 100, 20))



