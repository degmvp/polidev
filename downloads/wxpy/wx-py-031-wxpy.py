3 - Filtragem Vetorizada

def filter_outliers(data, n_std=3.0):

    mean = np.mean(data)

    std = np.std(data)

    mask = np.abs(data - mean) < n_std * std

    return data[mask], mask