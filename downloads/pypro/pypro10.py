# POLYDEV | Python Professional Functions
# 10 - Função para manipulação eficiente de grandes arquivos com geradores
#
# Finalidade:
# Processar grandes volumes de dados sem consumir muita memória.

def ler_arquivo_grande_linha_a_linha(caminho_arquivo):
    with open(caminho_arquivo, 'r') as arquivo:
        for linha in arquivo:
            yield linha.strip()

for linha in ler_arquivo_grande_linha_a_linha('dados_grandes.txt'):
    # Processar linha
    print(linha)
