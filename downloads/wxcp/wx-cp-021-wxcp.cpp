// wx-cp-021-wxcp.cpp
// Migrado do acervo legado: cpp01.cpp
// POLYDEV | WXCP
// Título: Leitura de arquivo TXT linha a linha

#include <fstream>
#include <iostream>
#include <string>

void lerTXT(const std::string& caminho) {
    std::ifstream arquivo(caminho);
    if (!arquivo) { std::cerr << "Não foi possível abrir: " << caminho << '\n'; return; }
    std::string linha;
    while (std::getline(arquivo, linha)) std::cout << linha << '\n';
}
int main(int argc, char** argv) {
    if (argc > 1) lerTXT(argv[1]);
    else std::cout << "Uso: ./programa arquivo.txt\n";
}
