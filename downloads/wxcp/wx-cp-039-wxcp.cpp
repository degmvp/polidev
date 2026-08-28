// wx-cp-039-wxcp.cpp
// Migrado do acervo legado: cpp20.cpp
// POLYDEV | WXCP
// Título: std::filesystem: listar arquivos de diretório

#include <filesystem>
#include <iostream>
namespace fs=std::filesystem;
void listarArquivos(const fs::path& dir){for(const auto& e:fs::directory_iterator(dir)) if(e.is_regular_file()) std::cout<<e.path().filename().string()<<'\n';}
int main(int argc,char** argv){listarArquivos(argc>1?fs::path(argv[1]):fs::current_path());}
