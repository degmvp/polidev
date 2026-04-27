print('-' * 70)
print('Cria dicionario e funções --> map (x,y) <-- [*map[x,y] ')
print('metodos append-extend-insert-remove-pop-index-count-sort-reverse ')
print('-' * 70)
print('Deg - Python 3.6 - em 2017/05/01 ')
print('-' * 70)
print('Programa - 005 - Python 3.6 ')
print('-' * 70)
dic = {}      #dicionario vazio.
dic ['a'] = 65
dic ['b'] = 66
dic ['c'] = 67
dic ['d'] = 68
dic ['e'] = 69
dic ['f'] = 70
dic ['g'] = 71
dic ['h'] = 72
dic ['i'] = 73
dic ['j'] = 74

print ('Lista dicionario :\n Digite o comando dic:\n Digite o comandso dic.keys() ')
for ch in map(chr,[65,66,67,68]):
    print(ch)
print(dic)
print(dic.keys())

print ('Criação de uma lista!')
print ('lista =  [1, 2, -3, 4, 5, -9]')
lista =  [1, 2, -3, 4, 5, -9]
L     =  [55,66,77]
print ('lista',lista,'\n')
print ('lista',L,'\n')

print ('Criação e definição de uma função!')
print ('def sroot(n): return n*n')
print ('-' * 40)

def sroot(n): return n*n

print ('Criação de uma função como objeto!')
print ('Uso da função MAP !\n [*map(sroot, [1, 2, -3, 4, 5, -9])]')
print ('MAP aplica a função sroot sobre os parametros da lista!')
print ('sroot calcula o quadrado de cada elemento da lista!\n')

print('resultado',[*map(sroot, [1, 2, -3, 4, 5, -9])])

print('resultado',[*map(sroot, lista)])

print ('-' * 60)
print('O tipo list possui métodos,eis aqui todos os\n disponíveis em um objeto lista:')
print('valor inicial da lista-->[1, 2, -3, 4, 5, -9]<--')
print ('-->lista.append(4)-->insere o valor 4','\n')
lista.append(4)
print ('lista',lista,'\n')
print ('-' * 60)

print ('-->lista.extend(L)-->insere o valor da lista L(55,66,77)','\n')
lista.extend(L)
print ('lista',lista,'\n')
print ('-' * 60)

print ('-->lista.insert(3, 88)-->insere o valor 88 na posição 3','\n')
lista.insert(3, 88)
print ('lista',lista,'\n')
print ('-' * 60)

print ('-->lista.remove(88)-->remove o valor 88 na lista','\n')
lista.remove(88)
print ('lista',lista,'\n')
print ('-' * 60)

print ('-->lista.pop(2)-->remove o valor do indice 2 na lista','\n')
lista.pop(2)
print ('lista',lista,'\n')
print ('-' * 60)

print ('-->lista.index(5)-->devolve o indice da primeira ocorrencia de valor 5','\n')
lista.index(5)
print ('lista',lista.index(5),'\n')
print ('-' * 60)

print ('-->lista.count(4)-->devolve o numero de vezes que ocorre o valor 4','\n')
lista.count(4)
print ('lista',lista.count(4),'\n')
print ('lista',lista,'\n')
print ('-' * 60)

print ('-->lista.sort()-->classifica a lista em ordem crescente','\n')
lista.sort()
print ('lista',lista,'\n')
print ('-' * 60)

print ('-->lista.reverse()-->classifica a lista em ordem inversa','\n')
lista.reverse()
print ('lista',lista,'\n')
print ('-' * 60)

def cubo(x): return x*x*x
print('resultado',[*map(cubo, [1, 2, -3, 4, 5, -9])])

lista =  [1, 2, -3, 4, 5, -9]
print('resultado',[*map(cubo, lista)])

print ('-' * 70)
print('usando map com range',[*map(cubo, range(1, 11))])
print ('-' * 70)

print('-' * 70)
print('import calendar')
print('-' * 70)
print('Deg - Python 3.6 - em 2017/05/06 ')
print('-' * 70)
print('Programa - 010 - Python 3.6 ')
print('-' * 70)
print('quando encerramos o Python e reiniciamos todas as definições')
print('feitas ( funções e variaveis) são perdidas!')
import calendar

calendar.prmonth(2017, 5)

print('Ao tratar funções como objetos,Python torna-se\numa linguagens de programação funcional.\n')
print('O Python possui uma função poderosa chamada MAP')
print('a qual possui dois argumentos.\n')
print('Exemplo :\n usando a função squad que calcula o dobro do valor passado!')
print('usando uma lista m = [10,20,55,40] como argumentos da função MAP teremos:')
print('A função map aplica o objeto-função a cada item do segundo argumento!')
print('O resultado é a criação de um novo objeto-lista, sem modificar o original!\n')

print('Função squad --> def squad (x): return x * 2 ,--')
print('Lista m      --> m = [10,20,55,40]   <--')

m = [10, 20, 55, 40]


def squad(x):
    return x * 2


print('Aplicação da função MAP -->> [*map(squad,m)] <<--')
print('observe o uso do ponteiro onde a função map coloca o resultado')
print([*map(squad, m)])

print('Atribuindo o resultado a uma variavel -->> m1 = [*map(squad, m)] <<-- :')
print('Imprimindo a variavel m1 -->>print(m1)<<-- eis o resultado: ')

m1 = [*map(squad, m)]
print(m1)
print('Imprimindo o original! -->> print(m)')

print(m)
print('exemplo excelente demonstrado!')
