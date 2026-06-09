Uso: simula permissões de acesso em sistemas bancários.

2. Máscara para extrair código de agência

#include <iostream>

uint32_t extractAgencyCode(uint32_t accountData) {
    return maskBits(accountData, 8, 8); // bits 8-15
}

int main() {
    uint32_t accountPacked = 0b1010101100110010;
    std::cout << "Agência: " << extractAgencyCode(accountPacked) << "\n";
}
