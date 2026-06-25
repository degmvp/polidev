7 - Processamento em Chunks
for chunk in pd.read_csv(
    file_path,
    chunksize=50_000
):

    numeric = chunk.select_dtypes(
        include=['number']
    ).to_numpy()