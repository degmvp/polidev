20. std::filesystem – ler diretório e arquivos (C++17)
cpp20.cpp
#include <filesystem>
namespace fs = std::filesystem;

void listarArquivos(const fs::path& dir) {
    for (const auto& entry : fs::directory_iterator(dir)) {
        if (entry.is_regular_file()) {
            std::cout << entry.path().filename() << '
';
        }
    }
}