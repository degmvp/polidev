11. Smart pointer: unique_ptr
cpp11.cpp
// Gerenciamento automático de memória
#include <memory>

std::unique_ptr<int> criaInteiro(int valor) {
    return std::make_unique<int>(valor);
} // liberado automaticamente ao sair do escopo