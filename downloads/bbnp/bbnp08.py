8 - Fast Smooth
Muito utilizado em:

DSP
Séries temporais
Suavização estatística
Pré-processamento ML

def fast_smooth(data, window_size=5):

    kernel = np.ones(window_size) / window_size

    return np.convolve(
        data,
        kernel,
        mode='valid'
    )