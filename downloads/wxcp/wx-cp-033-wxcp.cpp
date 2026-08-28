// wx-cp-033-wxcp.cpp
// Migrado do acervo legado: cpp14.cpp
// POLYDEV | WXCP
// Título: std::optional para valor opcional

#include <iostream>
#include <optional>
std::optional<double> dividir(double a,double b){if(b==0) return std::nullopt; return a/b;}
int main(){for(auto [a,b]: {std::pair{10.0,2.0},std::pair{10.0,0.0}}){auto r=dividir(a,b); if(r) std::cout<<a<<'/'<<b<<" = "<<*r<<'\n'; else std::cout<<"divisão inválida\n";}}
