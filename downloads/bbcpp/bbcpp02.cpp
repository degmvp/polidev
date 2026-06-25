02 • std::for_each
Cálculo de juros em paralelo
Aplica juros diários a uma lista de saldos simultaneamente.

#include <iostream>
#include <vector>
#include <algorithm>
#include <execution>

int main() {
    std::vector<double> saldos_contas = {1500.00, 3200.50, 800.00, 45000.00};
    double taxa_juros_diaria = 1.0001;

    std::for_each(std::execution::par, saldos_contas.begin(), saldos_contas.end(),
        [&taxa_juros_diaria](double& saldo) {
            saldo *= taxa_juros_diaria;
        }
    );

    std::cout << "Saldo conta 1 apos juros: " << saldos_contas[0] << "\n";
    return 0;
}