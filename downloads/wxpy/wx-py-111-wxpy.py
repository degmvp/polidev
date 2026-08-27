import pandas as pd

datas = pd.Series([
    "2026-01-10",
    "2026-02-15",
    "2026-03-20",
    "2026-04-25"
])

datas_convertidas = pd.to_datetime(datas)

print("Datas convertidas:")
print(datas_convertidas)

print("\nAno:")
print(datas_convertidas.dt.year)

print("\nMês:")
print(datas_convertidas.dt.month)

print("\nDia:")
print(datas_convertidas.dt.day)