// wx-cp-030-wxcp.cpp
// Migrado do acervo legado: cpp11.cpp
// POLYDEV | WXCP
// Título: Smart pointer com std::unique_ptr

#include <iostream>
#include <memory>
std::unique_ptr<int> criaInteiro(int valor){return std::make_unique<int>(valor);} 
int main(){auto p=criaInteiro(42); std::cout<<"Valor: "<<*p<<'\n';}
