print('✅' * 50)
print('''
#-------------------------------------------------------
# ✅ advR005
# ✅ Python 3.66 alterado: 2018/07/29
# ✅ Objetivo: cmd avançado calculadora
# ✅ Comandos: from tkinter - class
# ✅ Funções : get(), eval(), grid(), Button()
#-------------------------------------------------------''')
print('✅' * 50)

from tkinter import *

class Calculadora:
    def __init__(self, master):
        self.frame = Frame(master)
        self.frame.grid()
        self.dados = Entry(master, width=64)
        self.dados.grid(row=1, column=0)
        bts = ['0','1','2','3','4','5','6','7','8','9','+','-','*','/','=','C']
        r = 1
        c = 0
        for bt in bts:
            comando = lambda x=bt: self.calcular(x)
            self.botao = Button(self.frame, bd=6, font=('arial', 10, 'bold'), bg='powder blue',
                                text=bt, width=8, command=comando)
            self.botao.grid(row=r, column=c)
            c += 1
            if c > 3:
                c = 0
                r += 1