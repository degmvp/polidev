07 • std::sort com lambda
Otimização de cache
Ordena a folha por departamento antes de processar.

#include <iostream>
#include <vector>
#include <algorithm>
#include <string>

struct Funcionario {
    std::string departamento;
    std::string nome;
    double salario;
};

int main() {
    std::vector<Funcionario> empresa = {
        {"TI", "Joao", 5000.0},
        {"RH", "Maria", 4000.0},
        {"TI", "Ana", 6000.0}
    };

    std::sort(empresa.begin(), empresa.end(),
        [](const Funcionario& a, const Funcionario& b) {
            if (a.departamento != b.departamento)
                return a.departamento < b.departamento;
            return a.nome < b.nome;
        }
    );

    std::cout << "Primeiro da lista ordenada: "
              << empresa[0].departamento << " - " << empresa[0].nome << "\n";
    return 0;
}