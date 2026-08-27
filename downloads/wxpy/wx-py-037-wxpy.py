9 - Top-K Ultra-Eficiente
def top_k_fast(arr, k=10):

    idx = np.argpartition(arr, -k)[-k:]

    idx = idx[np.argsort(arr[idx])[::-1]]

    return arr[idx], idx