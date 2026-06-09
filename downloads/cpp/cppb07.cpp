 Uso: alternar rapidamente o estado de fraude em uma transação.

7. Contagem de operações ativas

#include <iostream>

int activeOperations(uint32_t opsFlags) {
    return countBits(opsFlags);
}

int main() {
    uint32_t ops = 0b101101;
    std::cout << "Operações ativas: " << activeOperations(ops) << "\n";
}
