// ════════════════════════════════════════════════════════════════════════════
// wx-cp-010-wxcp.cpp — Álgebra Linear: Multiplicação e Transposição de Matrizes
// ────────────────────────────────────────────────────────────────────────────
// DESCRIÇÃO (para que serve):
//   Operações matriciais genéricas (multiplicação com verificação de
//   dimensões e transposição). Base para gráficos, machine learning,
//   transformações geométricas e processamento de imagens.
//
// EXEMPLO:
//   A = {{1,2},{3,4}}  B = {{5,6},{7,8}}
//   A x B = {{19,22},{43,50}}   transpose(A) = {{1,3},{2,4}}
// ════════════════════════════════════════════════════════════════════════════

#include <vector>
#include <stdexcept>
#include <iostream>

template <typename T>
using Matrix = std::vector<std::vector<T>>;

template <typename T>
Matrix<T> matmul(const Matrix<T>& a, const Matrix<T>& b) {
    if (a.empty() || b.empty() || a[0].size() != b.size())
        throw std::invalid_argument("dimensões incompatíveis para multiplicação");
    size_t n = a.size(), m = a[0].size(), p = b[0].size();
    Matrix<T> c(n, std::vector<T>(p, T{}));
    for (size_t i = 0; i < n; ++i)
        for (size_t k = 0; k < m; ++k)
            for (size_t j = 0; j < p; ++j)
                c[i][j] += a[i][k] * b[k][j];   // laço k-ij melhora cache
    return c;
}

template <typename T>
Matrix<T> transpose(const Matrix<T>& a) {
    if (a.empty()) return {};
    size_t rows = a.size(), cols = a[0].size();
    Matrix<T> t(cols, std::vector<T>(rows));
    for (size_t i = 0; i < rows; ++i)
        for (size_t j = 0; j < cols; ++j)
            t[j][i] = a[i][j];
    return t;
}

int main() {
    Matrix<int> a{{1, 2}, {3, 4}}, b{{5, 6}, {7, 8}};
    auto c = matmul(a, b);
    for (const auto& row : c) {
        for (int x : row) std::cout << x << ' ';
        std::cout << '\n';   // 19 22 \n 43 50
    }
}