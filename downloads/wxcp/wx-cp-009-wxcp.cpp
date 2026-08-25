// ════════════════════════════════════════════════════════════════════════════
// wx-cp-009-wxcp.cpp — Estatística Descritiva
// ────────────────────────────────────────────────────────────────────────────
// DESCRIÇÃO (para que serve):
//   Calcula média, mediana, moda, variância e desvio padrão de um conjunto
//   de dados. Base para análises, relatórios de qualidade, métricas de
//   desempenho e qualquer aplicação de BI.
//
// EXEMPLO:
//   dados = {4,8,6,5,3,2,8,9,2,5}
//   média=5.20  mediana=5.00  moda=2 (menor em empate)
//   variância=5.76  desvio=2.40
// ════════════════════════════════════════════════════════════════════════════

#include <vector>
#include <numeric>
#include <algorithm>
#include <cmath>
#include <map>
#include <stdexcept>
#include <iostream>

struct Stats { double mean, median, mode, variance, stddev; };

Stats analyze(const std::vector<double>& data) {
    if (data.empty()) throw std::invalid_argument("conjunto vazio");

    double mean = std::accumulate(data.begin(), data.end(), 0.0) / data.size();

    std::vector<double> sorted(data);
    std::sort(sorted.begin(), sorted.end());
    size_t n = sorted.size();
    double median = (n % 2) ? sorted[n / 2]
                            : (sorted[n / 2 - 1] + sorted[n / 2]) / 2.0;

    std::map<double, int> freq;
    for (double x : sorted) ++freq[x];
    auto best = std::max_element(freq.begin(), freq.end(),
        [](const auto& a, const auto& b) { return a.second < b.second; });
    double mode = best->first;

    double variance = 0.0;
    for (double x : data) { double d = x - mean; variance += d * d; }
    variance /= n;

    return {mean, median, mode, variance, std::sqrt(variance)};
}

int main() {
    Stats s = analyze({4, 8, 6, 5, 3, 2, 8, 9, 2, 5});
    std::cout << s.mean << ' ' << s.median << ' ' << s.mode << ' '
              << s.variance << ' ' << s.stddev << '\n';
    // 5.2 5 2 5.76 2.4
}