// wx-cp-036-wxcp.cpp
// Migrado do acervo legado: cpp17.cpp
// POLYDEV | WXCP
// Título: Template com parâmetro auto C++17

#include <iostream>
template<auto N> void mostrarConstante(){std::cout<<N<<'\n';}
int main(){mostrarConstante<42>(); mostrarConstante<'X'>();}
