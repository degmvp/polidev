print('✅' * 50)
print('''
--------------------------------------------------
# ✅ binN05
# ✅ Python 3.6 alterado: 2018/07/29
# ✅ Objetivo: Busca binária iterativa,
               Busca binária  recursiva
# ✅ Comandos:binary_search_ite,binary_search_rec(
# ✅ Funções:pow(),[*map(pow,x,y)]
#-------------------------------------------------''')
print('✅' * 50)
print('Descompactação de Argumentos em Lista --> list(range(*L))')
L = [0, 16]
print(list(range(*L)))

print('Compreensão de listas --> qua = [z**2 for z in range(10)]')
qua = [z ** 2 for z in range(10)]
print(qua)
print('-' * 47)

print('--------->---------------------------<---------')
print('--------->PYTHON PARA DESENVOLVEDORES----------')
print('--------->---------------------------<---------')
print('--------->Operações Binarias Deltas<-----------')
print('''
--------------------------------------------------
>>> print 127      # Usando literal decimal
>>> print (0x7F)   # Usando literal hexadecimal
--------------------------------------------------
Construtores de Python
----------------------
 b = bool(True)
 i = int(100)
 f = float(100.1)
 c = complex(3.0, 1.2)
 print b, i, l, f, c
----------------------''')
print('''--------->Operações Binarias Bitwise/Deltas<-----------
----------------------------------------
--Aplicação pratica da Algebra Bolena-01
----------------------------------------
--Delta -->[a = b] = 1 -abs(sign(a - b))
----------------------------------------''')
import random


# busca binária iterativa
def binary_search_ite(vet, num):
    esquerda, direita, tentativa = 0, len(vet), 1
    while 1:
        meio = (esquerda + direita) // 2
        aux_num = vet[meio]
        if num == aux_num:
            return tentativa
        elif num > aux_num:
            esquerda = meio
        else:
            direita = meio
        tentativa += 1


def binary_search_rec(vet, num, esq, dir, tentativa):
    meio = (esq + dir) // 2
    aux_num = vet[meio]
    if num == aux_num:
        return tentativa
    elif num > aux_num:
        return binary_search_rec(vet, num, meio, dir, tentativa + 1)
    return binary_search_rec(vet, num, esq, meio, tentativa + 1)


def teste():
    vet = [i for i in range(1, 1000001)]
    num = random.choice(vet)
    print('Numero escolhido: %d' % num)
    print('Tentativa (iterativo): %d' % binary_search_ite(vet, num))
    print('Tentativa (recursivo): %d' % binary_search_rec(vet, num, 0, len(vet), 1))


teste()


def binarySearch(alist, item):
    tentativa = 0
    if len(alist) == 0:
        return False
    else:
        midpoint = len(alist) // 2
        tentativa += 1
        if alist[midpoint] == item:
            return print('o item existe na lista -->', item, 'tentativa-->', tentativa)
        else:
            if item < alist[midpoint]:
                tentativa += 1
                return binarySearch(alist[:midpoint], item)
            else:
                tentativa += 1
                return binarySearch(alist[midpoint + 1:], item)


vet = [i for i in range(1, 1000001)]
binarySearch(vet, 1945)
print('><' * 22)

print('usando a função pow(x,y)', pow(2, 8))
print('usando a função pow(x,y)', pow(2, 16))
print('usando a função pow(x,y)', pow(2, 31))
print('><' * 22)
x = [2, 2, 2]
print('valores de x = [2,2,2]   -->', x)
y = [8, 16, 31]
print('valores de y = [8,16,31] -->', y)
for i in range(1, 2):
    r = [*map(pow, x, y)]
    print('imprime a função map -->', r)
print('><' * 22)









