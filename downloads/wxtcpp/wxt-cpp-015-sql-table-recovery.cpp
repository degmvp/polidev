// ============================================================================
// POLYDEV | WX-TOOLS
// wxt-cpp-015-sql-table-recovery.cpp
//
// SQL Server MDF/NDF Table Recovery - Phase 3
//
// Purpose:
//   Scan DATA pages in an OFFLINE SQL Server MDF/NDF, walk valid slots and
//   recover rows matching the validated WX_RECOVERY_LAB.dbo.DadosTeste layout.
//   Recovered rows are exported to CSV.
//
// IMPORTANT:
//   - READ-ONLY: the MDF/NDF is opened with std::ifstream only.
//   - The output CSV is a NEW file; the database file is never modified.
//   - Always work on a COPY of damaged MDF/NDF files.
//   - This first Phase 3 decoder intentionally targets the schema already
//     validated by wxt-cpp-014-sql-row-recovery.cpp.
//
// Build (Visual Studio 2022 Developer Command Prompt):
//   cl /nologo /std:c++17 /O2 /EHsc /utf-8 /W4
//      wxt-cpp-015-sql-table-recovery.cpp
//      /Fe:wxt-cpp-015-sql-table-recovery.exe
//
// Usage:
//   wxt-cpp-015-sql-table-recovery.exe harvest <file.mdf|file.ndf> <output.csv>
//   wxt-cpp-015-sql-table-recovery.exe harvest <file> <output.csv> <start-page> <end-page>
//
// Example:
//   wxt-cpp-015-sql-table-recovery.exe harvest WX_RECOVERY_LAB.mdf recovered.csv
// ============================================================================

#include <algorithm>
#include <array>
#include <cstdint>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <limits>
#include <sstream>
#include <string>
#include <vector>

#ifdef _WIN32
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <windows.h>
#endif

namespace wxsql {

constexpr std::uint64_t PAGE_SIZE = 8192;
constexpr std::size_t HEADER_SIZE = 96;
using Page = std::array<std::uint8_t, PAGE_SIZE>;

static std::uint16_t u16le(const std::uint8_t* p) {
    return static_cast<std::uint16_t>(p[0])
         | (static_cast<std::uint16_t>(p[1]) << 8);
}

static std::uint64_t u64leN(const std::uint8_t* p, std::size_t n) {
    std::uint64_t v = 0;
    for (std::size_t i = 0; i < n; ++i)
        v |= static_cast<std::uint64_t>(p[i]) << (8 * i);
    return v;
}

struct PageHeader {
    std::uint8_t type{};
    std::uint16_t slotCnt{};
    std::uint32_t pageId{};
    std::uint16_t fileId{};
};

static PageHeader decodePageHeader(const Page& p) {
    PageHeader h;
    h.type = p[1];
    h.slotCnt = u16le(&p[22]);
    h.pageId = static_cast<std::uint32_t>(p[32])
             | (static_cast<std::uint32_t>(p[33]) << 8)
             | (static_cast<std::uint32_t>(p[34]) << 16)
             | (static_cast<std::uint32_t>(p[35]) << 24);
    h.fileId = u16le(&p[36]);
    return h;
}

class DataFile {
public:
    explicit DataFile(const std::string& path) {
        in_.open(path, std::ios::binary);
        if (!in_) return;
        in_.seekg(0, std::ios::end);
        const auto end = in_.tellg();
        if (end < 0) { in_.close(); return; }
        size_ = static_cast<std::uint64_t>(end);
        in_.seekg(0, std::ios::beg);
    }

    bool ok() const { return in_.is_open(); }
    std::uint64_t fullPages() const { return size_ / PAGE_SIZE; }

    bool readPage(std::uint64_t pageNo, Page& out) {
        if (!ok() || pageNo >= fullPages()) return false;
        const auto off = pageNo * PAGE_SIZE;
        if (off > static_cast<std::uint64_t>(
                std::numeric_limits<std::streamoff>::max())) return false;
        in_.clear();
        in_.seekg(static_cast<std::streamoff>(off), std::ios::beg);
        if (!in_) return false;
        in_.read(reinterpret_cast<char*>(out.data()),
                 static_cast<std::streamsize>(PAGE_SIZE));
        return in_.gcount() == static_cast<std::streamsize>(PAGE_SIZE);
    }

private:
    std::ifstream in_;
    std::uint64_t size_{0};
};

static bool parseU64(const std::string& s, std::uint64_t& v) {
    try {
        std::size_t n = 0;
        const auto x = std::stoull(s, &n, 10);
        if (n != s.size()) return false;
        v = static_cast<std::uint64_t>(x);
        return true;
    } catch (...) {
        return false;
    }
}

static std::vector<std::uint16_t> readSlots(const Page& p,
                                             std::uint16_t slotCnt) {
    std::vector<std::uint16_t> out;
    const std::uint64_t bytes = static_cast<std::uint64_t>(slotCnt) * 2ULL;
    if (bytes > PAGE_SIZE - HEADER_SIZE) return out;
    out.reserve(slotCnt);
    for (std::uint16_t i = 0; i < slotCnt; ++i) {
        const std::size_t pos = static_cast<std::size_t>(
            PAGE_SIZE - (static_cast<std::uint64_t>(i) + 1ULL) * 2ULL);
        out.push_back(u16le(&p[pos]));
    }
    return out;
}

static std::string bytes(const Page& p, std::size_t begin, std::size_t end) {
    if (begin > end || end > p.size()) return {};
    return std::string(reinterpret_cast<const char*>(&p[begin]), end - begin);
}

static std::string dateFromSqlDays(std::uint32_t days) {
    std::uint64_t n = static_cast<std::uint64_t>(days);
    std::uint64_t y = 1;

    const std::uint64_t c400 = n / 146097ULL;
    y += c400 * 400ULL;
    n %= 146097ULL;

    std::uint64_t c100 = n / 36524ULL;
    if (c100 == 4ULL) c100 = 3ULL;
    y += c100 * 100ULL;
    n -= c100 * 36524ULL;

    const std::uint64_t c4 = n / 1461ULL;
    y += c4 * 4ULL;
    n %= 1461ULL;

    std::uint64_t c1 = n / 365ULL;
    if (c1 == 4ULL) c1 = 3ULL;
    y += c1;
    n -= c1 * 365ULL;

    const bool leap = (y % 4ULL == 0ULL) &&
                      ((y % 100ULL != 0ULL) || (y % 400ULL == 0ULL));
    static const unsigned md[12] =
        {31,28,31,30,31,30,31,31,30,31,30,31};

    unsigned month = 1;
    while (month <= 12) {
        unsigned dim = md[month - 1];
        if (month == 2 && leap) ++dim;
        if (n < dim) break;
        n -= dim;
        ++month;
    }

    std::ostringstream os;
    os << std::setw(4) << std::setfill('0') << y << '-'
       << std::setw(2) << month << '-'
       << std::setw(2) << (static_cast<unsigned>(n) + 1U);
    return os.str();
}

static std::string datetime2Scale0(const std::uint8_t* p) {
    const std::uint32_t sec = static_cast<std::uint32_t>(u64leN(p, 3));
    const std::uint32_t days = static_cast<std::uint32_t>(u64leN(p + 3, 3));
    if (sec >= 86400U) return {};

    std::ostringstream os;
    os << dateFromSqlDays(days) << ' '
       << std::setw(2) << std::setfill('0') << sec / 3600U << ':'
       << std::setw(2) << (sec % 3600U) / 60U << ':'
       << std::setw(2) << sec % 60U;
    return os.str();
}

struct RecoveredRow {
    std::uint64_t physicalPage{};
    std::uint16_t fileId{};
    std::uint32_t sqlPageId{};
    std::uint16_t slot{};
    std::uint64_t id{};
    std::string codigo;
    std::string nome;
    std::string descricao;
    std::string valor;
    std::string dataCadastro;
    std::string marcador;
};

static bool decodeDadosTeste(const Page& p, std::uint16_t row,
                             RecoveredRow& out) {
    if (row < HEADER_SIZE || static_cast<std::size_t>(row) + 4 > PAGE_SIZE)
        return false;

    const std::uint8_t statusA = p[row];
    const std::uint16_t fixedEnd = u16le(&p[row + 2]);

    // Validated physical layout for WX_RECOVERY_LAB.dbo.DadosTeste.
    if ((statusA & 0x20u) == 0 || fixedEnd != 59)
        return false;

    const std::size_t base = row;
    const std::size_t fixedEndAbs = base + fixedEnd;
    if (fixedEndAbs + 3 > PAGE_SIZE) return false;

    const std::uint16_t columnCount = u16le(&p[fixedEndAbs]);
    if (columnCount != 7) return false;

    const std::size_t nullStart = fixedEndAbs + 2;
    if (nullStart >= PAGE_SIZE) return false;

    // Phase 3 v1 recovers complete non-NULL lab rows only.
    if ((p[nullStart] & 0x7Fu) != 0) return false;

    const std::size_t afterNull = nullStart + 1;
    if (afterNull + 2 > PAGE_SIZE) return false;

    const std::uint16_t varCount = u16le(&p[afterNull]);
    if (varCount != 3) return false;

    const std::size_t offsetsStart = afterNull + 2;
    if (offsetsStart + 6 > PAGE_SIZE) return false;

    const std::uint16_t r0 = u16le(&p[offsetsStart]);
    const std::uint16_t r1 = u16le(&p[offsetsStart + 2]);
    const std::uint16_t r2 = u16le(&p[offsetsStart + 4]);
    if ((r0 | r1 | r2) & 0x8000u) return false;

    const std::size_t e0 = r0;
    const std::size_t e1 = r1;
    const std::size_t e2 = r2;
    const std::size_t varDataRel = fixedEnd + 2 + 1 + 2 + 6; // 70

    if (!(varDataRel <= e0 && e0 <= e1 && e1 <= e2 &&
          base + e2 <= PAGE_SIZE))
        return false;

    const std::string codigo = bytes(p, base + varDataRel, base + e0);

    // Strong signature prevents unrelated 7-column DATA rows being exported.
    if (codigo.rfind("WX-", 0) != 0) return false;

    const bool positive = p[base + 12] != 0;
    if (p[base + 12] != 0 && p[base + 12] != 1) return false;

    const std::uint64_t magnitude = u64leN(&p[base + 13], 8);
    std::ostringstream val;
    val << (positive ? "" : "-")
        << (magnitude / 100ULL) << '.'
        << std::setw(2) << std::setfill('0') << (magnitude % 100ULL);

    const std::string dt = datetime2Scale0(&p[base + 21]);
    if (dt.empty()) return false;

    out.id = u64leN(&p[base + 4], 8);
    out.codigo = codigo;
    out.nome = bytes(p, base + e0, base + e1);
    out.descricao = bytes(p, base + e1, base + e2);
    out.valor = val.str();
    out.dataCadastro = dt;
    out.marcador = bytes(p, base + 27, base + 59);
    return true;
}

static std::string csv(const std::string& s) {
    std::string out = "\"";
    for (char c : s) {
        if (c == '"') out += "\"\"";
        else out += c;
    }
    out += '"';
    return out;
}

static void banner() {
    std::cout
        << "============================================================\n"
        << " POLYDEV | WX-TOOLS - SQL TABLE RECOVERY\n"
        << " Phase 3: DATA page row harvester (READ-ONLY)\n"
        << "============================================================\n";
}

static void usage(const char* exe) {
    banner();
    std::cout
        << "\nUsage:\n"
        << "  " << exe << " harvest <file.mdf|file.ndf> <output.csv>\n"
        << "  " << exe << " harvest <file> <output.csv> <start-page> <end-page>\n";
}

static int harvest(DataFile& f, const std::string& output,
                   std::uint64_t first, std::uint64_t last) {
    std::ofstream out(output, std::ios::binary | std::ios::trunc);
    if (!out) {
        std::cerr << "ERROR: cannot create output CSV: " << output << '\n';
        return 4;
    }

    out << "physical_page,file_id,sql_page_id,slot,Id,Codigo,Nome,Descricao,"
           "Valor,DataCadastro,Marcador\r\n";

    std::uint64_t pagesRead = 0;
    std::uint64_t dataPages = 0;
    std::uint64_t slotsSeen = 0;
    std::uint64_t recovered = 0;
    std::uint64_t rejected = 0;

    Page p{};
    for (std::uint64_t pageNo = first; pageNo <= last; ++pageNo) {
        if (!f.readPage(pageNo, p)) continue;
        ++pagesRead;

        const auto ph = decodePageHeader(p);
        if (ph.type != 1) continue;
        ++dataPages;

        const auto slots = readSlots(p, ph.slotCnt);
        if (slots.size() != ph.slotCnt) continue;

        for (std::size_t i = 0; i < slots.size(); ++i) {
            ++slotsSeen;
            RecoveredRow r;
            if (!decodeDadosTeste(p, slots[i], r)) {
                ++rejected;
                continue;
            }

            r.physicalPage = pageNo;
            r.fileId = ph.fileId;
            r.sqlPageId = ph.pageId;
            r.slot = static_cast<std::uint16_t>(i);

            out << r.physicalPage << ','
                << r.fileId << ','
                << r.sqlPageId << ','
                << r.slot << ','
                << r.id << ','
                << csv(r.codigo) << ','
                << csv(r.nome) << ','
                << csv(r.descricao) << ','
                << r.valor << ','
                << csv(r.dataCadastro) << ','
                << csv(r.marcador) << "\r\n";

            ++recovered;
            if (recovered <= 10 || recovered % 10000ULL == 0) {
                std::cout << "RECOVERED  page " << pageNo
                          << " slot " << i
                          << "  Id=" << r.id
                          << "  Codigo=" << r.codigo << '\n';
            }
        }

        if (pageNo == last) break; // avoids uint64 overflow
    }

    out.flush();

    std::cout
        << "\n------------------------------------------------------------\n"
        << "Pages read     : " << pagesRead << '\n'
        << "DATA pages     : " << dataPages << '\n'
        << "Slots examined : " << slotsSeen << '\n'
        << "Rows recovered : " << recovered << '\n'
        << "Rows rejected  : " << rejected << '\n'
        << "Output CSV     : " << output << '\n'
        << "------------------------------------------------------------\n"
        << "RESULT: recovery harvest completed without modifying MDF/NDF.\n";

    return 0;
}

} // namespace wxsql

int main(int argc, char* argv[]) {
#ifdef _WIN32
    SetConsoleOutputCP(1252);
#endif
    using namespace wxsql;

    if (argc != 4 && argc != 6) {
        usage(argv[0]);
        return 1;
    }

    if (std::string(argv[1]) != "harvest") {
        std::cerr << "ERROR: unknown command.\n\n";
        usage(argv[0]);
        return 1;
    }

    DataFile file(argv[2]);
    if (!file.ok()) {
        std::cerr << "ERROR: cannot open input file: " << argv[2] << '\n';
        return 2;
    }

    if (file.fullPages() == 0) {
        std::cerr << "ERROR: input has no complete SQL Server pages.\n";
        return 3;
    }

    std::uint64_t first = 0;
    std::uint64_t last = file.fullPages() - 1;

    if (argc == 6) {
        if (!parseU64(argv[4], first) || !parseU64(argv[5], last) ||
            first > last || last >= file.fullPages()) {
            std::cerr << "ERROR: invalid page range.\n";
            return 1;
        }
    }

    banner();
    std::cout
        << "Input          : " << argv[2] << '\n'
        << "Output         : " << argv[3] << '\n'
        << "Physical pages : " << first << " .. " << last << '\n'
        << "Decoder        : WX_RECOVERY_LAB.dbo.DadosTeste\n"
        << "Mode           : MDF/NDF READ-ONLY\n\n";

    return harvest(file, argv[3], first, last);
}
