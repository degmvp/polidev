2 - Lookup Ultra-Rápido
Uso de searchsorted para buscas extremamente eficientes.

def fast_lookup(codes, values, lookup_table):

    sorted_idx = np.argsort(codes)

    sorted_codes = codes[sorted_idx]

    positions = np.searchsorted(sorted_codes, values)

    return lookup_table[sorted_idx[positions]]