// wx-cp-022-wxcp.cpp
// Migrado do acervo legado: cpp03.cpp
// POLYDEV | WXCP
// Título: Leitura de TXT com delimitador personalizado

#include <fstream>
#include <iostream>
#include <sstream>
#include <string>

void lerDelimitado(const std::string& caminho, char delim='|') {
    std::ifstream arq(caminho);
    if (!arq) { std::cerr << "Não foi possível abrir: " << caminho << '\n'; return; }
    std::string linha;
    while (std::getline(arq, linha)) {
        std::stringstream ss(linha); std::string token;
        while (std::getline(ss, token, delim)) std::cout << '[' << token << "] ";
        std::cout << '\n';
    }
}
int main(int argc, char** argv) {
    if (argc > 1) lerDelimitado(argv[1], argc > 2 ? argv[2][0] : '|');
    else std::cout << "Uso: ./programa arquivo.txt [delimitador]\n";
}
