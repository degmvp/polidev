def pow(x):
    return x ** 2

mapa = map(pow, range(10))
print(*mapa)

ran = tuple(map(pow, range(10)))
print(ran)