13. constexpr função – avaliada em tempo de compilação
cpp13.cpp
constexpr int fatorial(int n) {
    return (n <= 1) ? 1 : n * fatorial(n - 1);
}
// static_assert(fatorial(5) == 120);