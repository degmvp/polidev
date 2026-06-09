 Uso: extrair parte de um identificador binário.

3. Compressão de flags de transação

#include <iostream>

uint32_t compressFlags(bool approved, bool fraud, bool priority) {
    uint32_t flags = 0;
    if (approved) flags = setBit(flags, 0);
    if (fraud)    flags = setBit(flags, 1);
    if (priority) flags = setBit(flags, 2);
    return flags;
}

int main() {
    uint32_t txFlags = compressFlags(true, false, true);
    std::cout << "Flags da transação: " << txFlags << "\n";
}
