14. std::optional – valor opcional
cpp14.cpp
#include <optional>

std::optional<double> dividir(double a, double b) {
    if (b == 0) return std::nullopt;
    return a / b;
}
// Uso: if (auto res = dividir(10,2)) std::cout << *res;