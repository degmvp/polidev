 Uso: exemplo de criptografia leve com bitwise.

5. Verificação de integridade
cpp
#include <iostream>

bool checkIntegrity(uint32_t value) {
    return isPowerOfTwo(lowestBit(value));
}

int main() {
    uint32_t packet = 0b1001000;
    std::cout << "Integridade ok? " << checkIntegrity(packet) << "\n";
}
