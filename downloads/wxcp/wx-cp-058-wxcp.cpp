// wx-cp-058-wxcp.cpp
// Migrado do acervo legado: cpps10.cpp
// POLYDEV | WXCP
// Título: std::async e std::future para processamento concorrente

#include <chrono>
#include <future>
#include <iostream>
#include <string>
#include <thread>
double calcularBalancoFilial(const std::string&){std::this_thread::sleep_for(std::chrono::milliseconds(100)); return 150000.0;}
int main(){auto sul=std::async(std::launch::async,calcularBalancoFilial,"Sul"); auto norte=std::async(std::launch::async,calcularBalancoFilial,"Norte"); std::cout<<"Balanço consolidado: R$ "<<sul.get()+norte.get()<<'\n';}
