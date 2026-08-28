print('✅' * 50)
print('''
#-------------------------------------------------------
# ✅ PyForm
# ✅ Python 3.6 alterado: 2018/09/24
# ✅ Objetivo:modelo de formulario de entrada de dados
# ✅ Comandos:import from tkinter
#-------------------------------------------------------''')
print('✅' * 50)
from tkinter import *

root = Tk()
root.title("Form - Entry-Grid-Config ✅ ")
root.geometry("850x550")
root.configure(bg="#006")
root.fg = "GOLDENROD"
root.resizable(width=False, height=False)

miframe = Frame(root, bg='GOLDENROD', width=500, height=300)
miframe.place(x=10, y=15)

nome = Entry(miframe, width=50)
nome.grid(row=0, column=1, padx=10, pady=10)
nome.config(fg='green', justify='left')

# ----------------------------
# password
# ----------------------------
pwd = Entry(miframe, width=30)
pwd.grid(row=1, column=1, padx=10, pady=10)
pwd.config(show='*')

apnome = Entry(miframe, width=30)
apnome.grid(row=2, column=1, padx=10, pady=10)

direc = Entry(miframe, width=50)
direc.grid(row=3, column=1, padx=10, pady=10)

nomelabel = Label(miframe, text='Nome: ')
nomelabel.grid(row=0, column=0, sticky='e', padx=10, pady=10)

apnomelabel = Label(miframe, text='Apelido: ')
apnomelabel.grid(row=2, column=0, sticky='e', padx=10, pady=10)

direclabel = Label(miframe, text='Endereço: ')
direclabel.grid(row=3, column=0, sticky='e', padx=10, pady=10)

pwdlabel = Label(miframe, text='Password: ')
pwdlabel.grid(row=1, column=0, sticky='e', padx=10, pady=10)


# -----------------------------------------------------------
# COMANDOS DIVERSOS
# -----------------------------------------------------------
def raise_to_power(base, pow):
    result = 1
    for index in range(pow):
        result = result * base
    return result


print(raise_to_power(2, 64))

print(raise_to_power(2, 128))

number_grid = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9],
    [0]
]

for row in number_grid:
    print(row)

for row in number_grid:
    for col in row:
        print(col)
import random, string


def generator():
    leter1 = random.choice(string.ascii_lowercase)
    leter2 = random.choice(string.ascii_lowercase)
    leter3 = random.choice(string.ascii_lowercase)
    leter4 = random.choice(string.ascii_lowercase)
    leter5 = random.choice(string.ascii_lowercase)
    name = leter1 + leter2 + leter3 + leter4 + leter5
    return (name)


print(generator())

for i in [234, 654, 378, 798]:
    # Se o resto dividindo por 3 for igual a zero:
    if i % 3 == 0:
        # Imprime...
        print(i, '/ 3 =', i / 3)

# Soma de 0 a 99
s = 0
for x in range(1, 10):
    s = s + x
    print(s)

# Soma de 0 a 99
s = 0
x = 1
while x < 100:
    s = s + x
    x = x + 1
print(s)

# Convertendo de real para inteiro
print('int(3.14) =', int(3.14))

# Convertendo de inteiro para real
print('float(5) =', float(5))

# Calculo entre inteiro e real resulta em real
print('5.0 / 2 + 3 = ', 5.0 / 2 + 3)

# Inteiros em outra base
print("int('20', 16) =", int('20', 16))  # base 16
print("int('1010', 2) =", int('1010', 2))  # base 2

s = 'Camel'
# Interpolação
print('tamanho de %s => %d' % (s, len(s)))

print('''
Símbolos usados na interpolação:\n ▪ %s: string.\n ▪ %d: inteiro.\n ▪ %o: octal.\n ▪ %x: hexacimal.\n ▪ %f: real.\n ▪ %e: real exponencial.\n ▪ %%: sinal de percentagem.\n
''')

a = 123.4562
print('valor decimal: %.2f' % (a))
print('')

prog = ['prog0', 'prog1', 'prog2', 'prog3', 'prog4']

for i, ii in enumerate(prog):
    print(i, 'indice--> ' + 'aponta elemento da tupla--> ', ii)

print('-' * 50)
prog_tupla = tuple(prog)

print(type(prog), type(prog_tupla))

prog_lista = list(prog_tupla)

print(type(prog_lista))
print('-' * 50)
# -------------------------------------------------------------
# Conjuntos de dados
s1 = set(range(3))
s2 = set(range(10, 7, -1))
s3 = set(range(2, 10, 2))
s4 = set(range(2, 10, 1))

# Exibe os dados
print('s1:', s1, '\ns2:', s2, '\ns3:', s3, '\ns4:', s4)
print('-' * 50)
# -------------------------------------------------------------

dic = {'ix1': 'val-pk1', 'ix2': 'val-pk2', 'ix3': 'val-pk3', 'ix4': 'val-pk4'}
print(dic)
print(dic.items())
print(dic.keys())
print(dic.values())
print('-' * 50)

dim = 6, 12
mat = {}
# Tuplas são imutáveis
# Cada tupla representa
# uma posição na matriz
mat[3, 7] = 3
mat[4, 6] = 5
mat[6, 3] = 7
mat[5, 4] = 6
mat[2, 9] = 4
mat[1, 0] = 9

matriz = '''0 0 0 0 0 0 0 0 0 0 0 0
            0 0 0 0 0 0 0 0 0 0 0 0
            0 0 0 0 0 0 0 0 0 0 0 0
            0 0 0 0 0 0 0 0 0 0 0 0
            0 0 0 0 0 0 0 0 0 0 0 0
            0 0 0 0 0 0 0 0 0 0 0 0'''

for lin, linha in enumerate(matriz.splitlines()):
    for col, coluna in enumerate(linha.split()):
        coluna = int(coluna)
        if coluna:
            mat[lin, col] = coluna
print(mat)
print(mat[3, 7])
print(mat[5, 4])
print(mat[1, 0])


# *args - argumentos sem nome (lista)
# **kargs - argumentos com nome (dicionário)
def func(*args, **kargs):
    print(args)
    print(kargs)


func('peso', 10, unidade='k')
func('peso', 10, 20, unidade='k', chave='pk')

print('-' * 50)
from collections import OrderedDict

dict(zip(string.ascii_lowercase, range(4)))
{'a': 0, 'b': 1, 'c': 2, 'd': 3}
dict(zip(string.ascii_lowercase, range(5)))
{'a': 0, 'b': 1, 'c': 2, 'd': 3, 'e': 4}
dict(zip(string.ascii_lowercase, range(6)))
{'a': 0, 'b': 1, 'c': 2, 'd': 3, 'f': 5, 'e': 4}

root.mainloop()




