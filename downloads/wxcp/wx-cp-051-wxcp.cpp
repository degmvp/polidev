// wx-cp-051-wxcp.cpp
// Migrado do acervo legado: cpps02.cpp
// POLYDEV | WXCP
// Título: std::for_each paralelo: cálculo de juros

#include <algorithm>
#include <execution>
#include <iostream>
#include <vector>
int main(){std::vector<double> saldos{1500,3200.5,800,45000}; double taxa=1.0001; std::for_each(std::execution::par,saldos.begin(),saldos.end(),[&](double& s){s*=taxa;}); std::cout<<"Saldo 1: "<<saldos[0]<<'\n';}
