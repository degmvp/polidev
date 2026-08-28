# ==========================================================
# POLYDEV | WX-COLLECTOR
# WX-PY-224
# Tratamento de Outliers com IQR
# Categoria: wxpy12
# ==========================================================

import numpy as np

def handle_outliers_iqr(df, columns):
    for col in columns:
        q1 = df[col].quantile(0.25)
        q3 = df[col].quantile(0.75)
        iqr = q3 - q1
        lower = q1 - 1.5 * iqr
        upper = q3 + 1.5 * iqr
        df[col] = np.clip(df[col], lower, upper)
    return df
