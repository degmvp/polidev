10. Rotação para gerar hash simples

#include <iostream>

uint32_t generateHash(uint32_t key) {
    return rotateLeft(key, 7) ^ rotateRight(key, 3);
}

int main() {
    uint32_t key = 12345;
    std::cout << "Hash: " << generateHash(key) << "\n";
}