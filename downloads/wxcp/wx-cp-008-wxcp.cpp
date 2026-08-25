// ════════════════════════════════════════════════════════════════════════════
// wx-cp-008-wxcp.cpp — Validação de CPF Brasileiro
// ────────────────────────────────────────────────────────────────────────────
// DESCRIÇÃO (para que serve):
//   Valida o CPF pelo algoritmo oficial (módulo 11): remove máscara, confere
//   11 dígitos, rejeita sequências repetidas e confere os dois dígitos
//   verificadores. Essencial em cadastros, checkout e sistemas de CRM.
//
// EXEMPLO:
//   validCPF("529.982.247-25") -> true
//   validCPF("111.111.111-11") -> false (dígitos repetidos)
// ════════════════════════════════════════════════════════════════════════════

#include <string>
#include <cctype>

bool validCPF(const std::string& cpf) {
    std::string digits;
    for (unsigned char c : cpf)
        if (std::isdigit(c)) digits.push_back(static_cast<char>(c));
    if (digits.size() != 11) return false;
    if (digits == std::string(11, digits[0])) return false;   // 000...000 etc.

    auto checkDigit = [&](int len) {
        int sum = 0;
        for (int i = 0; i < len; ++i)
            sum += (digits[i] - '0') * (len + 1 - i);
        int rest = (sum * 10) % 11;
        return (rest == 10) ? 0 : rest;
    };
    return checkDigit(9)  == digits[9]  - '0' &&
           checkDigit(10) == digits[10] - '0';
}

#include <iostream>
int main() {
    std::cout << std::boolalpha;
    std::cout << validCPF("529.982.247-25") << '\n';   // true
    std::cout << validCPF("111.111.111-11") << '\n';   // false
}