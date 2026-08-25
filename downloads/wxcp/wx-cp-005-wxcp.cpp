// ════════════════════════════════════════════════════════════════════════════
// wx-cp-005-wxcp.cpp — Quicksort Otimizado (Mediana de Três + Insertion Sort)
// ────────────────────────────────────────────────────────────────────────────
// DESCRIÇÃO (para que serve):
//   Ordenação avançada que combina quicksort com pivot pela mediana de três
//   (evita pior caso em dados ordenados) e insertion sort para partições
//   pequenas (reduz overhead). Recursão no lado menor limita a pilha a O(log n).
//
// EXEMPLO:
//   quicksort({7,3,9,1,5,2,8,6,4,0}) -> 0 1 2 3 4 5 6 7 8 9
// ════════════════════════════════════════════════════════════════════════════

#include <vector>
#include <algorithm>

template <typename T>
void insertionSort(std::vector<T>& v, int lo, int hi) {
    for (int i = lo + 1; i <= hi; ++i) {
        T key = std::move(v[i]);
        int j = i - 1;
        while (j >= lo && v[j] > key) { v[j + 1] = std::move(v[j]); --j; }
        v[j + 1] = std::move(key);
    }
}

template <typename T>
int medianOfThree(std::vector<T>& v, int lo, int hi) {
    int mid = lo + (hi - lo) / 2;
    if (v[mid] < v[lo]) std::swap(v[lo], v[mid]);
    if (v[hi] < v[lo]) std::swap(v[lo], v[hi]);
    if (v[hi] < v[mid]) std::swap(v[mid], v[hi]);
    return mid;
}

template <typename T>
int partition(std::vector<T>& v, int lo, int hi) {
    std::swap(v[medianOfThree(v, lo, hi)], v[hi]);
    const T pivot = v[hi];
    int i = lo;
    for (int j = lo; j < hi; ++j)
        if (v[j] < pivot) std::swap(v[i++], v[j]);
    std::swap(v[i], v[hi]);
    return i;
}

template <typename T>
void quicksort(std::vector<T>& v, int lo, int hi) {
    constexpr int kThreshold = 16;
    while (lo < hi) {
        if (hi - lo < kThreshold) { insertionSort(v, lo, hi); return; }
        int p = partition(v, lo, hi);
        if (p - lo < hi - p) { quicksort(v, lo, p - 1); lo = p + 1; }
        else                 { quicksort(v, p + 1, hi); hi = p - 1; }
    }
}

#include <iostream>
int main() {
    std::vector<int> v{7, 3, 9, 1, 5, 2, 8, 6, 4, 0};
    quicksort(v, 0, static_cast<int>(v.size()) - 1);
    for (int x : v) std::cout << x << ' ';   // 0 1 2 3 4 5 6 7 8 9
    std::cout << '\n';
}