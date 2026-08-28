// wx-cp-032-wxcp.cpp
// Migrado do acervo legado: cpp13.cpp
// POLYDEV | WXCP
// Título: constexpr: função avaliada em tempo de compilação

#include <iostream>
constexpr int fatorial(int n){return n<=1?1:n*fatorial(n-1);} 
static_assert(fatorial(5)==120);
int main(){std::cout<<"5! = "<<fatorial(5)<<'\n';}
