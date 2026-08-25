// ════════════════════════════════════════════════════════════════════════════
// wx-cp-006-wxcp.cpp — Busca Binária Genérica (Lower Bound)
// ────────────────────────────────────────────────────────────────────────────
// DESCRIÇÃO (para que serve):
//   Reimplementação de std::lower_bound em O(log n) sobre iteradores
//   genéricos: retorna o primeiro elemento >= value. Permite comparador
//   customizado (ex.: busca por campos de structs ou direção descendente).
//
// EXEMPLO:
//   v = {1,3,5,7,9,11}; lowerBound(v, 6) -> iterador apontando para 7 (índice 3)
// ════════════════════════════════════════════════════════════════════════════

#include <iterator>
#include <vector>
#include <iostream>

template <typename It, typename T, typename Comp = std::less<>>
It lowerBound(It first, It last, const T& value, Comp comp = {}) {
    std::ptrdiff_t count = std::distance(first, last);
    while (count > 0) {
        It it = first;
        std::ptrdiff_t step = count / 2;
        std::advance(it, step);
        if (comp(*it, value)) { first = ++it; count -= step + 1; }
        else                  { count = step; }
    }
    return first;
}

int main() {
    std::vector<int> v{1, 3, 5, 7, 9, 11};
    auto it = lowerBound(v.begin(), v.end(), 6);
    std::cout << *it << " no índice " << (it - v.begin()) << '\n';  // 7 no índice 3
}