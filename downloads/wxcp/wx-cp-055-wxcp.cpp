// wx-cp-055-wxcp.cpp
// Migrado do acervo legado: cpps07.cpp
// POLYDEV | WXCP
// Título: std::sort com lambda em registros

#include <algorithm>
#include <iostream>
#include <string>
#include <vector>
struct Funcionario{std::string departamento,nome; double salario;};
int main(){std::vector<Funcionario> v{{"TI","Joao",5000},{"RH","Maria",4000},{"TI","Ana",6000}}; std::sort(v.begin(),v.end(),[](const auto&a,const auto&b){return a.departamento!=b.departamento?a.departamento<b.departamento:a.nome<b.nome;}); for(const auto& f:v) std::cout<<f.departamento<<" - "<<f.nome<<'\n';}
