// ════════════════════════════════════════════════════════════════════════════
// wx-cp-015-wxcp.cpp — Gerador de UUID v4 (RFC 4122)
// ────────────────────────────────────────────────────────────────────────────
// DESCRIÇÃO (para que serve):
//   Gera identificadores únicos universais versão 4, baseados em aleatoriedade
//   (122 bits aleatórios), no formato 8-4-4-4-12. Ideal como chave primária
//   distribuída, id de pedidos, sessões e rastreamento sem servidor central.
//
// EXEMPLO:
//   uuid4() -> "550e8400-e29b-41d4-a716-446655440000" (formato; valores variam)
// ════════════════════════════════════════════════════════════════════════════

#include <string>
#include <random>
#include <cstdint>
#include <cstdio>

std::string uuid4() {
    static std::random_device rd;
    static std::mt19937_64 gen(rd());
    std::uniform_int_distribution<std::uint64_t> dist;
    std::uint64_t a = dist(gen), b = dist(gen);
    a = (a & 0xFFFFFFFFFFFF0FFFULL) | 0x0000000000004000ULL;   // versão 4
    b = (b & 0x3FFFFFFFFFFFFFFFULL) | 0x8000000000000000ULL;   // variante RFC 4122
    char buf[37];
    std::snprintf(buf, sizeof(buf), "%08x-%04x-%04x-%04x-%012llx",
        static_cast<unsigned>((a >> 32) & 0xFFFFFFFF),
        static_cast<unsigned>((a >> 16) & 0xFFFF),
        static_cast<unsigned>(a & 0xFFFF),
        static_cast<unsigned>((b >> 48) & 0xFFFF),
        static_cast<unsigned long long>(b & 0xFFFFFFFFFFFFULL));
    return buf;
}

#include <iostream>
int main() {
    std::cout << uuid4() << '\n';   // ex.: 550e8400-e29b-41d4-a716-446655440000
}