print('✅' * 50)
print('''
#---------------------------------------
# ✅ AppB03
# ✅ Python 3.6 alterado: 2018/08/14
# ✅ Objetivo: usando decorator--> @memorize
#---------------------------------------''')
print('✅' * 50)


class memorize(dict):
    def __init__(self, func):
        self.func = func

    def __call__(self, *args):
        return self[args]

    def __missing__(self, key):
        result = self[key] = self.func(*key)
        return result


@memorize
def foo(a, b):
    return a * b


print('Efetua 3 operações com a função foo(a, b) 2x4 12x4 12x12')
print('e armazena os resultados no decorador memorize dicionario')
print(foo(2, 4))
print(foo(12, 4))
print(foo(12, 12))
print(foo)
