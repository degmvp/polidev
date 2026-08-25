// ════════════════════════════════════════════════════════════════════════════
// wx-cp-017-wxcp.cpp — Slugify (Texto para URLs)
// ────────────────────────────────────────────────────────────────────────────
// DESCRIÇÃO (para que serve):
//   Converte títulos em slugs amigáveis para URLs e SEO: remove acentos,
//   passa para minúsculas e substitui caracteres não alfanuméricos por hífens.
//   Usado em blogs, e-commerce e rotas de aplicações web.
//
// EXEMPLO:
//   slugify("Olá, Mundo! Como vai?") -> "ola-mundo-como-vai"
// ════════════════════════════════════════════════════════════════════════════

#include <string>
#include <cctype>

std::string slugify(const std::string& text) {
    static const std::string accented =
        "áàâãäéèêëíìîïóòôõöúùûüçñÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇÑ";
    static const std::string plain    =
        "aaaaaeeeeiiiiooooouuuucnAAAAAEEEEIIIIOOOOOUUUUCN";
    std::string out;
    for (unsigned char c : text) {
        size_t pos = accented.find(static_cast<char>(c));
        if (pos != std::string::npos)
            out += plain[pos];
        else if (std::isalnum(c))
            out += static_cast<char>(std::tolower(c));
        else if (!out.empty() && out.back() != '-')
            out += '-';
    }
    while (!out.empty() && out.back() == '-') out.pop_back();
    return out;
}

#include <iostream>
int main() {
    std::cout << slugify("Olá, Mundo! Como vai?") << '\n';   // ola-mundo-como-vai
}