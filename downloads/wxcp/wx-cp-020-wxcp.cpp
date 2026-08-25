// ════════════════════════════════════════════════════════════════════════════
// wx-cp-020-wxcp.cpp — Cronômetro/Benchmark Profissional (RAII)
// ────────────────────────────────────────────────────────────────────────────
// DESCRIÇÃO (para que serve):
//   Classe RAII que mede tempo de execução com relógio de alta resolução e
//   imprime o resultado ao sair do escopo — sem chamadas manuais de
//   start/stop. Ideal para benchmarks, profiling de funções e logs de
//   performance.
//
// EXEMPLO:
//   { Timer t("Ordenação"); quicksort(...); }
//   -> Saída: Ordenação: 1.23 ms
// ════════════════════════════════════════════════════════════════════════════

#include <chrono>
#include <string>
#include <iostream>
#include <vector>
#include <numeric>

class Timer {
public:
    explicit Timer(std::string name)
        : name_(std::move(name)), start_(now()) {}

    ~Timer() {
        auto elapsed = std::chrono::duration<double, std::milli>(now() - start_).count();
        std::cout << name_ << ": " << elapsed << " ms\n";
    }

    Timer(const Timer&) = delete;
    Timer& operator=(const Timer&) = delete;

private:
    static std::chrono::high_resolution_clock::time_point now() {
        return std::chrono::high_resolution_clock::now();
    }
    std::string name_;
    std::chrono::high_resolution_clock::time_point start_;
};

int main() {
    std::vector<double> data(100000);
    std::iota(data.begin(), data.end(), 1.0);
    double result = 0.0;
    {
        Timer t("Somatório");
        for (double x : data) result += x;
    }
    std::cout << "Resultado: " << result << '\n';
    // Saída ex.: Somatório: 0.12 ms / Resultado: 5.00005e+09
}