// wx-cp-023-wxcp.cpp
// Migrado do acervo legado: cpp04.cpp
// POLYDEV | WXCP
// Título: Ler arquivo inteiro para uma string

#include <fstream>
#include <iostream>
#include <iterator>
#include <string>

std::string lerArquivoInteiro(const std::string& caminho) {
    std::ifstream arq(caminho);
    if (!arq) return {};
    return {std::istreambuf_iterator<char>(arq), std::istreambuf_iterator<char>()};
}
int main(int argc, char** argv) {
    if (argc < 2) { std::cout << "Uso: ./programa arquivo.txt\n"; return 0; }
    std::cout << lerArquivoInteiro(argv[1]);
}
