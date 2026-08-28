// wx-cp-057-wxcp.cpp
// Migrado do acervo legado: cpps09.cpp
// POLYDEV | WXCP
// Título: std::transform para geração em lote

#include <algorithm>
#include <iostream>
#include <vector>
int main(){std::vector<double> brutos{3000,5000,7000},liquidos(brutos.size()); std::transform(brutos.begin(),brutos.end(),liquidos.begin(),[](double x){return x*0.80;}); for(double x:liquidos) std::cout<<x<<' '; std::cout<<'\n';}
