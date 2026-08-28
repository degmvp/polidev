// wx-cp-035-wxcp.cpp
// Migrado do acervo legado: cpp16.cpp
// POLYDEV | WXCP
// Título: Structured bindings em C++17

#include <iostream>
#include <map>
#include <string>
int main(){std::map<int,std::string> m{{1,"um"},{2,"dois"}}; for(const auto& [chave,valor]:m) std::cout<<chave<<": "<<valor<<'\n';}
