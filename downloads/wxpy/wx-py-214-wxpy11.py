print('✅' * 50)
print('''
#---------------------------------------
# ✅ trick02
# ✅ Python 3.6 alterado: 2018/08/30
# ✅ Objetivo: operacoes com dicionario
#---------------------------------------''')
print('✅' * 50)

print(''' 
#------------------------------------------------------ 
# ✅ --sort a Python dict by value
# xs = {'a': 4, 'b': 3, 'c': 2, 'd': 1}
#-------------------------------------------------------''')
xs = {'a': 4, 'b': 3, 'c': 2, 'd': 1}

print('sorted(xs.items(), key=lambda x: x[1]))', )
print(sorted(xs.items(), key=lambda x: x[1]))
vtype = sorted(xs.items(), key=lambda x: x[1])
print(type(vtype))
print(xs.items())

print(''' 
#------------------------------------------------------ 
# ✅ --sort a Python dict by value using operator
#-------------------------------------------------------''')
import operator

print(sorted(xs.items(), key=operator.itemgetter(1)))

print(''' 
#------------------------------------------------------ 
# ✅ # Different ways to test multiple
#      flags at once in Python
#-------------------------------------------------------''')
x, y, z = 0, 0, 1

if x == 1 or y == 1 or z == 1:
    print('se x,y,z = 1')
else:
    print('False')

if 1 in (x, y, z):
    print('se existe 1 em: x,y,z')
else:
    print('False')

if x or y or z:
    print('se or - x,y,z true')
else:
    print('False')

if any((x, y, z)):
    print('qualquer x,y,z = true')
else:
    print('False')

print(''' 
#---------------------------------------- 
# ✅ Print - A função enumerate()
#    Retorna uma tupla (indice,elemento)
#    the ability to choose the starting
#    index for the enumeration. 
#----------------------------------------''')
names = ['Bob', 'Alice', 'Guido']
for index, value in enumerate(names):
    print(f'{index}: {value}')

for index, value in enumerate(names, 1):
    print(f'{index}: {value}')

print(enumerate(names))
print(list(enumerate(names)))

print(''' 
#------------------------------------------------------ 
# ✅Inner Functions -define func inside other functions
#-------------------------------------------------------''')


def parent():
    print("Printing from the parent() function")

    def first_child():
        print("Printing from the first_child() function")

    def second_child():
        print("Printing from the second_child() function")

    second_child()
    first_child()


parent()

print(''' 
#------------------------------------------------------ 
# ✅Returning Functions From Functions
#-------------------------------------------------------''')


def parent(num):
    def first_child():
        return "retorna funcao 1"

    def second_child():
        return "retorna funcao 2"

    if num == 1:
        return first_child
    else:
        return second_child


func1 = parent(1)

func2 = parent(2)

print(func1())
print(func2())

print(''' 
#------------------------------------------------------ 
# ✅ use decorators in a simpler way with the @ symbol, 
#-------------------------------------------------------''')


def my_decorator(func):
    def wrapper():
        print("imprime antes da function chamada.")
        func()
        print("imprime depois da function chamada.")

    return wrapper


@my_decorator
def func_decorate():
    print("execute argumento @my_decorator!")


func_decorate()

print(''' 
#------------------------------------------------------ 
# ✅--Decorating Functions With Arguments
#-------------------------------------------------------''')


def do_twice(func):
    def wrapper_do_twice(*args, **kwargs):
        func(*args, **kwargs)

    return wrapper_do_twice


@do_twice
def say_whee():
    print("Degmar Gomes Barbosa!")


def say_don():
    print("DonDeg!")


say_don()
say_whee()

print(''' 
#------------------------------------------------------ 
# ✅Timing Functions
#-------------------------------------------------------''')
import functools
import time


def timer(func):
    """Print the runtime of the decorated function"""

    @functools.wraps(func)
    def wrapper_timer(*args, **kwargs):
        start_time = time.perf_counter()  # 1
        value = func(*args, **kwargs)
        end_time = time.perf_counter()  # 2
        run_time = end_time - start_time  # 3
        print(f"Finished {func.__name__!r} in {run_time:.4f} secs")
        return value

    return wrapper_timer


@timer
def waste_some_time(num_times):
    for _ in range(num_times):
        sum([i ** 2 for i in range(10000)])


waste_some_time(100)

print(''' 
#------------------------------------------------------ 
# ✅ items() Como classificar um dicionario pelo valor 
#-------------------------------------------------------''')
print(''' 
#------------------------------------------------------ 
# ✅ Um dicionário de ações usando lambda 
#-------------------------------------------------------''')

print('''
#actions = { 
    'sum': lambda x, y: x + y, 
    'sub': lambda x, y: x - y, 
    'mul': lambda x, y: x * y, 
} 

func = actions['sum'] 
print(func(10, 20)) 

def func_lambda(operator, x, y):
    return {
        'add': lambda: x + y,
        'sub': lambda: x - y,
        'mul': lambda: x * y,
        'div': lambda: x / y,
    }.get(operator, lambda: None)()

print(func_lambda('add', 12, 8))
print(func_lambda('sub', 12, 8))
print(func_lambda('mul', 12, 8))
print(func_lambda('div', 12, 4))
#-------------------------------------------------------''')
print(''' 
#------------------------------------------------------ 
# ✅ Working With File I/O in Python
#------------------------------------------------------
# -------------------------------
Opening a File in Python
------------------------
file_object = open(filename, mode)

'w' – Write Mode: 
'r' – Read Mode: 
'a' – Append Mode: 
'r+' – Read/Write Mode:
'a+' – Append and Read Mode:
--------------------------------
Binary Files in Python
--------------------------------
--------------------------------
'wb' – Write Mode: 
'rb' – Read Mode: 
'ab' – Append Mode: 
'r+b' – Read/Write Mode:
'a+b' – Append and Read Mode:
-------------------------------
arq = open("workData.txt", "r+")
-------------------------------
arq.close()
--------------------------------------------
with open("workData.txt", "r+") as workData:
    # File object is now open.
    # Do stuff with the file:
    workData.read()

# File object is now closed.
----------------------------------------------------
with open("workData.txt", "r+") as work_data:
    print("This is the file name: ", work_data.name)
    line = work_data.read()
    print(line)
----------------------------------------------------
line = workData.read(6) -Le apenas 6 letras do arquivo!
#-------------------------------------------------------''')



