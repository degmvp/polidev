// ════════════════════════════════════════════════════════════════════════════
// wx-cp-001-wxcp.cpp — Split Avançado de String
// ────────────────────────────────────────────────────────────────────────────
// DESCRIÇÃO (para que serve):
//   Divide uma string em tokens usando um conjunto de delimitadores,
//   com opção de descartar ou manter campos vazios. Ideal para parser de
//   configurações, CSV simples e entrada de linha de comando.
//
// EXEMPLO:
//   split("um,dois;;tres", ",;") -> {"um", "dois", "tres"}
// ════════════════════════════════════════════════════════════════════════════

#include <string>
#include <vector>
#include <string_view>

std::vector<std::string> split(const std::string& s,
                               const std::string& delimiters,
                               bool keep_empty = false) {
    std::vector<std::string> tokens;
    size_t start = 0;
    while (start <= s.size()) {
        size_t end = s.find_first_of(delimiters, start);
        if (end == std::string::npos) end = s.size();
        std::string token = s.substr(start, end - start);
        if (keep_empty || !token.empty())
            tokens.push_back(std::move(token));
        start = end + 1;
    }
    return tokens;
}

#include <iostream>
int main() {
    auto t = split("um,dois;;tres", ",;");
    for (const auto& x : t) std::cout << x << ' ';   // Saída: um dois tres
    std::cout << '\n';
}