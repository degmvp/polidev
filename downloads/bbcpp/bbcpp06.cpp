06 • int64_t
Cálculo financeiro preciso e rápido
Trabalha com centavos para evitar erro de ponto flutuante.

#include <iostream>
#include <cstdint>

int main() {
    int64_t salario_centavos = 150050;
    int64_t desconto_percentual = 8;

    int64_t desconto_centavos = (salario_centavos * desconto_percentual) / 100;
    int64_t liquido_centavos = salario_centavos - desconto_centavos;

    std::cout << "Salario Liquido: R$ " << liquido_centavos / 100.0 << "\n";
    return 0;
}