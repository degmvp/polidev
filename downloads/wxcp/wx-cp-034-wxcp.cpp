// wx-cp-034-wxcp.cpp
// Migrado do acervo legado: cpp15.cpp
// POLYDEV | WXCP
// Título: std::variant: união type-safe

#include <iostream>
#include <string>
#include <variant>
using Valor=std::variant<int,double,std::string>;
void mostrar(const Valor& v){std::visit([](const auto& x){std::cout<<x<<'\n';},v);} 
int main(){Valor v=42; mostrar(v); v=3.14; mostrar(v); v=std::string("texto"); mostrar(v);}
