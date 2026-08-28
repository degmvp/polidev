// wx-cp-037-wxcp.cpp
// Migrado do acervo legado: cpp18.cpp
// POLYDEV | WXCP
// Título: Fold expressions C++17

#include <iostream>
template<typename... Args> auto soma(Args... args){return (args + ...);} 
int main(){std::cout<<soma(1,2,3,4)<<'\n';}
