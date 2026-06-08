10 • std::async e std::future
Processamento por filiais
Calcula balanços de filiais ao mesmo tempo e junta o resultado no final.

#include <iostream>
#include <future>
#include <thread>
#include <chrono>
#include <string>

double calcularBalancoFilial(std::string nome_filial) {
    std::this_thread::sleep_for(std::chrono::milliseconds(100));
    return 150000.00;
}

int main() {
    std::future<double> fut_sul =
        std::async(std::launch::async, calcularBalancoFilial, "Filial Sul");

    std::future<double> fut_norte =
        std::async(std::launch::async, calcularBalancoFilial, "Filial Norte");

    std::cout << "Processando filiais...\n";

    double total_geral = fut_sul.get() + fut_norte.get();

    std::cout << "Balanco consolidado: R$ " << total_geral << "\n";
    return 0;
}