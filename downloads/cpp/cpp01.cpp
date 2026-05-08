1. Leitura de arquivo TXT linha a linha
cpp01.cpp
// Lê cada linha de um arquivo .txt
#include <fstream>
#include <iostream>
#include <string>

void lerTXT(const std::string& caminho) {
    std::ifstream arquivo(caminho);
    std::string linha;
    while (std::getline(arquivo, linha)) {
        std::cout << linha << '
';
    }
}