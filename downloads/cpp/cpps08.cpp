08 • std::move
Transferência de memória
Evita copiar um objeto pesado ao passá-lo para outra função.

#include <iostream>
#include <vector>
#include <utility>

struct GrandeRelatorio {
    std::vector<double> todos_os_calculos;

    GrandeRelatorio(size_t tam)
        : todos_os_calculos(tam, 0.0) {}
};

void salvarNoBanco(GrandeRelatorio relatorio) {
    std::cout << "Relatorio salvo. Tamanho: "
              << relatorio.todos_os_calculos.size() << "\n";
}

int main() {
    GrandeRelatorio folha_mes_atual(1000000);

    salvarNoBanco(std::move(folha_mes_atual));

    return 0;
}