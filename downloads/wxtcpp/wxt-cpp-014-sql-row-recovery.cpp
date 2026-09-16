// ============================================================================
// POLYDEV | WX-TOOLS
// wxt-cpp-014-sql-row-recovery.cpp
//
// SQL Server MDF/NDF Row Inspector - Phase 2
//
// Purpose:
//   Read one DATA page and one slot from an OFFLINE SQL Server MDF/NDF,
//   locate the physical row record, decode the common in-row record header,
//   column count, NULL bitmap and variable-column offset array, and dump
//   the record bytes and decode the WX_RECOVERY_LAB.DadosTeste row values.
//
// IMPORTANT:
//   - READ-ONLY: the input file is opened with std::ifstream only.
//   - Always work on a COPY of the MDF/NDF.
//   - This phase inspects row structure; schema-aware value decoding comes next.
//
// Build (Visual Studio 2022 Developer Command Prompt):
//   cl /nologo /std:c++17 /O2 /EHsc /utf-8 /W4 wxt-cpp-014-sql-row-recovery.cpp /Fe:wxt-cpp-014-sql-row-recovery.exe
//
// Example:
//   wxt-cpp-014-sql-row-recovery.exe row WX_RECOVERY_LAB.mdf 8 0
// ============================================================================

#include <algorithm>
#include <array>
#include <cctype>
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

struct PageHeader {
    std::uint8_t type{};
    std::uint16_t slotCnt{};
    std::uint32_t pageId{};
    std::uint16_t fileId{};
};

static PageHeader decodePageHeader(const Page& p) {
    PageHeader h;
    h.type    = p[1];
    h.slotCnt = u16le(&p[22]);
    h.pageId  = static_cast<std::uint32_t>(p[32])
              | (static_cast<std::uint32_t>(p[33]) << 8)
              | (static_cast<std::uint32_t>(p[34]) << 16)
              | (static_cast<std::uint32_t>(p[35]) << 24);
    h.fileId  = u16le(&p[36]);
    return h;
}

class DataFile {
public:
    explicit DataFile(const std::string& path) : path_(path) {
        in_.open(path_, std::ios::binary);
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
        const auto offset = pageNo * PAGE_SIZE;
        if (offset > static_cast<std::uint64_t>(
                std::numeric_limits<std::streamoff>::max())) return false;

        in_.clear();
        in_.seekg(static_cast<std::streamoff>(offset), std::ios::beg);
        if (!in_) return false;
        in_.read(reinterpret_cast<char*>(out.data()),
                 static_cast<std::streamsize>(PAGE_SIZE));
        return in_.gcount() == static_cast<std::streamsize>(PAGE_SIZE);
    }

private:
    std::string path_;
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

static void banner() {
    std::cout
        << "============================================================\n"
        << " POLYDEV | WX-TOOLS - SQL ROW RECOVERY\n"
        << " Phase 2: physical row inspector (READ-ONLY)\n"
        << "============================================================\n";
}

static void usage(const char* exe) {
    banner();
    std::cout
        << "\nUsage:\n"
        << "  " << exe << " row <file.mdf|file.ndf> <physical-page> <slot>\n\n"
        << "Lab example:\n"
        << "  " << exe << " row WX_RECOVERY_LAB.mdf 8 0\n";
}

static void hexDump(const Page& p, std::size_t begin, std::size_t end) {
    end = std::min(end, p.size());
    for (std::size_t i = begin; i < end; i += 16) {
        std::cout << std::hex << std::setw(4) << std::setfill('0') << i << "  ";
        for (std::size_t j = 0; j < 16; ++j) {
            if (i + j < end)
                std::cout << std::setw(2)
                          << static_cast<unsigned>(p[i + j]) << ' ';
            else
                std::cout << "   ";
        }
        std::cout << " ";
        for (std::size_t j = 0; j < 16 && i + j < end; ++j) {
            const unsigned char c = p[i + j];
            std::cout << (std::isprint(c) ? static_cast<char>(c) : '.');
        }
        std::cout << '\n';
    }
    std::cout << std::dec << std::setfill(' ');
}

static std::vector<std::uint16_t> readSlots(const Page& p,
                                             std::uint16_t slotCnt) {
    std::vector<std::uint16_t> out;
    const std::uint64_t bytes = static_cast<std::uint64_t>(slotCnt) * 2ULL;
    if (bytes > PAGE_SIZE - HEADER_SIZE) return out;

    out.reserve(slotCnt);
    for (std::uint16_t i = 0; i < slotCnt; ++i) {
        const std::size_t pos =
            static_cast<std::size_t>(PAGE_SIZE -
            (static_cast<std::uint64_t>(i) + 1ULL) * 2ULL);
        out.push_back(u16le(&p[pos]));
    }
    return out;
}

static std::size_t recordBoundary(const std::vector<std::uint16_t>& slots,
                                  std::uint16_t rowOffset) {
    std::size_t end = PAGE_SIZE - slots.size() * 2ULL;
    for (const auto off : slots) {
        if (off > rowOffset && off < end) end = off;
    }
    return end;
}


static std::uint64_t u64leN(const std::uint8_t* p, std::size_t n) {
    std::uint64_t v = 0;
    for (std::size_t i = 0; i < n; ++i)
        v |= static_cast<std::uint64_t>(p[i]) << (8 * i);
    return v;
}

static std::string asciiField(const Page& p, std::size_t begin, std::size_t end) {
    if (begin > end || end > p.size()) return {};
    return std::string(reinterpret_cast<const char*>(&p[begin]), end - begin);
}

static std::string dateFromSqlDays(std::uint32_t days) {
    // SQL Server DATE/DATETIME2 date part:
    // unsigned day count where 0001-01-01 = 0.
    // Convert through the proleptic Gregorian 400-year cycle.
    std::uint64_t n = static_cast<std::uint64_t>(days);
    std::uint64_t y = 1;

    const std::uint64_t cycles400 = n / 146097ULL;
    y += cycles400 * 400ULL;
    n %= 146097ULL;

    std::uint64_t cycles100 = n / 36524ULL;
    if (cycles100 == 4ULL) cycles100 = 3ULL;
    y += cycles100 * 100ULL;
    n -= cycles100 * 36524ULL;

    const std::uint64_t cycles4 = n / 1461ULL;
    y += cycles4 * 4ULL;
    n %= 1461ULL;

    std::uint64_t cycles1 = n / 365ULL;
    if (cycles1 == 4ULL) cycles1 = 3ULL;
    y += cycles1;
    n -= cycles1 * 365ULL;

    const bool leap = (y % 4ULL == 0ULL) &&
                      ((y % 100ULL != 0ULL) || (y % 400ULL == 0ULL));

    static const unsigned monthDays[12] =
        {31,28,31,30,31,30,31,31,30,31,30,31};

    unsigned month = 1;
    while (month <= 12) {
        unsigned dim = monthDays[month - 1];
        if (month == 2 && leap) ++dim;
        if (n < dim) break;
        n -= dim;
        ++month;
    }

    const unsigned day = static_cast<unsigned>(n) + 1U;

    std::ostringstream os;
    os << std::setw(4) << std::setfill('0') << y << '-'
       << std::setw(2) << month << '-'
       << std::setw(2) << day;
    return os.str();
}

static std::string datetime2Scale0(const std::uint8_t* p) {
    // datetime2(0): 3-byte time in seconds + 3-byte date.
    const std::uint32_t sec = static_cast<std::uint32_t>(u64leN(p, 3));
    const std::uint32_t days = static_cast<std::uint32_t>(u64leN(p + 3, 3));
    const unsigned hh = sec / 3600U;
    const unsigned mm = (sec % 3600U) / 60U;
    const unsigned ss = sec % 60U;

    std::ostringstream os;
    os << dateFromSqlDays(days) << ' '
       << std::setw(2) << std::setfill('0') << hh << ':'
       << std::setw(2) << mm << ':'
       << std::setw(2) << ss;
    return os.str();
}

static void decodeRecoveryLabRow(const Page& p,
                                 std::uint16_t row,
                                 std::uint16_t fixedEnd,
                                 const std::vector<std::uint16_t>& varEnds) {
    // Schema used by WX_RECOVERY_LAB.dbo.DadosTeste:
    // Id BIGINT IDENTITY,
    // Codigo VARCHAR(30),
    // Nome VARCHAR(100),
    // Descricao VARCHAR(500),
    // Valor DECIMAL(18,2),
    // DataCadastro DATETIME2(0),
    // Marcador CHAR(32).
    //
    // SQL Server stores fixed-length columns before the variable section.
    if (fixedEnd != 59 || varEnds.size() != 3) {
        std::cout << "\nLAB DECODER: row does not match the expected DadosTeste layout.\n";
        return;
    }

    const std::size_t base = row;
    if (base + 59 > p.size()) return;

    const std::uint64_t id = u64leN(&p[base + 4], 8);

    const bool positive = p[base + 12] != 0;
    const std::uint64_t decimalMagnitude = u64leN(&p[base + 13], 8);
    const double valor =
        (positive ? 1.0 : -1.0) * static_cast<double>(decimalMagnitude) / 100.0;

    const std::string data = datetime2Scale0(&p[base + 21]);
    const std::string marcador = asciiField(p, base + 27, base + 59);

    // Variable data begins immediately after:
    // fixed data + column count + NULL bitmap + var-count + var-offset array.
    const std::size_t nullBytes = 1; // 7 columns in this lab schema.
    const std::size_t varDataRel =
        static_cast<std::size_t>(fixedEnd) + 2 + nullBytes + 2 + varEnds.size() * 2;

    const std::size_t e0 = varEnds[0] & 0x7FFFu;
    const std::size_t e1 = varEnds[1] & 0x7FFFu;
    const std::size_t e2 = varEnds[2] & 0x7FFFu;

    if (!(varDataRel <= e0 && e0 <= e1 && e1 <= e2 &&
          base + e2 <= p.size())) {
        std::cout << "\nLAB DECODER: invalid variable-column boundaries.\n";
        return;
    }

    const std::string codigo =
        asciiField(p, base + varDataRel, base + e0);
    const std::string nome =
        asciiField(p, base + e0, base + e1);
    const std::string descricao =
        asciiField(p, base + e1, base + e2);

    std::cout
        << "\nRECOVERED ROW - WX_RECOVERY_LAB.dbo.DadosTeste\n"
        << "------------------------------------------------------------\n"
        << "Id           : " << id << '\n'
        << "Codigo       : " << codigo << '\n'
        << "Nome         : " << nome << '\n'
        << "Descricao    : " << descricao << '\n'
        << "Valor        : " << std::fixed << std::setprecision(2) << valor << '\n'
        << "DataCadastro : " << data << '\n'
        << "Marcador     : " << marcador << '\n'
        << "------------------------------------------------------------\n";
}

static int inspectRow(DataFile& f, std::uint64_t pageNo,
                      std::uint64_t slotNo) {
    Page p{};
    if (!f.readPage(pageNo, p)) {
        std::cerr << "ERROR: unable to read physical page " << pageNo << ".\n";
        return 3;
    }

    const auto ph = decodePageHeader(p);
    banner();

    std::cout
        << "Physical page : " << pageNo << '\n'
        << "SQL Page ID   : (" << ph.fileId << ':' << ph.pageId << ")\n"
        << "Page type     : " << static_cast<unsigned>(ph.type)
        << (ph.type == 1 ? " (DATA)\n" : " (not DATA)\n")
        << "Slot count    : " << ph.slotCnt << '\n'
        << "Selected slot : " << slotNo << '\n';

    if (ph.type != 1) {
        std::cerr << "ERROR: selected page is not a DATA page.\n";
        return 4;
    }

    const auto slots = readSlots(p, ph.slotCnt);
    if (slots.size() != ph.slotCnt || slotNo >= slots.size()) {
        std::cerr << "ERROR: invalid slot number or slot array.\n";
        return 5;
    }

    const std::uint16_t row = slots[static_cast<std::size_t>(slotNo)];
    if (row < HEADER_SIZE || row + 4 > PAGE_SIZE) {
        std::cerr << "ERROR: slot points outside the valid row area.\n";
        return 6;
    }

    const std::uint8_t statusA = p[row];
    const std::uint8_t statusB = p[row + 1];
    const std::uint16_t fixedEnd = u16le(&p[row + 2]);

    std::cout
        << "Row offset    : " << row << '\n'
        << "Status Bits A : 0x" << std::hex << std::setw(2)
        << std::setfill('0') << static_cast<unsigned>(statusA) << '\n'
        << "Status Bits B : 0x" << std::setw(2)
        << static_cast<unsigned>(statusB)
        << std::dec << std::setfill(' ') << '\n'
        << "Fixed end     : " << fixedEnd << " bytes from row start\n";

    const std::size_t fixedEndAbs = static_cast<std::size_t>(row) + fixedEnd;
    if (fixedEnd < 4 || fixedEndAbs + 2 > PAGE_SIZE) {
        std::cerr << "ERROR: fixed-length boundary is outside the page.\n";
        return 7;
    }

    const std::uint16_t columnCount = u16le(&p[fixedEndAbs]);
    const std::size_t nullBytes =
        (static_cast<std::size_t>(columnCount) + 7ULL) / 8ULL;
    const std::size_t nullStart = fixedEndAbs + 2;
    const std::size_t afterNull = nullStart + nullBytes;

    if (afterNull > PAGE_SIZE) {
        std::cerr << "ERROR: NULL bitmap exceeds page boundary.\n";
        return 8;
    }

    std::cout
        << "Column count  : " << columnCount << '\n'
        << "NULL bitmap   : " << nullBytes << " byte(s)\n";

    std::cout << "NULL columns  : ";
    bool anyNull = false;
    for (std::uint16_t col = 0; col < columnCount; ++col) {
        const std::size_t byteIndex = col / 8;
        const unsigned bit = col % 8;
        if ((p[nullStart + byteIndex] & (1u << bit)) != 0) {
            if (anyNull) std::cout << ", ";
            std::cout << (col + 1);
            anyNull = true;
        }
    }
    if (!anyNull) std::cout << "none";
    std::cout << '\n';

    // For common primary records, a variable-column section follows the
    // NULL bitmap when Status Bits A indicates variable columns.
    // Bit 0x20 is the usual "has variable columns" flag for in-row records.
    const bool hasVarCols = (statusA & 0x20u) != 0;

    std::size_t structuralEnd = afterNull;
    std::vector<std::uint16_t> varEnds;

    if (hasVarCols) {
        if (afterNull + 2 > PAGE_SIZE) {
            std::cerr << "ERROR: variable-column count exceeds page.\n";
            return 9;
        }

        const std::uint16_t varCount = u16le(&p[afterNull]);
        const std::size_t offsetsStart = afterNull + 2;
        const std::size_t offsetsEnd =
            offsetsStart + static_cast<std::size_t>(varCount) * 2ULL;

        if (offsetsEnd > PAGE_SIZE) {
            std::cerr << "ERROR: variable-column offset array exceeds page.\n";
            return 10;
        }

        std::cout << "Variable cols : " << varCount << '\n';
        if (varCount != 0) {
            std::cout << "Var endings   : ";
            for (std::uint16_t i = 0; i < varCount; ++i) {
                const auto raw = u16le(&p[offsetsStart + i * 2ULL]);
                const auto endOff = static_cast<std::uint16_t>(raw & 0x7FFFu);
                varEnds.push_back(raw);
                if (i) std::cout << ", ";
                std::cout << endOff;
                if (raw & 0x8000u) std::cout << "(special)";
            }
            std::cout << '\n';
        }
        structuralEnd = offsetsEnd;
    } else {
        std::cout << "Variable cols : not flagged in Status Bits A\n";
    }

    const std::size_t boundary = recordBoundary(slots, row);
    const std::size_t maxDumpEnd =
        std::min<std::size_t>(boundary, static_cast<std::size_t>(row) + 256ULL);

    std::cout
        << "Row boundary  : " << boundary << '\n'
        << "Header parsed : through page offset " << structuralEnd << '\n'
        << "\nRaw row bytes (up to 256 bytes / next physical record):\n";

    hexDump(p, row, maxDumpEnd);

    if (columnCount == 7 && !anyNull)
        decodeRecoveryLabRow(p, row, fixedEnd, varEnds);

    std::cout
        << "\nRESULT: row structure located and parsed directly from MDF/NDF.\n"
        << "        No SQL Server query engine was used.\n";

    return 0;
}

} // namespace wxsql

int main(int argc, char* argv[]) {
#ifdef _WIN32
    SetConsoleOutputCP(1252);
#endif
    using namespace wxsql;

    if (argc != 5) {
        usage(argv[0]);
        return 1;
    }

    const std::string command = argv[1];
    if (command != "row") {
        std::cerr << "ERROR: unknown command: " << command << "\n\n";
        usage(argv[0]);
        return 1;
    }

    std::uint64_t pageNo = 0;
    std::uint64_t slotNo = 0;
    if (!parseU64(argv[3], pageNo) || !parseU64(argv[4], slotNo)) {
        std::cerr << "ERROR: page and slot must be unsigned integers.\n";
        return 1;
    }

    DataFile file(argv[2]);
    if (!file.ok()) {
        std::cerr << "ERROR: cannot open file: " << argv[2] << '\n';
        return 2;
    }

    if (pageNo >= file.fullPages()) {
        std::cerr << "ERROR: physical page is outside the file.\n";
        return 1;
    }

    return inspectRow(file, pageNo, slotNo);
}
