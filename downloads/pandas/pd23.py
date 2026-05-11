import pandas as pd

vendas = pd.Series(
    [1200, 1500, 1800, 900, 2100],
    index=["Jan", "Fev", "Mar", "Abr", "Mai"]
)

print("Series original:")
print(vendas)

print("\nFatiamento por posição:")
print(vendas[1:4])

print("\nFatiamento por índice:")
print(vendas["Fev":"Abr"])