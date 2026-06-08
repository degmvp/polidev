04 • vector::reserve
Evita travamentos ao ler DB
Reserva memória de uma vez antes de inserir milhões de registros.

#include <iostream>
#include <vector>

struct RegistroFolha {
    int id;
    double valor;
};

int main() {
    std::vector<RegistroFolha> folha_processed;

    folha_processed.reserve(2000000);

    for (int i = 0; i < 2000000; ++i) {
        folha_processed.push_back({i, 2500.00});
    }

    std::cout << "Tamanho final: " << folha_processed.size() << "\n";
    return 0;
}