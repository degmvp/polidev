// ════════════════════════════════════════════════════════════════════════════
// wx-cp-003-wxcp.cpp — Formatação de Bytes Legível
// ────────────────────────────────────────────────────────────────────────────
// DESCRIÇÃO (para que serve):
//   Converte um tamanho em bytes para uma unidade legível (B, KB, MB, GB, TB),
//   com precisão configurável. Útil em dashboards, gerenciadores de arquivo,
//   relatórios de uso de disco e logs de upload/download.
//
// EXEMPLO:
//   formatBytes(1536)      -> "1.50 KB"
//   formatBytes(1073741824)-> "1.00 GB"
// ════════════════════════════════════════════════════════════════════════════

#include <string>
#include <cstdint>
#include <sstream>
#include <iomanip>

std::string formatBytes(std::uint64_t bytes, int precision = 2) {
    static const char* units[] = {"B", "KB", "MB", "GB", "TB", "PB"};
    double value = static_cast<double>(bytes);
    int unit = 0;
    while (value >= 1024.0 && unit < 5) { value /= 1024.0; ++unit; }
    std::ostringstream oss;
    oss << std::fixed << std::setprecision(precision) << value << ' ' << units[unit];
    return oss.str();
}

#include <iostream>
int main() {
    std::cout << formatBytes(1536) << '\n';             // 1.50 KB
    std::cout << formatBytes(1073741824ULL) << '\n';    // 1.00 GB
}