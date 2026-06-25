09 • std::transform
Geração de resultado em lote
Gera salários líquidos a partir de salários brutos.

#include <iostream>
#include <vector>
#include <algorithm>

int main() {
    std::vector<double> brutos = {3000.00, 5000.00, 7000.00};
    std::vector<double> liquidos(brutos.size());

    std::transform(brutos.begin(), brutos.end(), liquidos.begin(),
        [](double bruto) {
            return bruto * 0.80;
        }
    );

    std::cout << "Liquido do primeiro: " << liquidos[0] << "\n";
    return 0;
}