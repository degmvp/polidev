# ==========================================================
# POLYDEV | WX-COLLECTOR
# WX-PY-229
# Pipeline Completo de Produção
# Categoria: wxpy12
# ==========================================================

import numpy as np

def create_features_fast(df):
    price = df["price"].to_numpy()
    qty = df["quantity"].to_numpy()
    df["total"] = price * qty
    df["log_price"] = np.log1p(price)
    return df

def smart_impute(df):
    numeric_cols = df.select_dtypes(include=["number"]).columns
    for col in numeric_cols:
        df[col] = df[col].fillna(df[col].median())
    return df

def handle_outliers_iqr(df, columns=None):
    if columns is None:
        columns = df.select_dtypes(include=["number"]).columns
    for col in columns:
        q1 = df[col].quantile(0.25)
        q3 = df[col].quantile(0.75)
        iqr = q3 - q1
        df[col] = np.clip(df[col], q1 - 1.5 * iqr, q3 + 1.5 * iqr)
    return df

def production_preprocessing_pipeline(df):
    df = create_features_fast(df)
    df = smart_impute(df)
    df = handle_outliers_iqr(df)
    return df
