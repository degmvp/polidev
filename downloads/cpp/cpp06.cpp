6. Bitwise: contar bits setados (popcount) – C++20
cpp06.cpp
// std::popcount disponível em C++20
#include <bit>
int contarBits(unsigned int n) {
    return std::popcount(n);
}
// Alternativa manual: while (n) { cont++; n &= n-1; }