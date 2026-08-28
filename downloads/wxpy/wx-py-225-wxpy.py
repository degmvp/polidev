# ==========================================================
# POLYDEV | WX-COLLECTOR
# WX-PY-225
# Encoding Categórico Eficiente
# Categoria: wxpy12
# ==========================================================

def fast_categorical_encoding(df, cat_columns):
    for col in cat_columns:
        freq = df[col].value_counts()
        df[f"{col}_freq"] = df[col].map(freq)
    return df
