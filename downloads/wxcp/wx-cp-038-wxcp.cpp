// wx-cp-038-wxcp.cpp
// Migrado do acervo legado: cpp19.cpp
// POLYDEV | WXCP
// Título: std::string_view sem cópia

#include <algorithm>
#include <iostream>
#include <string_view>
void exibirPrefixo(std::string_view texto,std::size_t n){std::cout<<texto.substr(0,std::min(n,texto.size()))<<'\n';}
int main(){exibirPrefixo("Hello World",5);}
