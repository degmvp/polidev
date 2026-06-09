 Uso: contabilizar quantos processos estão ativos em um sistema.

8. Validação de blocos de memória

#include <iostream>

bool validateBlockSize(uint32_t size) {
    return isPowerOfTwo(size);
}

int main() {
    std::cout << "Bloco 64 válido? " << validateBlockSize(64) << "\n";
    std::cout << "Bloco 70 válido? " << validateBlockSize(70) << "\n";
}