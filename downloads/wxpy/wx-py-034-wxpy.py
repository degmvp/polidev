6 - Pairwise Distance com Broadcasting
def pairwise_distance(X, Y=None):

    if Y is None:
        Y = X

    X2 = np.sum(X**2, axis=1, keepdims=True)

    Y2 = np.sum(Y**2, axis=1)

    XY = X @ Y.T

    return np.sqrt(X2 + Y2 - 2 * XY)