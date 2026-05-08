19. std::string_view – visão de string sem cópia
cpp19.cpp
#include <string_view>

void exibirPrefixo(std::string_view texto, size_t n) {
    std::cout << texto.substr(0, n) << '
';
}
// Uso: exibirPrefixo("Hello World", 5); // "Hello"