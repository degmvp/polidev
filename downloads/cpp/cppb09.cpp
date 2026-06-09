Uso: garantir que blocos de memória sejam potências de 2.

9. Extração do menor bit ativo para auditoria

#include <iostream>

void auditLowestFlag(uint32_t flags) {
    uint32_t lsb = lowestBit(flags);
    std::cout << "Menor flag ativa: " << lsb << "\n";
}

int main() {
    auditLowestFlag(0b101100);
}