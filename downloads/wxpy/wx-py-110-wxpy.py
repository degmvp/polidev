import pandas as pd

nomes = pd.Series([
    "python",
    "pandas",
    "sql",
    "postgresql",
    "polydev"
])

print("Series original:")
print(nomes)

print("\nMaiúsculas:")
print(nomes.str.upper())

print("\nPrimeira letra maiúscula:")
print(nomes.str.capitalize())

print("\nContém a letra 'p':")
print(nomes[nomes.str.contains("p")])