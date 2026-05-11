import pandas as pd

vendas = pd.Series(
    [1200, 1500, 1800, 900, 2100],
    index=["Jan", "Fimport pandas as pd

vendas = pd.Series(
    [1200, 1500, 1800, 900, 2100],
    index=["Jan", "Fev", "Mar", "Abr", "Mai"]
)

def classificar(valor):
    if valor >= 1800:
        return "Alta"
    elif valor >= 1200:
        return "Média"
    else:
        return "Baixa"

classificacao = vendas.apply(classificar)

print("Vendas:")
print(vendas)

print("\nClassificação:")
print(classificacao)ev", "Mar", "Abr", "Mai"]
)

print("Vendas originais:")
print(vendas)

print("\nVendas com aumento de 10%:")
print(vendas * 1.10)

print("\nTotal vendido:")
print(vendas.sum())

print("\nMédia de vendas:")
print(vendas.mean())