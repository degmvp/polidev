import pandas as pd

vendas = pd.Series(
    [1200, 1500, 1800, 900, 2100],
    index=["Jan", "Fev", "Mar", "Abr", "Mai"]
)

print("Vendas originais:")
print(vendas)

print("\nMeses com vendas acima de 1500:")
print(vendas[vendas > 1500])