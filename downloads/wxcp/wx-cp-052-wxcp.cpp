// wx-cp-052-wxcp.cpp
// Migrado do acervo legado: cpps04.cpp
// POLYDEV | WXCP
// Título: std::vector::reserve para grandes volumes

#include <iostream>
#include <vector>
struct RegistroFolha{int id; double valor;};
int main(){std::vector<RegistroFolha> v; v.reserve(2000000); for(int i=0;i<2000000;++i)v.push_back({i,2500.0}); std::cout<<"Tamanho: "<<v.size()<<" Capacidade: "<<v.capacity()<<'\n';}
