10 - Data Quality Report
report = pd.DataFrame({

    'tipo': df.dtypes,

    'nulos_%': df.isnull().mean() * 100,

    'unicos': df.nunique()

})