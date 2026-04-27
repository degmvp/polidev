print('✅' * 50)
print('''
#---------------------------------------
# ✅ AppA01
# ✅ Python 3.6 alterado: 2018/07/31
# ✅ Objetivo:Cmd tuplas,lambda,dic,listas
#---------------------------------------''')
print('✅' * 50)

print('''
# ✅ self --> é uma variavel de classe
# ✅ self --> passa toda -->class<-- para
# ✅      --> dentro da definição -->def<--
#------------------------------------------''')
print('✅' * 50)

print('''
#-------------------------------------
# ✅ Modulo de Processo(Dic/Lista/Tupla
#--------------------------------------''')

print('''
#------------------------------------------------------
# ✅ items() retorna uma lista de tuplas chave e o valor
#-------------------------------------------------------''')
dic = {'key1': 'cpo alfa1', 'key2': 'cpo alfa2', 'key3': 'cpo alfa3'}

print(dic.items())

for ref, ref1 in dic.items():
    print(ref, '=>', ref1)

for ref, ref1 in dic.items():
    print('{0} {1} -->usando format'.format(ref, ref1))

print('''
#------------------------------------------------------
# ✅ items() Como classificar um dicionario pelo valor
#-------------------------------------------------------''')
xs = {'a': 4, 'b': 3, 'c': 2, 'd': 1}
print(xs)
print(sorted(xs.items(), key=lambda x: x[1]))
print(xs.items())

xa = {}
xa = sorted(xs.items(), key=lambda x: x[1])
print(list(xa))

print('''
#------------------------------------------------------
# ✅ Um dicionário de ações usando lambda
#-------------------------------------------------------''')
actions = {
    'sum': lambda x, y: x + y,
    'sub': lambda x, y: x - y,
    'mul': lambda x, y: x * y,
}

func = actions['sum']
print(func(10, 20))

func = actions['mul']
print(func(10, 20))

func = actions['sub']
print(func(20, 10))

print('''
#------------------------------------------------------
# ✅ Um dicionário de operações bitwise usando lambda
#-------------------------------------------------------''')
bitwise = {
    'and': lambda x, y: x & y,
    'or': lambda x, y: x | y,
    'xor': lambda x, y: x ^ y,
}

print('expressões and - or - xor ')

fcbit = bitwise['and']
print(fcbit(100, 20))

fcbit = bitwise['or']
print(fcbit(50, 20))

fcbit = bitwise['xor']
print(fcbit(100, 20))
print('''
#------------------------------------------------------
# ✅ Usando replace e ações com lambda
#-------------------------------------------------------''')
replace = True
func = replace and (lambda s: s.replace(' ', '_')) or (lambda s: s)
phrase = 'frase usando lambda com replace true'
print(func(phrase))
print('✅' * 50)

replace = False
func = replace and (lambda s: s.replace(' ', '_')) or (lambda s: s)
phrase = 'frase usando lambda com replace false'
print(func(phrase))
print('✅' * 50)


def func(words):
    return [len(w) for w in words]


words = ['look', 'so', 'car', 'ice', 'melted', 'entendi lambda']

print(func(words))

print('''
#-------------------------------------
# ✅ Somatorio dos numeros da roleta
#--------------------------------------''')
s = 0
for x in range(1, 37):
    s = s + x
print('numeros da roleta de 1 a 36 Total---->', s)

tab = []
tab = [x * 7 for x in range(1, 11)]
print('-----------------------------------')
print('Impressão e geração da tabuada de 7')
print('-----------------------------------')
for r1, r2 in enumerate(tab):
    r1 += 1
    if r1 < 10: print(r1, ' x 7 ', r2)
print(r1, 'x 7 ', r2)
print('-----------------------------------')

print('''
#----------------------------------
# ✅ Print - Formatação de strings %
#----------------------------------''')
op = ' % operador de modulo,interpolação ou formatação'
vl = 100
opx = 'usando mais de um valor --> '
print('tecnica de formatação : %s' % op)
print('tecnica de formatação : %d' % vl)
print('tecnica de formatação : %s agora o valor %d' % (opx, vl))

print('''
#--------------------------------------
# ✅ Print Cria uma string template
#    Preenche o modelo com um dicionário
#---------------------------------------''')
import string

vst = string.Template('$txt_sub1 $txt_sub2')
# Preenche o modelo com um dicionário
vs = vst.substitute({'txt_sub1': 'substituido _sub1 ',
                     'txt_sub2': 'substituido _sub2'})
print(vs)
print('--------->-------------------------')

print('--------->----------')
print('''
#----------------------------------
# ✅ Print - A função enumerate()
#----------------------------------''')
progs = ['item1', 'item2', 'item3', 'item4']
for i, ref in enumerate(progs):
    print(i, '=>', ref)
print('--------->----------')

vtl = []
vstmes = ('jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez')
lstmes = ('jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez')
vtl = vstmes

print(vtl[0])
print(vtl[11])
print(vtl[-1])
print(vtl[-2])
print(vtl[1:])

print('''
#------------------------------------------
# ✅ A função enumerate() retorna uma tupla
#    de dois elementos a cada iteração:')
#------------------------------------------''')
for ref1, ref2 in enumerate(vtl):
    print(ref1 + 1, '=>', ref2)

someTuple = (1, 2)
someList = [1, 2]
print('someTuple = (1,2)-->', someTuple)
print('someList  = [1,2]-->', someList)

print('''
#---------------------------------------
# ✅ A lista vazia é avaliada como falsa
#---------------------------------------''')
lista = ['A', 'B', 'C']
print('lista:', lista)
while lista:
    print('Saiu', lista.pop(0), ', faltam', len(lista))
# Mais itens na lista
lista += ['D', 'E', 'F']
print('lista:', lista)
while lista:
    print('Saiu', lista.pop(), ', faltam', len(lista))
print('--------->----------')

matriz = '''0 0 0 0 0 0 0 0 0 0 0 0
9 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 4 0 0
0 0 0 0 0 0 0 3 0 0 0 0
0 0 0 0 0 0 5 0 0 0 0 0
0 0 0 0 6 0 0 0 0 0 0 0'''

print('''
#---------------------------------------
# ✅ Imprime matriz
#---------------------------------------''')
print(matriz)

print('''
#---------------------------------------
# ✅ Quebra a matriz em linhas
#---------------------------------------''')
mat = {}

for linha in enumerate(matriz.splitlines()):
    print('{0} '.format(linha))

print('''
#---------------------------------------
# ✅ Concatenação e Interpolação
#---------------------------------------''')
s = 'Python: '
print('A linguagem : ' + s + ' é excelente!')

print('tamanho de %s => %d' % (s, len(s)))

print('''
#---------------------------------------
# ✅ String tratada como sequência
#    Strings são objetos
#---------------------------------------''')
for ch in s: print(ch)

print(s[0], s[:2], s[2:])

if s.startswith('P'): print(s.upper())

print('''
#----------------------------------
# ✅ Print - Metodo str.format
#    print('metodo str.format --> {0}, e {1}!'.format(a1,a2))
#----------------------------------''')

a1 = 'primeiro arg '
a2 = 'segundo arg'
print('metodo str.format --> {0}, e {1}!'.format(a1, a2))

a = 42
b = 15


def print_dec_and_bits(value):
    print('Dec: {:d} --> {:3b}'.format(value, value))


print_dec_and_bits(a)
print_dec_and_bits(b)
xab = a & b
print_dec_and_bits(xab)

print('usando fcbit com valor de a,b')
fcbit = bitwise['and']
print(fcbit(a, b))

ax = 25.37
print('valor decimal com duas casas --> %5.2f' % (ax))
print('Agora são %2d:%2d.' % (16, 30))
print('Perc. uma decimal: %.1f%%' % (25.333))
print('Perc. Treis decimais: %.3f%%' % (25.333))

vstmsg = '{0} {1} {2} format usa ix da variavel --> vstmsg'
print(vstmsg)
print('--------->----------')
print('--------Listagem saida do código Python --------')
lstxt = [('txt1', 'txt2', 'txt3'),
         ('va1', 'va2', 'va3')]
for ref1, ref2, ref3 in lstxt:
    print(vstmsg.format(ref1, ref2, ref3))
    print('{0} {1} {2} -->format usa ix em print()'.format(ref1, ref2, ref3))
print('--------->----------')
print('--------->----------')
print('Decimal: %d, binario: %s, Hexadecimal: %x' % (15, bin(15), 15))
print('--------->----------')

print('--------->----------')

vstmes = ('jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez')
lstmes = ('jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez')
for ref1 in lstmes:
    print(ref1)
print('--------->----------')
print(lstmes[0])
print(lstmes[11])
print(lstmes[-1])
print(lstmes[-2])
print('--------->----------')

a = tuple(range(20))
b = list(range(20))
print(a)
print(b)

print('tamanho de a tupla -->', a.__sizeof__())  # 8024
print('tamanho de b lista -->', b.__sizeof__())  # 9088

b[0] = 1945
print('inserindo um elemento em b --> 1945', b)

print('imprimindo o id(a)', id(a))
a += (1945,)
print('inserindo um elemento em a --> 1945', a)
print('altera o id(a) --->', id(a))

print('''
#----------------------------------
# ✅ list – list.reverse() Method
#----------------------------------''')
mylist = [1, 2, 3, 4, 5]
mylist.reverse()
print(mylist)
# [5, 4, 3, 2, 1]

print('''
#----------------------------------
# ✅ list – Slicing Trick to Reverse
#----------------------------------''')
mylist = [1, 2, 3, 4, 5]

print(mylist[::-1])

print(mylist[:1])
''' print(mylist[:2])
[1, 2]
>>> print(mylist[:3])
[1, 2, 3]
>>> print(mylist[:4])
[1, 2, 3, 4]
>>> print(mylist[:5])
[1, 2, 3, 4, 5]'''
# --------------------------------
'''
>>> mylist[start:end:step]
>>> mylist
[1, 2, 3, 4, 5]
>>> mylist[1:3]
[2, 3]'''
# --------------------------------
'''
>>> mylist[::]
[1, 2, 3, 4, 5]

>>> mylist[::2]
[1, 3, 5]

>>> mylist[::-2]
[5, 3, 1]

>>> mylist[::3]
[1, 4]

>>> mylist[::4]
[1, 5]

>>> mylist[::5]
[1]

>>> mylist[::1]
[1, 2, 3, 4, 5]'''

print('''
#----------------------------------
# ✅ reversed() Built-In Function
#----------------------------------''')
mylist = [1, 2, 3, 4, 5]
for item in reversed(mylist):
    print(item)

x_list = [1, 2, 3]
y_list = [2, 4, 6]

for x, y in zip(x_list, y_list):
    print(x, y)
# ----------------------------------------
# -----------------------------------------
x = 2
y = 5

msg = 'x foi maior do que y' if x > y else 'y foi maior do que x'

print(' check : %s' % msg)
# -------------------------------------------
# Python 3.6 Cool new features
# -------------------------------------------
# Format String Literals
# -------------------------------------------
name = 'Deg'
print(f'Oi, {name}!')

a = 5
b = 10
print(f' 5 mais 10 são: {a + b} e não { 2 * (a + b)}')


def soma(a: int, b: int) -> int:
    return a + b


print(soma(64, 128))
python_version: float = 3.61
print('a versão atual é: python_version  ', python_version)

print('''
#----------------------------------
# ✅ list – Mutable Dynamic Arrays
#----------------------------------''')
import array

print('#------------Array textos------------------------------')
arraytxt = ['vet0', 'vet1', 'vet2']
print(arraytxt)
print(type(arraytxt))  # <class 'list'>
print('#------------Array inteiros------------------------------')
arrayint = [110, 191, 215, 319, 2300, 2388, 3300]
print(arrayint)
print(type(arrayint))  # <class 'list'>
print('acesso ao elemento 1 do arrayint --> ', arrayint[1])
print('#------------Array decimais------------------------------')
arraydec = array.array('f', (1.0, 1.5, 2.0, 2.5))
print(arraydec)
print(type(arraydec))  # <class 'array.array'>
print('#------------Array floating------------------------------')
arrayfloat = ((1.0, 1.5, 2.0, 2.5))
print(arrayfloat)
print(type(arrayfloat))  # <class 'tuple'>

print('#------------Array alterados------------------------------')
arraytxt[1] = 'vet0-modificado'
print(arraytxt)

arrayint[1] = (9999)
print(arrayint)

arraydec[1] = (1.9)
print(arraydec)

arraytxt.append('23')
print(arraytxt)

arrayint.append(23)
print(arrayint)

arraydec.append(23)
print(arraydec)

print('''
#-------------------------------------
# ✅ tuple – Immutable Containers
#-------------------------------------''')
tuparr = 'tup0', 'tup1', 'tup2'
print(tuparr)
print(tuparr[0])
print('''
#Tuples are immutable:
#tuparr[1] = 'hello'
#TypeError: "'tuple' object does not support item assignment

#del arr[1]
#TypeError: "'tuple' object doesn't support item deletion"

# Tuples can hold arbitrary data types:
# (Adding elements creates a copy of the tuple)''')
tupcopy = tuparr + (23,)
print(tuparr)
print(tupcopy)

print('''
#-------------------------------------
# ✅ array.array – Basic Typed Arrays
#-------------------------------------''')
arr = array.array('f', (1.0, 1.5, 2.0, 2.5))
print(arr)
print(arr[1])

# Arrays are mutable:
arr[1] = 23.0
print(arr)
# array('f', [1.0, 23.0, 2.0, 2.5])

del arr[1]
print(arr)
# array('f', [1.0, 2.0, 2.5])

arr.append(42.0)
print(arr)
# array('f', [1.0, 2.0, 2.5, 42.0])

print('''
#-------------------------------------
✅ str – Immutable Arrays of Unicode
       - Characters
#-------------------------------------''')
alfa = 'abcd'
print(alfa)

# Strings are immutable:
# >>> arr[1] = 'e'
# TypeError: "'str' object does not support item assignment"

# >>> del arr[1]
# TypeError: "'str' object doesn't support item deletion"

# Strings can be unpacked into a list to
# get a mutable representation:
list('abcd')
print('-->list ', list)
''.join(list('abcd'))
'abcd'

print('''
#------------------------------------------
✅ bytes – Immutable Arrays of Single Bytes
#------------------------------------------''')
arrbyte = bytes((0, 1, 2, 3))
print(arrbyte)
# b'\x00\x01\x02\x03'

arrb1 = b'\x00\x01\x02\x03'
print(arrb1)

print('''
#--------------------------------------------
✅ bytearray – Mutable Arrays of Single Bytes
#--------------------------------------------''')
arrb2 = bytearray((0, 1, 2, 3))
print(arrb2[1])

# >>> arrb2
# bytearray(b'\x00\x01\x02\x03')

# Bytearrays are mutable:
arrb2[1] = 23
# arrb2
# bytearray(b'\x00\x17\x02\x03')
print(arrb2[1])

# Bytearrays can grow and shrink in size:
del arrb2[1]
print(arrb2)
# bytearray(b'\x00\x02\x03')

arrb2.append(42)
print(arrb2)
# bytearray(b'\x00\x02\x03*')

# Bytearrays can only hold "bytes"
# (integers in the range 0 <= x <= 255)

# Bytearrays can be converted back into bytes objects:
# (This will copy the data)
print(bytes(arrb2))

print('✅' * 50)
'''
with open('app_tipA.py') as f:
    for line in f:
        print (line)
'''
print('✅' * 50)
