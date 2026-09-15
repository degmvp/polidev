// ============================================================================
// POLYDEV | WX-TOOLS
// wxt-cpp-013-sql-page-recovery.cpp
//
// SQL Server MDF/NDF Page Scanner - Phase 1
//
// Purpose:
//   Read SQL Server data files (.mdf/.ndf) OFFLINE and READ-ONLY.
//   Scan 8 KiB pages, decode common 96-byte page-header fields,
//   inspect slot arrays, and dump raw pages.
//
// IMPORTANT:
//   - This tool NEVER writes to the input file.
//   - Always work on a COPY of the MDF/NDF.
//   - This is a forensic/recovery utility, not a DBCC replacement.
//   - Phase 1 does NOT reconstruct table rows yet.
//
// Build (Visual Studio 2022 Developer Command Prompt):
//   cl /nologo /std:c++17 /O2 /EHsc /utf-8 /W4 wxt-cpp-013-sql-page-recovery.cpp /Fe:wxt-cpp-013-sql-page-recovery.exe
//
// Examples:
//   wxt-cpp-013-sql-page-recovery.exe info  banco.mdf
//   wxt-cpp-013-sql-page-recovery.exe scan  banco.mdf
//   wxt-cpp-013-sql-page-recovery.exe page  banco.mdf 123
//   wxt-cpp-013-sql-page-recovery.exe slots banco.mdf 123
//
// Page numbering in this tool is the physical zero-based page offset in ONE file.
// SQL Server identifies a database page by (file_id : page_id).
// ============================================================================

#include <algorithm>
#include <array>
#include <cctype>
#include <cstdint>
#include <cstring>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <limits>
#include <map>
#include <sstream>
#include <string>
#include <vector>

namespace wxsql {

constexpr std::uint64_t PAGE_SIZE   = 8192;
constexpr std::size_t   HEADER_SIZE = 96;

using Page = std::array<std::uint8_t, PAGE_SIZE>;

static std::uint16_t u16le(const std::uint8_t* p) {
    return static_cast<std::uint16_t>(p[0])
         | (static_cast<std::uint16_t>(p[1]) << 8);
}

static std::uint32_t u32le(const std::uint8_t* p) {
    return static_cast<std::uint32_t>(p[0])
         | (static_cast<std::uint32_t>(p[1]) << 8)
         | (static_cast<std::uint32_t>(p[2]) << 16)
         | (static_cast<std::uint32_t>(p[3]) << 24);
}

struct PageHeader {
    std::uint8_t  headerVersion{};
    std::uint8_t  type{};
    std::uint8_t  typeFlagBits{};
    std::uint8_t  level{};
    std::uint16_t flagBits{};
    std::uint16_t indexId{};

    std::uint32_t prevPageId{};
    std::uint16_t prevFileId{};
    std::uint16_t pminlen{};

    std::uint32_t nextPageId{};
    std::uint16_t nextFileId{};
    std::uint16_t slotCnt{};

    std::uint32_t objId{};
    std::uint16_t freeCnt{};
    std::uint16_t freeData{};

    std::uint32_t pageId{};
    std::uint16_t fileId{};
    std::uint16_t reservedCnt{};

    bool saneBasic{false};
    bool physicalPageMatches{false};
};

static PageHeader decodeHeader(const Page& p, std::uint64_t physicalPage) {
    PageHeader h;

    h.headerVersion = p[0];
    h.type          = p[1];
    h.typeFlagBits  = p[2];
    h.level         = p[3];
    h.flagBits      = u16le(&p[4]);
    h.indexId       = u16le(&p[6]);

    h.prevPageId    = u32le(&p[8]);
    h.prevFileId    = u16le(&p[12]);
    h.pminlen       = u16le(&p[14]);

    h.nextPageId    = u32le(&p[16]);
    h.nextFileId    = u16le(&p[20]);
    h.slotCnt       = u16le(&p[22]);

    h.objId         = u32le(&p[24]);
    h.freeCnt       = u16le(&p[28]);
    h.freeData      = u16le(&p[30]);

    h.pageId        = u32le(&p[32]);
    h.fileId        = u16le(&p[36]);
    h.reservedCnt   = u16le(&p[38]);

    const std::uint64_t slotBytes = static_cast<std::uint64_t>(h.slotCnt) * 2ULL;

    h.saneBasic =
        h.headerVersion != 0 &&
        h.headerVersion != 0xFF &&
        h.type != 0xFF &&
        slotBytes <= (PAGE_SIZE - HEADER_SIZE) &&
        h.freeData <= PAGE_SIZE &&
        h.freeCnt <= PAGE_SIZE;

    h.physicalPageMatches =
        static_cast<std::uint64_t>(h.pageId) == physicalPage;

    return h;
}

static const char* pageTypeName(std::uint8_t t) {
    // Common SQL Server page types. Unknown values are intentionally preserved.
    switch (t) {
        case 1:  return "DATA";
        case 2:  return "INDEX";
        case 3:  return "TEXT_MIX";
        case 4:  return "TEXT_TREE";
        case 7:  return "SORT";
        case 8:  return "GAM";
        case 9:  return "SGAM";
        case 10: return "IAM";
        case 11: return "PFS";
        case 13: return "BOOT";
        case 15: return "FILE_HEADER";
        case 16: return "DIFF_MAP";
        case 17: return "ML_MAP";
        default: return "OTHER/UNKNOWN";
    }
}

class DataFile {
public:
    explicit DataFile(const std::string& path) : path_(path) {
        in_.open(path_, std::ios::binary);
        if (!in_) return;

        in_.seekg(0, std::ios::end);
        const auto end = in_.tellg();
        if (end < 0) {
            in_.close();
            return;
        }

        size_ = static_cast<std::uint64_t>(end);
        in_.seekg(0, std::ios::beg);
    }

    bool ok() const { return in_.is_open(); }
    std::uint64_t size() const { return size_; }
    std::uint64_t fullPages() const { return size_ / PAGE_SIZE; }
    std::uint64_t remainder() const { return size_ % PAGE_SIZE; }
    const std::string& path() const { return path_; }

    bool readPage(std::uint64_t pageNo, Page& out) {
        if (!ok() || pageNo >= fullPages()) return false;

        const std::uint64_t offset = pageNo * PAGE_SIZE;
        if (offset > static_cast<std::uint64_t>(
                std::numeric_limits<std::streamoff>::max())) {
            return false;
        }

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

static std::string humanBytes(std::uint64_t n) {
    static const char* units[] = {"B", "KiB", "MiB", "GiB", "TiB"};
    double v = static_cast<double>(n);
    std::size_t i = 0;
    while (v >= 1024.0 && i < 4) {
        v /= 1024.0;
        ++i;
    }

    std::ostringstream os;
    os << std::fixed << std::setprecision(i == 0 ? 0 : 2)
       << v << ' ' << units[i];
    return os.str();
}

static void banner() {
    std::cout
        << "============================================================\n"
        << " POLYDEV | WX-TOOLS - SQL PAGE RECOVERY\n"
        << " Phase 1: MDF/NDF offline page scanner (READ-ONLY)\n"
        << "============================================================\n";
}

static void usage(const char* exe) {
    banner();
    std::cout
        << "\nUsage:\n"
        << "  " << exe << " info  <file.mdf|file.ndf>\n"
        << "  " << exe << " scan  <file.mdf|file.ndf>\n"
        << "  " << exe << " page  <file.mdf|file.ndf> <physical-page-no>\n"
        << "  " << exe << " slots <file.mdf|file.ndf> <physical-page-no>\n\n"
        << "Notes:\n"
        << "  * Input is opened with std::ifstream only: no writes are performed.\n"
        << "  * Use a COPY of the database data file.\n"
        << "  * Page number here is the zero-based physical page within one file.\n";
}

static bool parseU64(const std::string& s, std::uint64_t& value) {
    if (s.empty()) return false;
    std::size_t idx = 0;
    try {
        unsigned long long v = std::stoull(s, &idx, 10);
        if (idx != s.size()) return false;
        value = static_cast<std::uint64_t>(v);
        return true;
    } catch (...) {
        return false;
    }
}

static bool isAllZero(const Page& p) {
    return std::all_of(p.begin(), p.end(),
                       [](std::uint8_t b) { return b == 0; });
}

static void printFileInfo(DataFile& f) {
    banner();
    std::cout
        << "File       : " << f.path() << '\n'
        << "Size       : " << f.size() << " bytes (" << humanBytes(f.size()) << ")\n"
        << "Page size  : " << PAGE_SIZE << " bytes\n"
        << "Full pages : " << f.fullPages() << '\n'
        << "Remainder  : " << f.remainder() << " bytes\n";

    if (f.remainder() != 0) {
        std::cout
            << "WARNING    : file size is not an exact multiple of 8192 bytes.\n";
    }
}

static void printHeader(const PageHeader& h, std::uint64_t physicalPage) {
    std::cout
        << "Physical page : " << physicalPage << '\n'
        << "Header version: " << static_cast<unsigned>(h.headerVersion) << '\n'
        << "Type          : " << static_cast<unsigned>(h.type)
        << " (" << pageTypeName(h.type) << ")\n"
        << "Type flags    : 0x" << std::hex << std::setw(2)
        << std::setfill('0') << static_cast<unsigned>(h.typeFlagBits)
        << std::dec << std::setfill(' ') << '\n'
        << "Level         : " << static_cast<unsigned>(h.level) << '\n'
        << "Flag bits     : 0x" << std::hex << std::setw(4)
        << std::setfill('0') << h.flagBits
        << std::dec << std::setfill(' ') << '\n'
        << "Index ID      : " << h.indexId << '\n'
        << "Page ID       : (" << h.fileId << ':' << h.pageId << ")\n"
        << "Prev page     : (" << h.prevFileId << ':' << h.prevPageId << ")\n"
        << "Next page     : (" << h.nextFileId << ':' << h.nextPageId << ")\n"
        << "Object/Alloc  : " << h.objId << '\n'
        << "pminlen       : " << h.pminlen << '\n'
        << "Slot count    : " << h.slotCnt << '\n'
        << "Free count    : " << h.freeCnt << '\n'
        << "Free data off.: " << h.freeData << '\n'
        << "Reserved count: " << h.reservedCnt << '\n'
        << "Basic sanity  : " << (h.saneBasic ? "OK" : "SUSPICIOUS") << '\n'
        << "Page-id match : " << (h.physicalPageMatches ? "YES" : "NO") << '\n';
}

static void hexDump(const Page& p, std::size_t begin, std::size_t end) {
    end = std::min<std::size_t>(end, p.size());

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
            unsigned char c = p[i + j];
            std::cout << (std::isprint(c) ? static_cast<char>(c) : '.');
        }

        std::cout << '\n';
    }

    std::cout << std::dec << std::setfill(' ');
}

static int cmdPage(DataFile& f, std::uint64_t pageNo) {
    Page p{};
    if (!f.readPage(pageNo, p)) {
        std::cerr << "ERROR: unable to read physical page " << pageNo << ".\n";
        return 3;
    }

    banner();
    auto h = decodeHeader(p, pageNo);
    printHeader(h, pageNo);

    std::cout << "\nFirst 96 bytes (page header):\n";
    hexDump(p, 0, HEADER_SIZE);
    return 0;
}

static std::vector<std::uint16_t>
readSlots(const Page& p, const PageHeader& h) {
    std::vector<std::uint16_t> slots;

    const std::uint64_t slotBytes =
        static_cast<std::uint64_t>(h.slotCnt) * 2ULL;

    if (slotBytes > PAGE_SIZE - HEADER_SIZE) return slots;

    slots.reserve(h.slotCnt);

    for (std::uint16_t i = 0; i < h.slotCnt; ++i) {
        // Slot 0 occupies the final 2 bytes, slot 1 the preceding 2, etc.
        const std::size_t pos =
            static_cast<std::size_t>(PAGE_SIZE - (static_cast<std::uint64_t>(i) + 1ULL) * 2ULL);

        slots.push_back(u16le(&p[pos]));
    }

    return slots;
}

static int cmdSlots(DataFile& f, std::uint64_t pageNo) {
    Page p{};
    if (!f.readPage(pageNo, p)) {
        std::cerr << "ERROR: unable to read physical page " << pageNo << ".\n";
        return 3;
    }

    banner();
    const auto h = decodeHeader(p, pageNo);
    printHeader(h, pageNo);

    if (!h.saneBasic) {
        std::cerr << "\nERROR: header sanity check failed; refusing slot parsing.\n";
        return 4;
    }

    const auto slots = readSlots(p, h);

    std::cout << "\nSlot array:\n";
    std::cout << "Slot     Offset     Status\n";
    std::cout << "----     ------     ------\n";

    std::size_t invalid = 0;

    for (std::size_t i = 0; i < slots.size(); ++i) {
        const auto off = slots[i];
        const bool valid = off >= HEADER_SIZE && off < PAGE_SIZE;
        if (!valid) ++invalid;

        std::cout << std::setw(4) << i
                  << "     " << std::setw(6) << off
                  << "     " << (valid ? "OK" : "INVALID") << '\n';
    }

    std::cout
        << "\nSlots total : " << slots.size() << '\n'
        << "Invalid     : " << invalid << '\n';

    return invalid == 0 ? 0 : 5;
}

static int cmdScan(DataFile& f) {
    banner();

    const auto pages = f.fullPages();

    std::cout
        << "File        : " << f.path() << '\n'
        << "Size        : " << humanBytes(f.size()) << '\n'
        << "Pages       : " << pages << '\n'
        << "Mode        : sequential / read-only\n\n";

    if (pages == 0) {
        std::cerr << "ERROR: file has no complete 8192-byte page.\n";
        return 3;
    }

    std::map<unsigned, std::uint64_t> byType;
    std::uint64_t zeroPages = 0;
    std::uint64_t saneHeaders = 0;
    std::uint64_t suspiciousHeaders = 0;
    std::uint64_t pageIdMatches = 0;
    std::uint64_t pageIdMismatches = 0;
    std::uint64_t readable = 0;

    Page p{};

    const std::uint64_t progressStep =
        std::max<std::uint64_t>(1, pages / 20);

    for (std::uint64_t i = 0; i < pages; ++i) {
        if (!f.readPage(i, p)) {
            std::cerr << "\nERROR: read failed at physical page " << i << ".\n";
            return 4;
        }

        ++readable;

        if (isAllZero(p)) {
            ++zeroPages;
        } else {
            const auto h = decodeHeader(p, i);
            ++byType[static_cast<unsigned>(h.type)];

            if (h.saneBasic) ++saneHeaders;
            else             ++suspiciousHeaders;

            if (h.physicalPageMatches) ++pageIdMatches;
            else                       ++pageIdMismatches;
        }

        if ((i + 1) % progressStep == 0 || (i + 1) == pages) {
            const double pct =
                (100.0 * static_cast<double>(i + 1)) /
                static_cast<double>(pages);

            std::cout << '\r'
                      << "Scanning    : "
                      << std::fixed << std::setprecision(1)
                      << std::setw(5) << pct << "%  "
                      << (i + 1) << '/' << pages
                      << std::flush;
        }
    }

    std::cout << "\n\nPage types:\n";

    for (const auto& kv : byType) {
        std::cout << "  "
                  << std::setw(3) << kv.first
                  << "  "
                  << std::setw(14) << std::left
                  << pageTypeName(static_cast<std::uint8_t>(kv.first))
                  << std::right
                  << " : " << kv.second << '\n';
    }

    std::cout
        << "\nSummary:\n"
        << "  Readable pages      : " << readable << '\n'
        << "  All-zero pages      : " << zeroPages << '\n'
        << "  Sane headers        : " << saneHeaders << '\n'
        << "  Suspicious headers  : " << suspiciousHeaders << '\n'
        << "  Page-id matches     : " << pageIdMatches << '\n'
        << "  Page-id mismatches  : " << pageIdMismatches << '\n';

    if (f.remainder() != 0) {
        std::cout
            << "  Trailing bytes      : " << f.remainder()
            << "  [WARNING: non-page remainder]\n";
    }

    return 0;
}

} // namespace wxsql

int main(int argc, char* argv[]) {
    using namespace wxsql;

    if (argc < 3) {
        usage(argv[0]);
        return 1;
    }

    const std::string command = argv[1];
    const std::string path    = argv[2];

    DataFile file(path);

    if (!file.ok()) {
        std::cerr << "ERROR: cannot open file: " << path << '\n';
        return 2;
    }

    if (command == "info") {
        printFileInfo(file);
        return 0;
    }

    if (command == "scan") {
        return cmdScan(file);
    }

    if (command == "page" || command == "slots") {
        if (argc < 4) {
            std::cerr << "ERROR: physical page number is required.\n";
            return 1;
        }

        std::uint64_t pageNo = 0;
        if (!parseU64(argv[3], pageNo)) {
            std::cerr << "ERROR: invalid page number: " << argv[3] << '\n';
            return 1;
        }

        if (pageNo >= file.fullPages()) {
            std::cerr
                << "ERROR: page " << pageNo << " is outside the file. "
                << "Valid range: 0.."
                << (file.fullPages() ? file.fullPages() - 1 : 0)
                << '\n';
            return 1;
        }

        if (command == "page")  return cmdPage(file, pageNo);
        if (command == "slots") return cmdSlots(file, pageNo);
    }

    std::cerr << "ERROR: unknown command: " << command << "\n\n";
    usage(argv[0]);
    return 1;
}
