// wx-cp-026-wxcp.cpp
// Migrado do acervo legado: cpp07.cpp
// POLYDEV | WXCP
// Título: Bitwise: trocar dois números usando XOR

#include <iostream>
void trocar(int& a, int& b) { if (&a==&b) return; a ^= b; b ^= a; a ^= b; }
int main() { int a=10,b=25; trocar(a,b); std::cout << "a=" << a << " b=" << b << '\n'; }
