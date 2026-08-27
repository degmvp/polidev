import pandas as pd

# Mini projeto com Series
produtos = pd.Series(
    [3500, 4200, 2800, 5100, 3900],
    index=["Notebook", "Servidor", "Tablet", "Desktop", "Monitor"]
)

print("Faturamento por produto:")
print(produtos)

print("\nProduto com maior faturamento:")
print(produtos.idxmax(), "-", produtos.max())

print("\nProduto com menor faturamento:")
print(produtos.idxmin(), "-", produtos.min())

print("\nProdutos acima da média:")
media = produtos.mean()
print(produtos[produtos > media])

print("\nFaturamento com reajuste de 8%:")
print(produtos * 1.08)