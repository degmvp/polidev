12. Range-based for loop com inicializador (C++20)
cpp12.cpp
// for com variável de inicialização
#include <vector>

void exibir(const std::vector<int>& v) {
    for (int i = 0; int x : v) {
        std::cout << i++ << ": " << x << '
';
    }
}