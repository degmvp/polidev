print('✅' * 50)
print('''
#-------------------------------------------------------
# ✅ advR008
# ✅ Python 3.66 alterado: 2018/07/29
# ✅ Objetivo: cmd avançado imprime formato table
# ✅ Comandos: for, if
# ✅ Funções : append(), str(), join(), range()
#-------------------------------------------------------''')
print('✅' * 50)

class Table:
    def __init__(self, title, headers, rows):
        self.title = title
        self.headers = headers
        self.rows = rows
        self.nrows = len(self.rows)
        self.fieldlen = []

        ncols = len(headers)

        for i in range(ncols):
            max = 0
            for j in rows:
                if len(str(j[i])) > max:
                    max = len(str(j[i]))
            self.fieldlen.append(max)

        for i in range(len(headers)):
            if len(str(headers[i])) > self.fieldlen[i]:
                self.fieldlen[i] = len(str(headers[i]))

        self.width = sum(self.fieldlen) + (ncols - 1) * 3 + 4