3. Leitura de TXT com delimitador personalizado
cpp03.cpp
// Usa '|' como delimitador
#include <fstream>
#include <string>
#include <sstream>

void lerDelimitado(const std::string& caminho, char delim = '|') {
    std::ifstream arq(caminho);
    std::string linha;
    while (std::getline(arq, linha)) {
        std::stringstream ss(linha);
        std::string token;
        while (std::getline(ss, token, delim)) {
            std::cout << token << ' ';
        }
        std::cout << '
';
    }
}