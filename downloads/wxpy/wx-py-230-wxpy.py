# ==========================================================
# POLYDEV | WX-COLLECTOR
# WX-PY-230
# Data Quality Report
# Categoria: wxpy12
# ==========================================================

import pandas as pd

def data_quality_report(df):
    return pd.DataFrame({
        "tipo": df.dtypes,
        "nulos_%": df.isnull().mean() * 100,
        "unicos": df.nunique()
    })
