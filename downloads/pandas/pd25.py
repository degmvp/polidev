import pandas as pd

vendas = pd.Series(
    [1200, 1500, 1800, 900, 2100],
    index=["Jan", "Fev", "Mar", "Abr", "Mai"]
)

print("Vendas originais:")
print(vendas)

print("\nVendas com aumento de 10%:")
print(vendas * 1.10)

print("\nTotal vendido:")
print(vendas.sum())

print("\nMédia de vendas:")
print(vendas.mean())