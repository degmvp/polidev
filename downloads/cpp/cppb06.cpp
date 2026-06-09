 Uso: validar pacotes ou registros.

6. Controle de status de transações com toggle

#include <iostream>

void toggleFraudFlag(uint32_t &txFlags) {
    txFlags = toggleBit(txFlags, 1); // bit 1 = fraude
}

int main() {
    uint32_t txFlags = 0b001; // aprovado
    toggleFraudFlag(txFlags);
    std::cout << "Flags após toggle: " << txFlags << "\n";
}