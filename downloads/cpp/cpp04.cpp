4. Ler arquivo inteiro para uma string (moderno)
cpp04.cpp
// Usa istreambuf_iterator para ler tudo de uma vez
#include <fstream>
#include <string>
#include <iterator>

std::string lerArquivoInteiro(const std::string& caminho) {
    std::ifstream arq(caminho);
    return {std::istreambuf_iterator<char>(arq),
            std::istreambuf_iterator<char>()};
}