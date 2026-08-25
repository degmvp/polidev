// ════════════════════════════════════════════════════════════════════════════
// wx-cp-014-wxcp.cpp — Utilitários de Data/Hora: ISO 8601 e Diferença em Dias
// ────────────────────────────────────────────────────────────────────────────
// DESCRIÇÃO (para que serve):
//   Gera timestamp no formato ISO 8601 (interoperável com APIs e bancos de
//   dados) e calcula a diferença em dias entre duas datas usando o algoritmo
//   days_from_civil (O(1), sem loops por ano).
//
// EXEMPLO:
//   iso8601Now()                     -> "2026-08-25T14:30:00"
//   daysBetween(2026,1,1,2026,12,31) -> 364 (2026 não é bissexto)
// ════════════════════════════════════════════════════════════════════════════

#include <string>
#include <chrono>
#include <ctime>
#include <iomanip>
#include <sstream>

std::string iso8601Now() {
    auto now = std::chrono::system_clock::now();
    std::time_t t = std::chrono::system_clock::to_time_t(now);
    std::tm tm{};
#ifdef _WIN32
    localtime_s(&tm, &t);
#else
    localtime_r(&t, &tm);
#endif
    std::ostringstream oss;
    oss << std::put_time(&tm, "%Y-%m-%dT%H:%M:%S");
    return oss.str();
}

int daysFromCivil(int y, unsigned m, unsigned d) {
    y -= m <= 2;
    const int era = (y >= 0 ? y : y - 399) / 400;
    const unsigned yoe = static_cast<unsigned>(y - era * 400);
    const unsigned doy = (153 * (m + (m > 2 ? -3 : 9)) + 2) / 5 + d - 1;
    const unsigned doe = yoe * 365 + yoe / 4 - yoe / 100 + doy;
    return era * 146097 + static_cast<int>(doe) - 719468;
}

int daysBetween(int y1, int m1, int d1, int y2, int m2, int d2) {
    return daysFromCivil(y2, m2, d2) - daysFromCivil(y1, m1, d1);
}

#include <iostream>
int main() {
    std::cout << iso8601Now() << '\n';                              // ex.: 2026-08-25T14:30:00
    std::cout << daysBetween(2026, 1, 1, 2026, 12, 31) << '\n';     // 364
}