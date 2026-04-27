print('✅' * 50)
print('''
#---------------------------------------
# ✅ AppB02
# ✅ Python 3.6 alterado: 2017/08/13
# ✅ Objetivo: usando decorator--> @funcao
#---------------------------------------''')
print('✅' * 50)
def declara1(func1):
    def  function_decoradora1(name):
        print('função -->declara1!-->chamada como  function_decoradora1')
        func1(name)
    return function_decoradora1

def declara2(func2):
    def function_decoradora2(n):
        print('função -->declara2 chamada como  function_decoradora2')
        func2(n)
    return function_decoradora2

@declara1
@declara2

def imprimir_nome(name):
    print(name)

imprimir_nome('Apos usar function_decoradora1-2 imprime o  nome:Degmar')
#----------------------------------------------------------
def p_decorador(func):
    def  function_decoradora(n):
        print('Usando Decorator',func(n))
    return function_decoradora

def p_decorador1(func):
    def function_decoradora(n):
        print('Testando Decorator',func(n))
    return function_decoradora

@p_decorador
def fib_dyn(n):
    if n == 1 or n == 2:
        return 1
    f1 = 1
    f2 = 1
    for i in range(3, n + 1):
        f = f1 + f2
        f2 = f1
        f1 = f
    return f1
print(fib_dyn(17))
print(fib_dyn(27))

@p_decorador1
def fib_dyn(n):
    if n == 1 or n == 2:
        return 1
    f1 = 1
    f2 = 1
    for i in range(3, n + 1):
        f = f1 + f2
        f2 = f1
        f1 = f
    return f1
print(fib_dyn(11))
print(fib_dyn(22))
