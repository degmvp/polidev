print('✅' * 50)
print('''
--------------------------------------------------
# ✅ advR001
# ✅ Python 3.66 alterado: 2018/07/29
# ✅ Objetivo:Rotina ler nota .txt
# ✅ Comandos:import sys,if,while,elif,else,break
# ✅ Funções :readline(),close()print(),int(),def()
#-------------------------------------------------''')
print('✅' * 50)
import sys
listaH = []
def cargarH():
    archivoH = open('p:nota.txt','r')
    lineaH = archivoH.readline()
    if lineaH:
        while lineaH:
            if lineaH[-1] == '\n':
                lineaH = lineaH[:-1]
                listaH.append(lineaH)
                lineaH = archivoH.readline()
        archivoH.close()
        print(listaH)
        for linha in (listaH):
            linha = linha.split(';')
            aluno = linha[0]
            trabalho1 = int(linha[1])
            trabalho2 = int(linha[2])
            trabalho3 = int(linha[3])
            media = (trabalho1 + trabalho2 + trabalho3) / 3
            print(aluno + ': ', end='')
            if media >= 5:
                print('Aprovado')
            elif media >= 3:
                print('Recuperação')
            elif media < 3:

                print('Reprovado')
            else:
                break
cargarH()

print('✅' * 50)
print('''
--------------------------------------------------
# ✅ advR001
# ✅ Python 3.66 alterado: 2018/07/29
# ✅ Objetivo:copia chips.jpg para chips_copy.jpg
# ✅ Comandos:with open 'rb' 
# ✅ grava imagem em binario
#-------------------------------------------------''')
print('✅' * 50)
with open('chips.jpg','rb') as rf:
    with open('chips_copy.jpg','wb') as wf:
        chunk_size = 4096
        rf_chunk = rf.read(chunk_size)
        while  len(rf_chunk) > 0:
            wf.write(rf_chunk)
            rf_chunk = rf.read(chunk_size)
