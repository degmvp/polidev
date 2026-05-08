2. Leitura de CSV simples (separador vírgula)
cpp02.cpp
// Lê campos separados por vírgula
#include <sstream>
#include <vector>

std::vector<std::vector<std::string>> lerCSV(const std::string& caminho) {
    std::ifstream arquivo(caminho);
    std::vector<std::vector<std::string>> dados;
    std::string linha;
    while (std::getline(arquivo, linha)) {
        std::stringstream ss(linha);
        std::string campo;
        std::vector<std::string> linhaDados;
        while (std::getline(ss, campo, ',')) {
            linhaDados.push_back(campo);
        }
        dados.push_back(linhaDados);
    }
    return dados;
}