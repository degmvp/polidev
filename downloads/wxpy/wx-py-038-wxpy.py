10 - Sparse Correlation
def sparse_correlation(a, b, threshold=0.01):

    mask = (
        np.abs(a) > threshold
    ) | (
        np.abs(b) > threshold
    )

    if mask.sum() == 0:
        return 0.0

    return np.corrcoef(
        a[mask],
        b[mask]
    )[0,1]