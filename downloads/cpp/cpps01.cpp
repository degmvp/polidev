01 • std::reduce
Soma paralela de folha
Soma o salário bruto de 500 mil funcionários usando múltiplos núcleos do processador.

#include <iostream>
#include <vector>
#include <numeric>
#include <execution>

int main() {
    std::vector<double> salarios_brutos(500000, 3500.00);

    double total_folha = std::reduce(
        std::execution::par,
        salarios_brutos.begin(),
        salarios_brutos.end(),
        0.0
    );

    std::cout << "Total da folha: " << total_folha << "\n";
    return 0;
}