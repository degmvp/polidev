15. std::variant – união type-safe
cpp15.cpp
#include <variant>
#include <string>

std::variant<int, double, std::string> valor;
valor = 42;
valor = 3.14;
valor = "texto";
// Acesso com std::get<T> ou std::visit