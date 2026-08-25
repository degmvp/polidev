// ════════════════════════════════════════════════════════════════════════════
// wx-cp-002-wxcp.cpp — Hash FNV-1a 64-bit
// ────────────────────────────────────────────────────────────────────────────
// DESCRIÇÃO (para que serve):
//   Função hash não criptográfica de 64 bits, extremamente rápida e com boa
//   distribuição. Usada em tabelas hash, caches, dicionários e deduplicação
//   de strings. Constexpr: pode ser avaliada em tempo de compilação.
//
// EXEMPLO:
//   fnv1a64("hello") -> valor inteiro de 64 bits determinístico e estável
// ════════════════════════════════════════════════════════════════════════════

#include <cstdint>
#include <string_view>

constexpr std::uint64_t fnv1a64(std::string_view text,
    std::uint64_t seed = 1469598103934665603ULL /* offset basis */) {
    constexpr std::uint64_t prime = 1099511628211ULL;
    std::uint64_t hash = seed;
    for (unsigned char c : text) {
        hash ^= c;
        hash *= prime;
    }
    return hash;
}

#include <iostream>
int main() {
    std::cout << fnv1a64("hello") << '\n';          // hash fixo para "hello"
    std::cout << fnv1a64("world") << '\n';          // hash diferente
}