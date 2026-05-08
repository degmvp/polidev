10. Lambda com auto e captura moderna
cpp10.cpp
// Lambda genérica e captura por referência
#include <vector>
#include <algorithm>

auto maiorQue = [](const auto& a, const auto& b) { return a > b; };
// Uso: std::sort(v.begin(), v.end(), maiorQue);