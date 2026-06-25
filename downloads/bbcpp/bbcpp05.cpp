05 • constexpr
Cálculo em tempo de compilação
Calcula a taxa de juros diária antes mesmo do programa rodar.

#include <iostream>
#include <cmath>

constexpr double calcularTaxaDiaria(double taxaAnual) {
    return std::pow(1.0 + taxaAnual, 1.0 / 252.0) - 1.0;
}

int main() {
    constexpr double TAXA_ANUAL = 0.12;
    constexpr double TAXA_DIARIA = calcularTaxaDiaria(TAXA_ANUAL);

    double saldo = 10000.00;
    saldo += saldo * TAXA_DIARIA;

    std::cout << "Taxa diaria compilada: " << TAXA_DIARIA << "\n";
    return 0;
}