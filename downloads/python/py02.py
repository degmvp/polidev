class Produto:
    def __init__(self, nome, preco, quantidade):
        self.nome = nome
        self.preco = preco
        self.quantidade = quantidade

    def mostrar_produto(self):
        print(f"Produto: {self.nome}")
        print(f"Preço: R$ {self.preco}")
        print(f"Quantidade: {self.quantidade} unidades")

# Criando instâncias diferentes
p1 = Produto("Caneta", 2.50, 10)
p2 = Produto("Caderno", 15.00, 5)
p3 = Produto("Borracha", 1.00, 20)

# Exibindo os dados
p1.mostrar_produto()
print("-" * 40)
p2.mostrar_produto()
print("-" * 40)
p3.mostrar_produto()