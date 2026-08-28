// wx-cp-031-wxcp.cpp
// Migrado do acervo legado: cpp12.cpp
// POLYDEV | WXCP
// Título: Range-based for com inicializador C++20

#include <iostream>
#include <vector>
void exibir(const std::vector<int>& v){for(int i=0; int x:v) std::cout<<i++<<": "<<x<<'\n';}
int main(){exibir({10,20,30});}
