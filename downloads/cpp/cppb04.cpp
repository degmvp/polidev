 Uso: compactar múltiplos estados em um único inteiro.

4. Rotação para criptografia simples

#include <iostream>

uint32_t simpleEncrypt(uint32_t value) {
    return rotateLeft(value, 5) ^ 0xA5A5A5A5;
}

uint32_t simpleDecrypt(uint32_t value) {
    return rotateRight(value ^ 0xA5A5A5A5, 5);
}

int main() {
    uint32_t data = 123456;
    auto enc = simpleEncrypt(data);
    auto dec = simpleDecrypt(enc);

    std::cout << "Original: " << data << " | Decriptado: " << dec << "\n";
}