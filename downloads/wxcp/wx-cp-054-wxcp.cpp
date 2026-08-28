// wx-cp-054-wxcp.cpp
// Migrado do acervo legado: cpps06.cpp
// POLYDEV | WXCP
// Título: int64_t para cálculo financeiro em centavos

#include <cstdint>
#include <iomanip>
#include <iostream>
int main(){std::int64_t salario=150050, pct=8; auto desconto=(salario*pct)/100; auto liquido=salario-desconto; std::cout<<std::fixed<<std::setprecision(2)<<"Salário líquido: R$ "<<liquido/100.0<<'\n';}
