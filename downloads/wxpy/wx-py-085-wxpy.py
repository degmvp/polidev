import pandas as pd

dados = {
    "produto": ["Mouse", "Teclado", "Monitor"],
    "preco": [50, 120, 900]
}

df = pd.DataFrame(dados)

df.to_csv("produtos.csv", index=False)

print("CSV salvo com sucesso.")
