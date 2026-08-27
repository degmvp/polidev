6 - Rolling Statistics
df.groupby(group_col)[value_col]

.transform(

    lambda x:

    pd.Series(x.to_numpy())

    .rolling(window)

    .mean()
)