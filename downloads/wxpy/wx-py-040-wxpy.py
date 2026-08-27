2 - Feature Engineering Vetorizado
def create_features_fast(df):

    price = df['price'].to_numpy()

    qty = df['quantity'].to_numpy()

    df['total'] = price * qty

    df['log_price'] = np.log1p(price)

    return df