16. Structured bindings (C++17)
cpp16.cpp
// Desestruturação de tuplas/pares
#include <tuple>
#include <map>

std::map<int, std::string> m = {{1,"um"}};
for (const auto& [chave, valor] : m) {
    std::cout << chave << ": " << valor << '
';
}