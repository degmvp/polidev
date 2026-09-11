// ============================================================================
// POLYDEV | WX-TOOLS
// wxt-cpp-007-drive-space-analyzer.cpp
//
// Drive Space Analyzer - C++17 CLI
// Diagnostica o consumo de espaco de um drive/diretorio sem apagar nada.
//
// Comandos:
//   summary --drive="C:\"
//   scan    --drive="C:\" --top=20
//   largest --drive="C:\" --min-size=500MB --top=30
//
// Compilacao MSVC 2022:
//   cl /std:c++17 /EHsc /O2 wxt-cpp-007-drive-space-analyzer.cpp /Fe:drive-analyzer.exe
//
// Compilacao GCC:
//   g++ -std=c++17 -O2 wxt-cpp-007-drive-space-analyzer.cpp -o drive-analyzer
// ============================================================================

#include <algorithm>
#include <chrono>
#include <cctype>
#include <cstdint>
#include <filesystem>
#include <iomanip>
#include <iostream>
#include <map>
#include <sstream>
#include <string>
#include <system_error>
#include <unordered_map>
#include <utility>
#include <vector>

#ifdef _WIN32
    #define NOMINMAX
    #include <windows.h>
#endif

namespace fs = std::filesystem;

struct FileInfo {
    fs::path path;
    std::uintmax_t size = 0;
};

struct DirInfo {
    fs::path path;
    std::uintmax_t size = 0;
    std::uint64_t files = 0;
};

struct ScanStats {
    std::uint64_t files = 0;
    std::uint64_t directories = 0;
    std::uint64_t skipped = 0;
    std::uint64_t errors = 0;
    std::uintmax_t bytesSeen = 0;

    std::vector<FileInfo> largestFiles;
    std::unordered_map<std::string, std::uintmax_t> bytesByExtension;
    std::unordered_map<std::string, std::uint64_t> filesByExtension;
};

static std::string lowerCopy(std::string s) {
    std::transform(s.begin(), s.end(), s.begin(),
        [](unsigned char c) { return static_cast<char>(std::tolower(c)); });
    return s;
}

static std::string pathUtf8(const fs::path& p) {
#ifdef _WIN32
    const std::wstring ws = p.wstring();
    if (ws.empty()) return {};

    int sizeNeeded = WideCharToMultiByte(
        CP_UTF8, 0, ws.c_str(), static_cast<int>(ws.size()),
        nullptr, 0, nullptr, nullptr
    );

    if (sizeNeeded <= 0) return p.string();

    std::string out(static_cast<std::size_t>(sizeNeeded), '\0');
    WideCharToMultiByte(
        CP_UTF8, 0, ws.c_str(), static_cast<int>(ws.size()),
        out.data(), sizeNeeded, nullptr, nullptr
    );
    return out;
#else
    return p.string();
#endif
}

static std::string humanBytes(std::uintmax_t bytes) {
    static const char* units[] = {"B", "KB", "MB", "GB", "TB", "PB"};
    double value = static_cast<double>(bytes);
    std::size_t unit = 0;

    while (value >= 1024.0 && unit < 5) {
        value /= 1024.0;
        ++unit;
    }

    std::ostringstream oss;
    if (unit == 0) {
        oss << static_cast<std::uintmax_t>(value) << ' ' << units[unit];
    } else {
        oss << std::fixed << std::setprecision(value < 10.0 ? 2 : 1)
            << value << ' ' << units[unit];
    }
    return oss.str();
}

static bool parseSize(std::string text, std::uintmax_t& bytes) {
    text.erase(
        std::remove_if(text.begin(), text.end(),
            [](unsigned char c) { return std::isspace(c) != 0; }),
        text.end()
    );

    if (text.empty()) return false;

    std::string upper;
    upper.reserve(text.size());
    for (char c : text) {
        upper.push_back(static_cast<char>(std::toupper(static_cast<unsigned char>(c))));
    }

    std::uintmax_t multiplier = 1;

    auto stripSuffix = [&](const std::string& suffix, std::uintmax_t mult) -> bool {
        if (upper.size() >= suffix.size() &&
            upper.compare(upper.size() - suffix.size(), suffix.size(), suffix) == 0) {
            upper.erase(upper.size() - suffix.size());
            multiplier = mult;
            return true;
        }
        return false;
    };

    if      (stripSuffix("TB", 1024ULL * 1024ULL * 1024ULL * 1024ULL)) {}
    else if (stripSuffix("GB", 1024ULL * 1024ULL * 1024ULL)) {}
    else if (stripSuffix("MB", 1024ULL * 1024ULL)) {}
    else if (stripSuffix("KB", 1024ULL)) {}
    else if (stripSuffix("B", 1ULL)) {}

    try {
        double value = std::stod(upper);
        if (value < 0.0) return false;
        bytes = static_cast<std::uintmax_t>(value * static_cast<double>(multiplier));
        return true;
    } catch (...) {
        return false;
    }
}

static void keepTopFile(std::vector<FileInfo>& top,
                        const FileInfo& candidate,
                        std::size_t limit) {
    if (limit == 0) return;

    if (top.size() < limit) {
        top.push_back(candidate);
        if (top.size() == limit) {
            std::sort(top.begin(), top.end(),
                [](const FileInfo& a, const FileInfo& b) {
                    return a.size > b.size;
                });
        }
        return;
    }

    if (candidate.size <= top.back().size) return;

    top.back() = candidate;
    for (std::size_t i = top.size() - 1; i > 0; --i) {
        if (top[i].size <= top[i - 1].size) break;
        std::swap(top[i], top[i - 1]);
    }
}

static std::string extensionOf(const fs::path& p) {
    std::string ext = lowerCopy(p.extension().string());
    if (ext.empty()) return "[sem extensao]";
    return ext;
}

static bool isSpecialEntry(const fs::directory_entry& entry) {
    std::error_code ec;
    fs::file_status st = entry.symlink_status(ec);
    if (ec) return false;

    if (fs::is_symlink(st)) return true;

#ifdef _WIN32
    // Evita seguir junctions/reparse points que podem duplicar arvores ou criar ciclos.
    DWORD attrs = GetFileAttributesW(entry.path().c_str());
    if (attrs != INVALID_FILE_ATTRIBUTES &&
        (attrs & FILE_ATTRIBUTE_REPARSE_POINT)) {
        return true;
    }
#endif

    return false;
}

static std::uintmax_t scanTree(const fs::path& root,
                               ScanStats& stats,
                               std::size_t topLimit,
                               std::uintmax_t minLargestSize,
                               bool collectExtensions,
                               bool collectLargest) {
    std::uintmax_t total = 0;

    std::error_code ec;
    fs::recursive_directory_iterator it(
        root,
        fs::directory_options::skip_permission_denied,
        ec
    );

    if (ec) {
        ++stats.errors;
        return 0;
    }

    fs::recursive_directory_iterator end;

    while (it != end) {
        const fs::directory_entry entry = *it;

        if (isSpecialEntry(entry)) {
            if (entry.is_directory(ec)) {
                it.disable_recursion_pending();
            }
            ++stats.skipped;
            ec.clear();
            it.increment(ec);
            if (ec) {
                ++stats.errors;
                ec.clear();
            }
            continue;
        }

        ec.clear();
        if (entry.is_directory(ec)) {
            ++stats.directories;
        } else if (entry.is_regular_file(ec)) {
            ec.clear();
            const auto sz = entry.file_size(ec);
            if (!ec) {
                ++stats.files;
                stats.bytesSeen += sz;
                total += sz;

                if (collectLargest && sz >= minLargestSize) {
                    keepTopFile(stats.largestFiles, {entry.path(), sz}, topLimit);
                }

                if (collectExtensions) {
                    const std::string ext = extensionOf(entry.path());
                    stats.bytesByExtension[ext] += sz;
                    stats.filesByExtension[ext] += 1;
                }
            } else {
                ++stats.errors;
                ec.clear();
            }
        }

        it.increment(ec);
        if (ec) {
            ++stats.errors;
            ec.clear();
        }
    }

    return total;
}

static std::vector<DirInfo> immediateDirectoryUsage(const fs::path& root,
                                                    std::uint64_t& totalErrors,
                                                    std::uint64_t& totalSkipped) {
    std::vector<DirInfo> result;

    std::error_code ec;
    fs::directory_iterator it(
        root,
        fs::directory_options::skip_permission_denied,
        ec
    );

    if (ec) {
        ++totalErrors;
        return result;
    }

    fs::directory_iterator end;
    while (it != end) {
        const fs::directory_entry entry = *it;

        ec.clear();
        if (entry.is_directory(ec)) {
            if (isSpecialEntry(entry)) {
                ++totalSkipped;
            } else {
                ScanStats local;
                std::uintmax_t size = scanTree(
                    entry.path(),
                    local,
                    0,
                    0,
                    false,
                    false
                );

                result.push_back({
                    entry.path(),
                    size,
                    local.files
                });

                totalErrors += local.errors;
                totalSkipped += local.skipped;
            }
        }

        it.increment(ec);
        if (ec) {
            ++totalErrors;
            ec.clear();
        }
    }

    std::sort(result.begin(), result.end(),
        [](const DirInfo& a, const DirInfo& b) {
            return a.size > b.size;
        });

    return result;
}

static bool printDriveSummary(const fs::path& root) {
    std::error_code ec;
    const fs::space_info info = fs::space(root, ec);

    if (ec) {
        std::cerr << "ERRO: nao foi possivel obter informacoes de espaco de: "
                  << pathUtf8(root) << "\n";
        std::cerr << "Detalhe: " << ec.message() << "\n";
        return false;
    }

    const std::uintmax_t used =
        info.capacity >= info.available ? info.capacity - info.available : 0;

    const double usedPct =
        info.capacity == 0 ? 0.0 :
        (100.0 * static_cast<double>(used) / static_cast<double>(info.capacity));

    std::cout << "\n============================================================\n";
    std::cout << " POLYDEV | WX-TOOLS - DRIVE SPACE ANALYZER\n";
    std::cout << "============================================================\n";
    std::cout << "Alvo       : " << pathUtf8(root) << "\n";
    std::cout << "Capacidade : " << humanBytes(info.capacity) << "\n";
    std::cout << "Usado      : " << humanBytes(used)
              << " (" << std::fixed << std::setprecision(1) << usedPct << "%)\n";
    std::cout << "Livre      : " << humanBytes(info.available) << "\n";
    std::cout << "============================================================\n";

    return true;
}

static void printLargestFiles(const std::vector<FileInfo>& files) {
    std::cout << "\nTOP ARQUIVOS\n";
    std::cout << "------------------------------------------------------------\n";

    if (files.empty()) {
        std::cout << "Nenhum arquivo encontrado para o filtro informado.\n";
        return;
    }

    for (std::size_t i = 0; i < files.size(); ++i) {
        std::cout << std::setw(3) << (i + 1) << ". "
                  << std::setw(11) << humanBytes(files[i].size)
                  << "  " << pathUtf8(files[i].path) << "\n";
    }
}

static void printTopExtensions(const ScanStats& stats, std::size_t top) {
    std::vector<std::pair<std::string, std::uintmax_t>> items;
    items.reserve(stats.bytesByExtension.size());

    for (const auto& kv : stats.bytesByExtension) {
        items.push_back(kv);
    }

    std::sort(items.begin(), items.end(),
        [](const auto& a, const auto& b) {
            return a.second > b.second;
        });

    if (items.size() > top) {
        items.resize(top);
    }

    std::cout << "\nTOP EXTENSOES POR ESPACO\n";
    std::cout << "------------------------------------------------------------\n";

    if (items.empty()) {
        std::cout << "Nenhuma extensao encontrada.\n";
        return;
    }

    std::size_t pos = 1;
    for (const auto& kv : items) {
        auto countIt = stats.filesByExtension.find(kv.first);
        const std::uint64_t count =
            countIt == stats.filesByExtension.end() ? 0 : countIt->second;

        std::cout << std::setw(3) << pos++ << ". "
                  << std::left << std::setw(18) << kv.first
                  << std::right << std::setw(12) << humanBytes(kv.second)
                  << "  " << count << " arquivo(s)\n";
    }
}

static void printTopDirectories(const std::vector<DirInfo>& dirs, std::size_t top) {
    std::cout << "\nTOP DIRETORIOS\n";
    std::cout << "------------------------------------------------------------\n";

    if (dirs.empty()) {
        std::cout << "Nenhum diretorio encontrado ou acesso negado.\n";
        return;
    }

    const std::size_t limit = std::min(top, dirs.size());

    for (std::size_t i = 0; i < limit; ++i) {
        std::cout << std::setw(3) << (i + 1) << ". "
                  << std::setw(11) << humanBytes(dirs[i].size)
                  << "  " << pathUtf8(dirs[i].path)
                  << "  [" << dirs[i].files << " arquivo(s)]\n";
    }
}

static void printHelp(const char* exe) {
    std::cout
        << "POLYDEV | WX-TOOLS - Drive Space Analyzer\n\n"
        << "Uso:\n"
        << "  " << exe << " summary --drive=\"C:\\\\\"\n"
        << "  " << exe << " scan --drive=\"C:\\\\\" --top=20\n"
        << "  " << exe << " largest --drive=\"C:\\\\\" --min-size=500MB --top=30\n\n"
        << "Opcoes:\n"
        << "  --drive=PATH       Drive ou diretorio raiz a analisar\n"
        << "  --top=N            Quantidade de resultados exibidos (padrao: 20)\n"
        << "  --min-size=TAM     Filtro para 'largest'. Ex.: 100MB, 1GB\n"
        << "  --help             Mostra esta ajuda\n\n"
        << "Observacoes:\n"
        << "  * Esta versao NAO remove, move nem altera arquivos.\n"
        << "  * Junctions/symlinks/reparse points sao ignorados.\n"
        << "  * Acesso negado e outros erros sao contabilizados sem abortar o scan.\n";
}

static bool startsWith(const std::string& s, const std::string& prefix) {
    return s.rfind(prefix, 0) == 0;
}

int main(int argc, char* argv[]) {
#ifdef _WIN32
    SetConsoleOutputCP(CP_UTF8);
    SetConsoleCP(CP_UTF8);
#endif

    if (argc < 2) {
        printHelp(argv[0]);
        return 1;
    }

    const std::string command = lowerCopy(argv[1]);

    if (command == "--help" || command == "-h" || command == "help") {
        printHelp(argv[0]);
        return 0;
    }

    std::string driveText;
    std::size_t top = 20;
    std::uintmax_t minSize = 100ULL * 1024ULL * 1024ULL; // 100 MB

    for (int i = 2; i < argc; ++i) {
        std::string arg = argv[i];

        if (startsWith(arg, "--drive=")) {
            driveText = arg.substr(8);
        } else if (startsWith(arg, "--top=")) {
            try {
                const unsigned long parsed = std::stoul(arg.substr(6));
                if (parsed == 0 || parsed > 10000) {
                    std::cerr << "ERRO: --top deve estar entre 1 e 10000.\n";
                    return 1;
                }
                top = static_cast<std::size_t>(parsed);
            } catch (...) {
                std::cerr << "ERRO: valor invalido em --top.\n";
                return 1;
            }
        } else if (startsWith(arg, "--min-size=")) {
            if (!parseSize(arg.substr(11), minSize)) {
                std::cerr << "ERRO: valor invalido em --min-size.\n";
                return 1;
            }
        } else if (arg == "--help" || arg == "-h") {
            printHelp(argv[0]);
            return 0;
        } else {
            std::cerr << "ERRO: opcao desconhecida: " << arg << "\n";
            return 1;
        }
    }

    if (driveText.empty()) {
#ifdef _WIN32
        driveText = "C:\\";
#else
        driveText = "/";
#endif
    }

    fs::path root = fs::path(driveText);

    std::error_code ec;
    if (!fs::exists(root, ec) || ec) {
        std::cerr << "ERRO: caminho inexistente ou inacessivel: "
                  << pathUtf8(root) << "\n";
        return 1;
    }

    if (!fs::is_directory(root, ec) || ec) {
        std::cerr << "ERRO: o alvo precisa ser um drive ou diretorio.\n";
        return 1;
    }

    if (command == "summary") {
        return printDriveSummary(root) ? 0 : 1;
    }

    if (command == "largest") {
        if (!printDriveSummary(root)) {
            return 1;
        }

        const auto start = std::chrono::steady_clock::now();

        ScanStats stats;
        scanTree(root, stats, top, minSize, false, true);

        std::sort(stats.largestFiles.begin(), stats.largestFiles.end(),
            [](const FileInfo& a, const FileInfo& b) {
                return a.size > b.size;
            });

        printLargestFiles(stats.largestFiles);

        const auto end = std::chrono::steady_clock::now();
        const auto secs =
            std::chrono::duration_cast<std::chrono::seconds>(end - start).count();

        std::cout << "\nRESUMO DO SCAN\n";
        std::cout << "------------------------------------------------------------\n";
        std::cout << "Arquivos analisados : " << stats.files << "\n";
        std::cout << "Diretorios          : " << stats.directories << "\n";
        std::cout << "Itens ignorados     : " << stats.skipped << "\n";
        std::cout << "Erros/acesso negado : " << stats.errors << "\n";
        std::cout << "Tempo                : " << secs << " s\n";

        return 0;
    }

    if (command == "scan") {
        if (!printDriveSummary(root)) {
            return 1;
        }

        const auto start = std::chrono::steady_clock::now();

        std::cout << "\nAnalisando o drive. Nenhum arquivo sera alterado...\n";

        ScanStats stats;
        scanTree(root, stats, top, 0, true, true);

        std::sort(stats.largestFiles.begin(), stats.largestFiles.end(),
            [](const FileInfo& a, const FileInfo& b) {
                return a.size > b.size;
            });

        std::uint64_t dirErrors = 0;
        std::uint64_t dirSkipped = 0;

        std::cout << "\nCalculando consumo dos diretorios principais...\n";
        auto dirs = immediateDirectoryUsage(root, dirErrors, dirSkipped);

        printTopDirectories(dirs, top);
        printLargestFiles(stats.largestFiles);
        printTopExtensions(stats, top);

        const auto end = std::chrono::steady_clock::now();
        const auto secs =
            std::chrono::duration_cast<std::chrono::seconds>(end - start).count();

        std::cout << "\nRESUMO DO SCAN\n";
        std::cout << "------------------------------------------------------------\n";
        std::cout << "Arquivos analisados : " << stats.files << "\n";
        std::cout << "Diretorios          : " << stats.directories << "\n";
        std::cout << "Bytes contabilizados: " << humanBytes(stats.bytesSeen) << "\n";
        std::cout << "Itens ignorados     : " << (stats.skipped + dirSkipped) << "\n";
        std::cout << "Erros/acesso negado : " << (stats.errors + dirErrors) << "\n";
        std::cout << "Tempo                : " << secs << " s\n";

        std::cout << "\nNOTA: o valor 'Bytes contabilizados' representa arquivos que puderam\n"
                     "ser lidos durante o scan e pode diferir do espaco usado informado\n"
                     "pelo sistema operacional.\n";

        return 0;
    }

    std::cerr << "ERRO: comando desconhecido: " << command << "\n\n";
    printHelp(argv[0]);
    return 1;
}
