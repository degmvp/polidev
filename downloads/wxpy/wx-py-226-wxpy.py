# ==========================================================
# POLYDEV | WX-COLLECTOR
# WX-PY-226
# Rolling Statistics
# Categoria: wxpy12
# ==========================================================

def rolling_statistics(df, group_col, value_col, window=3):
    df[f"{value_col}_rolling_mean"] = (
        df.groupby(group_col)[value_col]
        .transform(lambda x: x.rolling(window).mean())
    )
    return df
