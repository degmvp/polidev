// wx-cp-056-wxcp.cpp
// Migrado do acervo legado: cpps08.cpp
// POLYDEV | WXCP
// Título: std::move para transferência de objeto pesado

#include <iostream>
#include <utility>
#include <vector>
struct GrandeRelatorio{std::vector<double> dados; explicit GrandeRelatorio(std::size_t n):dados(n,0.0){}};
void salvarNoBanco(GrandeRelatorio r){std::cout<<"Relatório recebido: "<<r.dados.size()<<" itens\n";}
int main(){GrandeRelatorio r(1000000); salvarNoBanco(std::move(r)); std::cout<<"Após move, tamanho local: "<<r.dados.size()<<'\n';}
