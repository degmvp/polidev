# POLYDEV | Python Professional Functions
# 02 - Funções geradoras com yield
#
# Finalidade:
# Gerar grandes volumes de dados ou streams de forma eficiente em memória, útil para processamento de logs, pipelines e dados em tempo real.

def read_large_file(file_path):
    with open(file_path) as file:
        for line in file:
            yield line.strip()

for line in read_large_file("grande_arquivo.log"):
    process(line)
