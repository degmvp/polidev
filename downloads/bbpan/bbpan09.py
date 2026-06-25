9 - Pipeline Completo de Produção
def production_preprocessing_pipeline(df):

    df = create_features_fast(df)

    df = smart_impute(df)

    df = handle_outliers_iqr(df)

    return df