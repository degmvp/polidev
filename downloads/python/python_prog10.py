print('✅' * 50)
print('''
--------------------------------------------------
# ✅ binN04
# ✅ Python 3.6 alterado: 2018/07/29
# ✅ Objetivo:operação Bitwise
# ✅ Comandos:operadores & | ^ and, or, xor
# ✅ Funções:bin(),int(),hex(),
#-------------------------------------------------''')
print('✅' * 50)
print('Conversão decimal/binario --> binario/decimal <--')
print('9 = bin(9)-->', bin(9))
print('0b1001 = int(0b1001,2)-->', int('0b1001', 2))
print('-' * 47)

print('Conversão decimal/hexadecimal --> hexadecimal/decimal <--')
print('Decimal --> 147  = hex(147)    -->', hex(147))
print('Hexa    --> 0x93 = int(0x93,16)-->', int('0x93', 16))
print('-' * 47)

print('Conversão shift left (0b0010100 >> 2)  -->>', 0b0010100 >> 2)
print('Conversão shift right(0b0010100 << 2)  <<--', 0b0010100 << 2)
print('-' * 47)

print('Operações Bitwise AND = & --> 1 = True 0 = False')
t_and = ['1 and 1 = 1', '1 and 0 = 0', '0 and 1 = 0', '0 and 0 = 0']
for k in t_and:
    print(k)
print('-' * 47)

a = 42
b = 15
print('Bitwise de (a & b)-->', a & b)
print('a: 00101010  42')
print('b: 00001111  15')
print('===============')
print('R->00001010  10')
print('a & b -->', a & b, 42 & 15)
print('0b00101010 & 0b00001111', 0b00101010 & 0b00001111)
print('-' * 47)

print('Operações Bitwise OR = | --> 1 = True 0 = False')
t_or = ['1 or 1 = 1', '1 or 0 = 1', '0 or 1 = 1', '0 or 0 = 0']
for k in t_or:
    print(k)
print('-' * 47)

a = 42
b = 15
print('Bitwise de (a or b)-->', a | b)
print('a: 00101010  42')
print('b: 00001111  15')
print('===============')
print('R->00101111  47')
print('a | b -->', a | b, 42 | 15)
print('ob00101010 | ob00001111', 0b00101010 | 0b00001111)
print('-' * 47)

print('Operações Bitwise XOR = | --> 1 = True 0 = False')
t_xor = ['1 xor 1 = 0', '1 xor 0 = 1', '0 xor 1 = 1', '0 xor 0 = 0']
for k in t_xor:
    print(k)
print('-' * 47)

a = 42
b = 15
print('Bitwise de (a xor b)-->', a ^ b)
print('a: 00101010  42')
print('b: 00001111  15')
print('===============')
print('R->00100101  37')
print('a ^ b -->', a ^ b, 42 ^ 15)
print('0b00101010 ^ 0b00001111', 0b00101010 ^ 0b00001111)
print('-' * 47)


def print_dec_and_bits(value):
    print('Dec: {:d} | {:3b}'.format(value, value))


print_dec_and_bits(a)
print_dec_and_bits(b)

xab = a & b
print_dec_and_bits(xab)

xob = a | b
print_dec_and_bits(xob)

xxr = a ^ b
print_dec_and_bits(xxr)
print('-' * 47)

print('Operações Bitwise AND = & --> ')
print('Operações Bitwise OR =  | --> ')
print('Operações Bitwise XOR = & --> ')
print('-' * 47)

print('User rigths --> mapeamento binario')
print('-' * 47)
print('view   = 1 bits 001')
print('edit   = 2 bits 011')
print('create = 4 bits 100')

print('class User: --> mapeamento binario')


class User:
    def __init__(self, rights):
        self.rights = rights

    def can_view(self):
        return view & self.rights

    def can_edit(self):
        return edit & self.rights

    def can_create(self):
        return create & self.rights


print('Valores binarios: 1-view, 2-edit, 4-create(mapeamento)!')
view = int(input('Digite mapeamento para view:'))
edit = int(input('Digite mapeamento para edit:'))
create = int(input('Digite mapeamento para create:'))

usr = User(view)
adm = User(view | edit)
dba = User(view | edit | create)

print_dec_and_bits(view)
print_dec_and_bits(edit)
print_dec_and_bits(create)
print('-' * 47)


def seekusr(pk):
    if usr.can_view():
        print('sim,usr --> pode ver')
    else:
        print('ver --> permissão inexistente!')
    if usr.can_edit():
        print('sim,usr --> pode editar')
    else:
        print('editar --> permissão inexistente!')
    if usr.can_create():
        print('sim,usr --> pode criar')
    else:
        print('criar --> permissão inexistente!')


def seekadm(pk):
    if adm.can_view():
        print('sim,adm --> pode ver')
    else:
        print('ver --> permissão inexistente!')
    if adm.can_edit():
        print('sim,adm --> pode editar')
    else:
        print('editar --> permissão inexistente!')
    if adm.can_create():
        print('sim,adm --> pode criar')
    else:
        print('criar --> permissão inexistente!')


usr = User(view)
seekusr(usr)
print('-' * 44)
adm = usr
seekadm(adm)
print('><' * 22)
# ----------------------------
usr = User(edit)
seekusr(usr)
print('-' * 44)
adm = usr
seekadm(adm)
print('><' * 22)
# ----------------------------
usr = User(view | edit)
seekusr(usr)
print('-' * 44)
adm = usr
seekadm(adm)
print('><' * 22)
# ----------------------------
usr = User(view | edit | create)
seekusr(usr)
print('-' * 44)
adm = usr
seekadm(adm)
print('><' * 22)

