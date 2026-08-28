print('-' * 70)
print('Trabalhando com modulos em Python!')
print('Usar a qualificação do modulo para chamar as funções !)')
print('isto é nome do modulo + . + função -->>calendar.prmonth(2017,5)!)')
print('Deg - Python 3.6 - em 2017/05/17 ')
print('-' * 70)
print('Programa - 012 - Python 3.6 ')
print('-' * 70)
import calendar
calendar.prmonth(2018,7)
print('-' * 70)
import calendar
print('-' * 70)
print('Criar uma lista ls = [10,30,60] ')
print('Aplicar o calculo do cubo em cada valor da lista ls = [10,30,60] ')
print('Usar a função map na solução mantendo os valores de ls = [10,30,60] ')
print('Atribuir os valores a uma nova lista lx com os calculos!')
print('listar ls = [10,30,60] ')
print('listar lx = [??,??,??] ')
print('-' * 70)
print('Solução do problema')
print('-' * 70)
#------------------------------------------------------------------
def sroot(x):
    return x * 2
def cubo(x): return x*x*x

ls = [10,30,60]
print('Criando a lista ls = [10,30,60] ')
print('Aplicando a função cubo em cada membro da ls -->> ',[*map(cubo,ls)])
lx =  [*map(cubo,ls)]
print('Atribuindo os valores calculados a lx -->>  lx = [*map(cubo,ls)]')
print ('Imprimindo ls -->> ',ls)
print ('Imprimindo lx -->> ',lx)

print ('O uso da função map : ' )
print ('Ela possui dois argumentos o primeiro atua sobre o segundo :')
print ('Neste caso -->> [*map(cubo,ls)] ela calcula o cubo de todos os')
print ('elementos da lista ls [10,30,60]')
print ('Colocando o resultado no endereço de memoria apontado pelo ponteiro *map\n')
print('-' * 70)
print ('Imprime o calendario completo -->> calendar.prcal(2017')
from calendar import prcal
prcal(2018)

def pow(x):
    return x**2

print('---------------------------------------')
print('✅ A função map')
print('✅ map(pow, range(10))')
print('---------------------------------------')
mapa = map(pow, range(10))
print (*mapa)

ran = tuple(map(pow, range (10)))
print (ran)
