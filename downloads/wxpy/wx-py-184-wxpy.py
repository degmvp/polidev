class ContaBancaria:
    def __init__(self, titular, saldo=0):
        self.titular = titular
        self._saldo = saldo  # atributo protegido

    @property
    def saldo(self):
        """Getter para o saldo"""
        return self._saldo

    @saldo.setter
    def saldo(self, valor):
        """Setter que impede saldo negativo"""
        if valor < 0:
            print("❌ Saldo não pode ser negativo.")
        else:
            self._saldo = valor

    def depositar(self, valor):
        if valor > 0:
            self._saldo += valor
        else:
            print("❌ Valor inválido para depósito.")

    def sacar(self, valor):
        if 0 < valor <= self._saldo:
            self._saldo -= valor
        else:
            print("❌ Saldo insuficiente ou valor inválido.")