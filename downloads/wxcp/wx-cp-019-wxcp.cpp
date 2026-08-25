// ════════════════════════════════════════════════════════════════════════════
// wx-cp-019-wxcp.cpp — Avaliador de Expressões Aritméticas (Shunting-yard)
// ────────────────────────────────────────────────────────────────────────────
// DESCRIÇÃO (para que serve):
//   Avalia expressões aritméticas digitadas como texto: números decimais,
//   operadores + - * / ^ (potência), e parênteses, respeitando precedência e
//   associatividade. Base para calculadoras, planilhas e regras de negócio
//   configuráveis.
//
// EXEMPLO:
//   evaluate("3 + 4 * 2 / (1 - 5)^2") -> 3.5
// ════════════════════════════════════════════════════════════════════════════

#include <string>
#include <stack>
#include <map>
#include <cctype>
#include <cmath>
#include <stdexcept>
#include <iostream>

double evaluate(const std::string& expr) {
    std::map<char, int> prec{{'+',1},{'-',1},{'*',2},{'/',2},{'^',3}};
    std::stack<double> values;
    std::stack<char> ops;

    auto apply = [&](char op) {
        double b = values.top(); values.pop();
        double a = values.top(); values.pop();
        switch (op) {
            case '+': values.push(a + b); break;
            case '-': values.push(a - b); break;
            case '*': values.push(a * b); break;
            case '/':
                if (b == 0.0) throw std::runtime_error("divisão por zero");
                values.push(a / b); break;
            case '^': values.push(std::pow(a, b)); break;
        }
    };

    for (size_t i = 0; i < expr.size(); ++i) {
        char c = expr[i];
        if (std::isspace(static_cast<unsigned char>(c))) continue;
        if (std::isdigit(static_cast<unsigned char>(c)) || c == '.') {
            size_t j = i;
            while (j < expr.size() &&
                   (std::isdigit(static_cast<unsigned char>(expr[j])) || expr[j] == '.'))
                ++j;
            values.push(std::stod(expr.substr(i, j - i)));
            i = j - 1;
        } else if (c == '(') {
            ops.push(c);
        } else if (c == ')') {
            while (!ops.empty() && ops.top() != '(') { apply(ops.top()); ops.pop(); }
            if (ops.empty()) throw std::runtime_error("parêntese desbalanceado");
            ops.pop();
        } else if (prec.count(c)) {
            while (!ops.empty() && ops.top() != '(' &&
                   (prec[ops.top()] > prec[c] ||
                    (prec[ops.top()] == prec[c] && c != '^'))) {   // '^' é associativo à direita
                apply(ops.top()); ops.pop();
            }
            ops.push(c);
        } else {
            throw std::runtime_error(std::string("caractere inválido: ") + c);
        }
    }
    while (!ops.empty()) { apply(ops.top()); ops.pop(); }
    if (values.size() != 1) throw std::runtime_error("expressão malformada");
    return values.top();
}

int main() {
    std::cout << evaluate("3 + 4 * 2 / (1 - 5)^2") << '\n';   // 3.5
}