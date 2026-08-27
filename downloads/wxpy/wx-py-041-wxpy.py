3 - Smart Imputation
def smart_impute(df):

    numeric_cols = df.select_dtypes(
        include=['number']
    ).columns

    for col in numeric_cols:

        df[col] = df[col].fillna(
            df[col].median()
        )

    return df