// wx-cp-024-wxcp.cpp
// Migrado do acervo legado: cpp05.cpp
// POLYDEV | WXCP
// Título: Bitwise: verificar se número é potência de 2

#include <iostream>
bool ehPotenciaDe2(unsigned int n) { return n > 0 && (n & (n - 1)) == 0; }
int main() { for (unsigned n : {1u,2u,3u,4u,8u,10u,64u}) std::cout << n << ": " << std::boolalpha << ehPotenciaDe2(n) << '\n'; }
