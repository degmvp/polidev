'''
import string
print(help(string))
print(string.Formatter)

'''
import random,string

print('-' * 50)
print(string.ascii_letters)
print(string.ascii_lowercase)
print(string.ascii_uppercase)
print(string.hexdigits)
print(string.printable)
print(string.__all__)
print('-' * 50)

def generator():
    letter1 = random.choice(string.ascii_uppercase)
    letter2 = random.choice(string.ascii_uppercase)
    letter3 = random.choice(string.ascii_uppercase)
    letter4 = random.choice(string.ascii_lowercase)
    letter5 = random.choice(string.ascii_lowercase)
    number1 = random.choice(string.hexdigits)
    number2 = random.choice(string.hexdigits)
    number3 = random.choice(string.hexdigits)
    name = letter1+letter2+number1+number2+number3+letter3+letter4+letter5
    return(name)

print(generator())

def V_and_F(var_v,var_f):
    return var_v and not var_f


print(V_and_F(True,False))

print(V_and_F(True,True))

a = True
b = False
print(V_and_F(a,b))
print(V_and_F(b,a))
print(V_and_F(a,a))

print('-' * 50)
def c_maior_d_plus_e(c,d,e):
    return c > d + e

print(c_maior_d_plus_e(4,1,2))

'''
Fibonacci : 1,1,2,3,5,8,13,21, 34...
F(1) = F(2) = 1
F(n) = F(n-1) + F(n-2)

F(3) = F(2) + F(1) = 1 + 1 = 2
F(4) = F(3) + F(2) = 2 + 1 = 3
F(5) = F(4) + F(3) = 3 + 2 = 5
F(6) = F(5) + F(4) = 5 + 3 = 8
'''

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


print(fib_dyn(7))

