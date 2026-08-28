// wx-cp-050-wxcp.cpp
// Migrado do acervo legado: cpps01.cpp
// POLYDEV | WXCP
// Título: std::reduce: soma paralela de folha

#include <execution>
#include <iostream>
#include <numeric>
#include <vector>
int main(){std::vector<double> salarios(500000,3500.0); double total=std::reduce(std::execution::par,salarios.begin(),salarios.end(),0.0); std::cout<<"Total da folha: "<<total<<'\n';}
