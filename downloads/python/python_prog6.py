print('✅' * 50)
print('''
--------------------------------------------------
# ✅ advR003
# ✅ Python 3.6 alterado: 2018/07/29
# ✅ Objetivo:Rotina ler arq.txt
# ✅ Comandos:f = open(), with open) as f:,f.readlines()
# ✅ Funções:f.read(size_to_read), open('chips.jpg','rb') as rf:
#-------------------------------------------------''')
print('✅' * 50)

f = open('arq.txt','r')

print(f.name)
print(f)
print(f.mode)
lineH = f.readline()
print(lineH)

f.close()

print('ler o arquivo a função read() todo o arquivo\n')
with open('arq.txt','r') as f:
    f_contents = f.read()
    print(f_contents)

print('ler o arquivo a função readlines() todo o arquivo\n')
with open('arq.txt', 'r') as f:
    f_contents = f.readlines()
    print(f_contents)

print('ler o arquivo a função readline() apenas uma linha\n')
with open('arq.txt','r') as f:
    f_contents = f.readline()
    print(f_contents, end='')

print('ler o arquivo usando for para acesso aos registros\n')
with open('arq.txt','r') as f:
    for line in f:
        print(line, end='')

print(' ')
print('ler o arquivo usando size explicito 120 bytes\n')
with open('arq.txt', 'r') as f:
    size_to_read = 125

    f_contents = f.read(size_to_read)
    print(f_contents, end='')

    print('imprime o tamanho da variavel size_to_read : ', f.tell())

    print('ler arq.txt e grava saida em arq_copy.txt\n')
    with open('arq.txt', 'r') as rf:
        with open('arq_copy.txt', 'w') as wf:
            for line in rf:
                wf.write(line)


    def func_arg(*args, **kwargs):
        print(args)
        print(kwargs)


    pro = ['Python', 'Programação']
    dic = {'nome': 'Degmar', 'desenvolvedor': 'avancado', 'ano ': '2017', 'mes ': 'maio'}

    func_arg(*pro, **dic)