# ==========================================================
# POLYDEV | WX-COLLECTOR
# WX-PY-228
# Feature Selection com Correlação
# Categoria: wxpy12
# ==========================================================

def select_features_by_correlation(numeric_df, target):
    return (
        numeric_df.corr()[target]
        .abs()
        .sort_values(ascending=False)
    )
