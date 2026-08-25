// ════════════════════════════════════════════════════════════════════════════
// wx-cp-004-wxcp.cpp — Gerador de Números Aleatórios Seguros
// ────────────────────────────────────────────────────────────────────────────
// DESCRIÇÃO (para que serve):
//   Classe wrapper sobre o <random> do C++11: usa random_device como semente,
//   distribuições uniformes de inteiros e reais. Evita rand()/srand() (não
//   confiáveis). Base para sorteios, amostragem, testes e simulações.
//
// EXEMPLO:
//   rng.integer(1, 100) -> inteiro aleatório entre 1 e 100
//   rng.real(0.0, 1.0)  -> real aleatório no intervalo [0, 1)
// ════════════════════════════════════════════════════════════════════════════

#include <random>
#include <cstdint>

class SecureRandom {
    std::random_device rd_;
    std::mt19937_64 gen_{rd_()};
public:
    std::uint64_t integer(std::uint64_t min, std::uint64_t max) {
        return std::uniform_int_distribution<std::uint64_t>(min, max)(gen_);
    }
    double real(double min, double max) {
        return std::uniform_real_distribution<double>(min, max)(gen_);
    }
    bool boolean() { return integer(0, 1) == 1; }
};

#include <iostream>
int main() {
    SecureRandom rng;
    for (int i = 0; i < 5; ++i) std::cout << rng.integer(1, 100) << ' ';
    std::cout << '\n';   // ex.: 42 7 93 15 68
}