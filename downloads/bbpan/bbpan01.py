1 - Leitura Otimizada de Grandes Arquivos
Processamento de CSVs gigantes usando chunks e otimização automática de memória.

def read_large_csv_optimized(file_path,
                             chunksize=100_000):

    chunks = []

    for chunk in pd.read_csv(
        file_path,
        chunksize=chunksize
    ):

        chunks.append(chunk)

    return pd.concat(
        chunks,
        ignore_index=True
    )