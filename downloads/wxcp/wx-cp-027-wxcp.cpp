// wx-cp-027-wxcp.cpp
// Migrado do acervo legado: cpp08.cpp
// POLYDEV | WXCP
// Título: Bitwise: encontrar elemento único usando XOR

#include <iostream>
#include <vector>
int unico(const std::vector<int>& v) { int res=0; for (int x:v) res ^= x; return res; }
int main() { std::cout << "Único: " << unico({4,1,2,1,2,4,99}) << '\n'; }
