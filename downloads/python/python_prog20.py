print('✅' * 50)
print('''
#---------------------------------------
# ✅ AppB05
# ✅ Python 3.6 alterado: 2017/08/13
# ✅ Objetivo: decorator-->number of times a function is called
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


'''
@memorize
def foo(a, b):
    return a * b

print('Efetua 3 operações com a função foo(a, b) 2x4 12x4 12x12') 
print('e armazena os resultados no decorador memorize dicionario')
print(foo(2,4))
print(foo(12,4))
print(foo(12,12))
print(foo)'''


class countcalls(object):
    "Decorator that keeps track of the number of times a function is called."

    __instances = {}

    def __init__(self, f):
        self.__f = f
        self.__numcalls = 0
        countcalls.__instances[f] = self

    def __call__(self, *args, **kwargs):
        self.__numcalls += 1
        return self.__f(*args, **kwargs)

    def count(self):
        "Return the number of times the function f was called."
        return countcalls.__instances[self.__f].__numcalls

    @staticmethod
    def counts():
        "Return a dict of {function: # of calls} for all registered functions."
        return dict([(f.__name__, countcalls.__instances[f].__numcalls) for f in countcalls.__instances])


@countcalls
def f():
    print('f called')


f()
f()


@memorize
@countcalls
def foo(a, b):
    return a * b


print('Efetua 3 operações com a função foo(a, b) 2x4 12x4 12x12')
print('e armazena os resultados no decorador memorize dicionario')
print(foo(2, 4))
print(foo(12, 4))
print(foo(12, 12))
print(foo)

print(countcalls.counts())
