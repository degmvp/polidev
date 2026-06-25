1 - Batch Processing para Grandes Volumes
    Processamento em lotes reduz drasticamente o consumo de memória.

def batch_process_large_array(data, batch_size=10000):

    results = []

    for i in range(0, len(data), batch_size):

        batch = data[i:i+batch_size]

        batch_norm = (
            batch - batch.mean(axis=0)
        ) / (
            batch.std(axis=0) + 1e-8
        )

        results.append(batch_norm)

    return np.vstack(results)