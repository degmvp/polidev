// wx-cp-053-wxcp.cpp
// Migrado do acervo legado: cpps05.cpp
// POLYDEV | WXCP
// Título: constexpr: cálculo em tempo de compilação

#include <iostream>
constexpr double potencia(double b,int e){double r=1.0; for(int i=0;i<e;++i) r*=b; return r;}
constexpr double taxaDiariaAproximada(double anual){return anual/252.0;}
int main(){constexpr double taxa=taxaDiariaAproximada(0.12); static_assert(taxa>0); std::cout<<"Taxa diária aproximada: "<<taxa<<'\n';}
