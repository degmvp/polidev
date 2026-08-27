import pandas as pd

# Series com índice personalizado
vendas = pd.Series(
    [1200, 1500, 1800, 900, 2100],
    index=["Jan", "Fev", "Mar", "Abr", "Mai"]
)

print("Vendas por mês:")
print(vendas)

print("\nVenda de Março:")
print(vendas["Mar"])