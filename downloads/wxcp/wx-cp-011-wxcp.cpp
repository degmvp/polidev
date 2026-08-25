// ════════════════════════════════════════════════════════════════════════════
// wx-cp-011-wxcp.cpp — Parser de CSV com Suporte a Aspas
// ────────────────────────────────────────────────────────────────────────────
// DESCRIÇÃO (para que serve):
//   Lê dados CSV de qualquer stream (arquivo, string) tratando campos com
//   aspas e aspas duplicadas (""). Essencial para importação/exportação de
//   dados, integrações e migrações de sistemas legados.
//
// EXEMPLO:
//   "nome,idade\nJoão,30\nMaria,25" -> 3 linhas x 2 colunas
// ════════════════════════════════════════════════════════════════════════════

#include <vector>
#include <string>
#include <sstream>
#include <iostream>

std::vector<std::vector<std::string>> parseCSV(std::istream& in, char delim = ',') {
    std::vector<std::vector<std::string>> rows;
    std::string line;
    while (std::getline(in, line)) {
        std::vector<std::string> fields;
        std::string field;
        bool inQuotes = false;
        for (size_t i = 0; i < line.size(); ++i) {
            char c = line[i];
            if (inQuotes) {
                if (c == '"') {
                    if (i + 1 < line.size() && line[i + 1] == '"') { field += '"'; ++i; }
                    else inQuotes = false;
                } else field += c;
            } else {
                if (c == '"') inQuotes = true;
                else if (c == delim) { fields.push_back(field); field.clear(); }
                else field += c;
            }
        }
        fields.push_back(field);
        rows.push_back(std::move(fields));
    }
    return rows;
}

int main() {
    std::stringstream ss("nome,idade\n\"João, Jr.\",30\nMaria,25");
    auto rows = parseCSV(ss);
    for (const auto& r : rows) {
        for (const auto& f : r) std::cout << '[' << f << "] ";
        std::cout << '\n';
    }
    // [nome] [idade]
    // [João, Jr.] [30]
    // [Maria] [25]
}