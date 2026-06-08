03 • std::lower_bound
Busca rápida de faixa de IR
Encontra a alíquota correta usando busca binária.

#include <iostream>
#include <vector>
#include <algorithm>

struct FaixaIR {
    double limite;
    double aliquota;
};

int main() {
    std::vector<FaixaIR> tabela_ir = {
        {1903.98, 0.0},
        {2826.65, 0.075},
        {3751.05, 0.15},
        {4664.68, 0.225},
        {99999.99, 0.275}
    };

    double salario = 3500.00;

    auto it = std::lower_bound(tabela_ir.begin(), tabela_ir.end(), salario,
        [](const FaixaIR& faixa, double valor) {
            return faixa.limite < valor;
        }
    );

    double aliquota_encontrada = it->aliquota;
    std::cout << "Aliquota encontrada: " << aliquota_encontrada * 100 << "%\n";
    return 0;
}