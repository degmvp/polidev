print('✅' * 50)
print('''
-------------------------------------------------- 
# ✅ advR003 
# ✅ Python 3.6 alterado: 2018/07/29 
# ✅ Objetivo: Rotina ler arq.txt 
# ✅ Comandos: open(), with open, readlines() 
# ✅ Funções: f.read(), f.readline(), f.readlines() 
--------------------------------------------------''')
print('✅' * 50)

f = open('arq.txt', 'r')

print(f.name)
print(f)
print(f.mode)
lineH = f.readline()
print(lineH)

f.close()