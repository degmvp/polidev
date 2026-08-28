print('✅' * 50)
print('''
#---------------------------------------
# ✅ AppZ04 
# ✅ Python 3.6 alterado: 2017/08/12
# ✅ Objetivo:Cmd aplicados 
#---------------------------------------''')
print('✅' * 50)

variavel = 'Deg'
print(dir(variavel))
'''
>>> variavel
'Deg'
>>> help('variavel'.upper)
Help on built-in function upper:

upper(...) method of builtins.str instance
    S.upper() -> str

    Return a copy of S converted to uppercase.
>>> type(variavel)
<class 'str'>
'''
print(id(variavel))
# calcular quantos digistos tem em 2** 1000
a = str(2 ** 128)
print(a)
print(len(a))

i = 1
fat = 1
n = 10
while i <= n:
    fat = fat * i
    i += 1
    print('Fatorial(%d) = %d' % (n, fat))

i = 1
fat = 1
n = 10
while i <= n:
    fat = fat * i
    i += 1
    print('Fatorial (%d) = %d' % (n, fat))
    if fat == 5040:
        print('Fatorial(break em : %d) = %d' % (n, fat))
        break

soma = 0
while True:
    x = int(input('Digite zero para sair: '))
    if x == 0:
        break
    soma += x
print('Soma: %d' % soma)

print('Impressão e geração da tabuada de 7')
print('-----------------------------------')
tab = []
tab = [x * 7 for x in range(1, 11)]
for r1, r2 in enumerate(tab):
    r1 += 1
    if r1 < 10: print('7 x ', r1, r2)
print('7 x', r1, r2)
print('-----------------------------------')

tab = 1
while tab <= 10:
    n = 1
    print('Tabuada %d' % tab)
    while n < 10:
        print('%d x  %d = %d' % (tab, n, tab * n))
        n += 1
    tab = tab + 1
    print('%d x %d = %d' % (tab - 1, n, tab * n - n))
print('-----------------------------------')

# a = 21
# b = 15
a = 15
b = 21
while a % b != 0:
    a, b = b, a % b
print('mdc = %d' % b)
print('-----------------------------------')

notas = [6, 7, 5, 8, 9]
soma = 0
x = 0
while x < 5:
    soma += notas[x]
    x += 1
print('Media: %5.2f' % (soma / x))
print('-----------------------------------')
vetor = []
i = 1
while i <= 5:
    n = int(input('Digite um numero: '))
    vetor.append(n)
    i = i + 1
print('vetor lido:', vetor)
print(
    '''   
    >>> ls = [10,20,30,40,50,60,70]
    >>> xl = reversed(ls)
    >>> print(*xl)
    70 60 50 40 30 20 10
    >>> ls[::-1]
    [70, 60, 50, 40, 30, 20, 10]''')

print('-----------------------------------')
letras = ['p', 'e', 'r', 'n', 'a', 'm', 'b', 'u', 'c', 'o']
i = 0
cont = 0
while i <= 9:
    if letras[i] not in 'aeiou':
        cont += 1
    i += 1
print('Existe %d consoantes em: ' % cont)
print(letras)
print('-----------------------------------')
palavra = 'arara'
if palavra == palavra[::-1]:
    print('%s é palindrome' % palavra)
else:
    print('%s não é palindrome' % palavra)
print('---------------------------------------------------------')
letras = ['p', 'e', 'r', 'n', 'a', 'm', 'b', 'u', 'c', 'o']
i = 0
cont = 0
while i <= 9:
    if letras[i] in 'aeiou':
        letras[i] = '*'
    i += 1
print(letras)  # ['p', '*', 'r', 'n', '*', 'm', 'b', '*', 'c', '*']
print('---------------------------------------------------------')
arq = 'prog.py'
print(arq.startswith('p'))
print(arq.endswith('py'))
print(arq.upper())
print(arq.lower())
print('---------------------------------------------------------')
s = 'aqui,comeca, texto, para, usar, no, texto, com, cmd, find, replace'
print(s.find('texto'))
print(s.replace('texto', 'string'))
print('---------------------------------------------------------')
txt = 'este texto sera separado pelo cmd split'
print(txt.split())
txt = txt.split()
print(txt)
print('---------------------------------------------------------')
ip = ['198', '188', '10', '144']
print('.'.join(ip))
print(ip)
print('---------------------------------------------------------')
dia, mes, ano = input('Data (dd/mm/aaaa) : ').split('/')
tbmes = ('jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez')
print('voce nasceu em:')
print('%s de %s de %s' % (dia, tbmes[int(mes) - 1], ano))
print('---------------------------------------------------------')


def fat(n):
    f = 1
    while n > 0:
        f = f * n
        n -= 1
    return f


for i in range(10): print(fat(i))
print('---------------------------------------------------------')
import random

print(random.randint(1, 100))

random.choice(['txt1', 'txt2', 'txt3', 'txt4', 'txt5', 'txt6', 'txt7'])
lista = ['txt1', 'txt2', 'txt3', 'txt4', 'txt5', 'txt6', 'txt7']
print(random.shuffle(lista))
print('---------------------------------------------------------')
s = ['palmeiras', 'corintias', 'botafogo', 'flamengo', 'santos', 'txt6', 'txt7']


def embaralha(s):
    lista = list(s)
    print(lista)
    random.shuffle(lista)
    return ' '.join(lista)


embaralha('flamengo')
print('---------------------------------------------------------')
lista = []
for k in range(15):
    lista.append(random.randint(10, 100))
print(lista)
print('---------------------------------------------------------')
lista = []
while len(lista) < 15:
    x = random.randint(10, 100)
    if x not in lista:
        lista.append(x)
lista.sort()
print(lista)
print('---------------------------------------------------------')


def hide(msg):
    s = ''
    for c in msg: s += chr(ord(c) + 30000)
    return s


def hshow(msg):
    s = ''
    for c in msg: s += chr(ord(c) - 30000)
    return s


print(hide('degmar gomes barbosa'))
print(hshow('疔疕疗疝疑疢畐疗疟疝疕疣畐疒疑疢疒疟疣疑'))

