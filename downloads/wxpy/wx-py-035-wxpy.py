7 - Interpolação Linear Vetorizada
def fast_linear_interpolate(x, y, x_new):

    return np.interp(x_new, x, y)