// ════════════════════════════════════════════════════════════════════════════
// wx-cp-012-wxcp.cpp — Compactação RLE (Run-Length Encoding)
// ────────────────────────────────────────────────────────────────────────────
// DESCRIÇÃO (para que serve):
//   Compacta sequências de bytes repetidos como pares (quantidade, valor).
//   Muito eficiente em imagens com áreas planas, fontes bitmap e logs com
//   repetição. Inclui decodificador para round-trip garantido.
//
// EXEMPLO:
//   encode("AAAABBBCC") -> "\x04A\x03B\x02C"
//   decode(encode(x))   -> x (round-trip sem perdas)
// ════════════════════════════════════════════════════════════════════════════

#include <string>
#include <iostream>

std::string rleEncode(const std::string& s) {
    std::string out;
    for (size_t i = 0; i < s.size();) {
        size_t j = i;
        while (j < s.size() && s[j] == s[i] && j - i < 255) ++j;   // máx 255
        out.push_back(static_cast<char>(j - i));
        out.push_back(s[i]);
        i = j;
    }
    return out;
}

std::string rleDecode(const std::string& s) {
    std::string out;
    for (size_t i = 0; i + 1 < s.size(); i += 2)
        out.append(static_cast<unsigned char>(s[i]), s[i + 1]);
    return out;
}

int main() {
    std::string original = "AAAABBBCC";
    std::string encoded = rleEncode(original);
    std::cout << "tamanho: " << original.size() << " -> " << encoded.size() << '\n';
    std::cout << (rleDecode(encoded) == original) << '\n';   // 1 (round-trip OK)
}