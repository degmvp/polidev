// wx-cp-025-wxcp.cpp
// Migrado do acervo legado: cpp06.cpp
// POLYDEV | WXCP
// Título: Bitwise: contar bits setados com std::popcount

#include <bit>
#include <iostream>
int contarBits(unsigned int n) { return std::popcount(n); }
int main() { unsigned int n=0b101101u; std::cout << "Bits ligados: " << contarBits(n) << '\n'; }
