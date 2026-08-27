print('✅' * 50)
print('''
#-------------------------------------------------------
# ✅ advR007
# ✅ Python 3.6 alterado: 2018/07/29
# ✅ Objetivo: cmd avançado imprime formato table
# ✅ Comandos: LEFT, RIGHT, COLUMNS
# ✅ Funções : get_row, get_rows()
#-------------------------------------------------------''')
print('✅' * 50)

class ALIGN:
    LEFT, RIGHT = '-', ''

class Column(list):
    def __init__(self, name, data, align=ALIGN.RIGHT):
        list.__init__(self, data)
        self.name = name
        width = max(len(x) for x in data + [name])
        self.format = ' %%%s%ds ' % (align, width)