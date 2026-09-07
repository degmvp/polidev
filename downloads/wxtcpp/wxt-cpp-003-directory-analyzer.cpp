/*
===============================================================================
POLYDEV | WX-TOOLS
wxt-cpp-003-directory-analyzer.cpp

Directory Analyzer
-------------------------------------------------------------------------------
Ferramenta CLI em C++ para análise segura de diretórios.

Funções:
  - contabiliza arquivos e diretórios;
  - calcula espaço total ocupado;
  - identifica arquivos vazios;
  - agrupa arquivos por extensão;
  - lista os maiores arquivos;
  - identifica diretórios que mais ocupam espaço;
  - contabiliza erros de leitura/permissão;
  - ignora links simbólicos para evitar ciclos;
  - não altera, move ou remove nenhum arquivo.

Modo:
  READ-ONLY / SAFE MODE

Compilação:
  g++ -std=c++17 -O2 -Wall -Wextra \
      wxt-cpp-003-directory-analyzer.cpp \
      -o wxt-cpp-003-directory-analyzer

Uso:
  ./wxt-cpp-003-directory-analyzer <diretorio>

Exemplo:
  ./wxt-cpp-003-directory-analyzer /home/degsu/polydev_lab

Opcional:
  ./wxt-cpp-003-directory-analyzer <diretorio> --top 15

Autor:
  POLYDEV | WX-TOOLS
===============================================================================
*/

#include <algorithm>
#include <cctype>
#include <cstdint>
#include <filesystem>
#include <iomanip>
#include <iostream>
#include <map>
#include <string>
#include <system_error>
#include <unordered_map>
#include <utility>
#include <vector>

namespace fs = std::filesystem;

// -----------------------------------------------------------------------------
// Estruturas
// -----------------------------------------------------------------------------

struct FileInfo {
    fs::path path;
    std::uintmax_t size = 0;
};

struct ExtensionInfo {
    std::uint64_t files = 0;
    std::uintmax_t bytes = 0;
};

struct AnalysisResult {
    std::uint64_t files = 0;
    std::uint64_t directories = 0;
    std::uint64_t emptyFiles = 0;
    std::uint64_t symlinksSkipped = 0;
    std::uint64_t errors = 0;

    std::uintmax_t totalBytes = 0;

    std::vector<FileInfo> largestFiles;

    std::map<std::string, ExtensionInfo> extensions;

    std::unordered_map<std::string, std::uintmax_t> directoryBytes;
};

// -----------------------------------------------------------------------------
// Utilidades
// -----------------------------------------------------------------------------

static std::string toLower(std::string text) {
    std::transform(
        text.begin(),
        text.end(),
        text.begin(),
        [](unsigned char c) {
            return static_cast<char>(std::tolower(c));
        }
    );

    return text;
}

static std::string humanSize(std::uintmax_t bytes) {
    static const char* units[] = {
        "B",
        "KB",
        "MB",
        "GB",
        "TB",
        "PB"
    };

    double value = static_cast<double>(bytes);
    std::size_t unit = 0;

    while (value >= 1024.0 && unit < 5) {
        value /= 1024.0;
        ++unit;
    }

    std::ostringstream out;

    if (unit == 0) {
        out << static_cast<std::uintmax_t>(value)
            << ' '
            << units[unit];
    } else {
        out << std::fixed
            << std::setprecision(2)
            << value
            << ' '
            << units[unit];
    }

    return out.str();
}

static std::string extensionOf(const fs::path& path) {
    std::string ext = path.extension().string();

    if (ext.empty()) {
        return "[sem extensão]";
    }

    return toLower(ext);
}

static std::string relativeDisplay(
    const fs::path& path,
    const fs::path& root
) {
    std::error_code ec;

    fs::path rel = fs::relative(path, root, ec);

    if (!ec && !rel.empty()) {
        return rel.string();
    }

    return path.string();
}

static void printSeparator() {
    std::cout
        << "------------------------------------------------------------\n";
}

// -----------------------------------------------------------------------------
// Acumula tamanho em todos os diretórios ancestrais
// -----------------------------------------------------------------------------

static void accumulateDirectorySize(
    AnalysisResult& result,
    const fs::path& filePath,
    const fs::path& root,
    std::uintmax_t size
) {
    fs::path current = filePath.parent_path();

    while (!current.empty()) {
        result.directoryBytes[current.string()] += size;

        if (current == root) {
            break;
        }

        fs::path parent = current.parent_path();

        if (parent == current) {
            break;
        }

        current = parent;
    }
}

// -----------------------------------------------------------------------------
// Análise
// -----------------------------------------------------------------------------

static AnalysisResult analyzeDirectory(
    const fs::path& root
) {
    AnalysisResult result;

    std::error_code ec;

    fs::directory_options options =
        fs::directory_options::skip_permission_denied;

    fs::recursive_directory_iterator it(
        root,
        options,
        ec
    );

    fs::recursive_directory_iterator end;

    if (ec) {
        ++result.errors;
        return result;
    }

    while (it != end) {
        const fs::directory_entry& entry = *it;

        std::error_code typeError;

        bool isSymlink = entry.is_symlink(typeError);

        if (typeError) {
            ++result.errors;
            it.increment(ec);

            if (ec) {
                ++result.errors;
                ec.clear();
            }

            continue;
        }

        if (isSymlink) {
            ++result.symlinksSkipped;

            std::error_code dirError;

            if (entry.is_directory(dirError)) {
                it.disable_recursion_pending();
            }

            it.increment(ec);

            if (ec) {
                ++result.errors;
                ec.clear();
            }

            continue;
        }

        std::error_code statusError;

        if (entry.is_directory(statusError)) {
            ++result.directories;

            result.directoryBytes.try_emplace(
                entry.path().string(),
                0
            );
        }
        else if (!statusError &&
                 entry.is_regular_file(statusError)) {

            ++result.files;

            std::error_code sizeError;

            std::uintmax_t fileSize =
                entry.file_size(sizeError);

            if (sizeError) {
                ++result.errors;
            }
            else {
                result.totalBytes += fileSize;

                if (fileSize == 0) {
                    ++result.emptyFiles;
                }

                result.largestFiles.push_back({
                    entry.path(),
                    fileSize
                });

                std::string ext =
                    extensionOf(entry.path());

                auto& extInfo =
                    result.extensions[ext];

                ++extInfo.files;
                extInfo.bytes += fileSize;

                accumulateDirectorySize(
                    result,
                    entry.path(),
                    root,
                    fileSize
                );
            }
        }
        else if (statusError) {
            ++result.errors;
        }

        it.increment(ec);

        if (ec) {
            ++result.errors;
            ec.clear();
        }
    }

    result.directoryBytes.try_emplace(
        root.string(),
        result.totalBytes
    );

    return result;
}

// -----------------------------------------------------------------------------
// Relatórios
// -----------------------------------------------------------------------------

static void printSummary(
    const AnalysisResult& result,
    const fs::path& root
) {
    std::cout << "\n";
    std::cout << "POLYDEV | WX-TOOLS\n";
    std::cout << "DIRECTORY ANALYZER\n";

    printSeparator();

    std::cout
        << "Diretório analisado : "
        << root.string()
        << '\n';

    std::cout
        << "Arquivos            : "
        << result.files
        << '\n';

    std::cout
        << "Diretórios          : "
        << result.directories
        << '\n';

    std::cout
        << "Tamanho total       : "
        << humanSize(result.totalBytes)
        << '\n';

    std::cout
        << "Arquivos vazios     : "
        << result.emptyFiles
        << '\n';

    std::cout
        << "Symlinks ignorados  : "
        << result.symlinksSkipped
        << '\n';

    std::cout
        << "Erros de leitura    : "
        << result.errors
        << '\n';

    printSeparator();
}

static void printLargestFiles(
    AnalysisResult result,
    const fs::path& root,
    std::size_t topCount
) {
    std::sort(
        result.largestFiles.begin(),
        result.largestFiles.end(),
        [](const FileInfo& a, const FileInfo& b) {
            return a.size > b.size;
        }
    );

    std::cout << "\nMAIORES ARQUIVOS\n";
    printSeparator();

    if (result.largestFiles.empty()) {
        std::cout << "Nenhum arquivo encontrado.\n";
        return;
    }

    std::size_t limit =
        std::min(
            topCount,
            result.largestFiles.size()
        );

    for (std::size_t i = 0; i < limit; ++i) {
        const auto& file =
            result.largestFiles[i];

        std::cout
            << std::setw(3)
            << (i + 1)
            << ". "
            << std::setw(12)
            << humanSize(file.size)
            << "  "
            << relativeDisplay(
                   file.path,
                   root
               )
            << '\n';
    }
}

static void printExtensions(
    const AnalysisResult& result
) {
    struct Row {
        std::string extension;
        std::uint64_t files = 0;
        std::uintmax_t bytes = 0;
    };

    std::vector<Row> rows;

    rows.reserve(result.extensions.size());

    for (const auto& [extension, info] :
         result.extensions) {

        rows.push_back({
            extension,
            info.files,
            info.bytes
        });
    }

    std::sort(
        rows.begin(),
        rows.end(),
        [](const Row& a, const Row& b) {
            if (a.bytes != b.bytes) {
                return a.bytes > b.bytes;
            }

            return a.files > b.files;
        }
    );

    std::cout << "\nDISTRIBUIÇÃO POR EXTENSÃO\n";
    printSeparator();

    if (rows.empty()) {
        std::cout << "Nenhuma extensão encontrada.\n";
        return;
    }

    std::cout
        << std::left
        << std::setw(20)
        << "Extensão"
        << std::right
        << std::setw(12)
        << "Arquivos"
        << std::setw(16)
        << "Espaço"
        << '\n';

    printSeparator();

    for (const auto& row : rows) {
        std::cout
            << std::left
            << std::setw(20)
            << row.extension
            << std::right
            << std::setw(12)
            << row.files
            << std::setw(16)
            << humanSize(row.bytes)
            << '\n';
    }
}

static void printLargestDirectories(
    const AnalysisResult& result,
    const fs::path& root,
    std::size_t topCount
) {
    std::vector<
        std::pair<std::string, std::uintmax_t>
    > directories;

    directories.reserve(
        result.directoryBytes.size()
    );

    for (const auto& item :
         result.directoryBytes) {

        directories.push_back(item);
    }

    std::sort(
        directories.begin(),
        directories.end(),
        [](const auto& a, const auto& b) {
            return a.second > b.second;
        }
    );

    std::cout << "\nDIRETÓRIOS QUE MAIS OCUPAM ESPAÇO\n";
    printSeparator();

    if (directories.empty()) {
        std::cout << "Nenhum diretório encontrado.\n";
        return;
    }

    std::size_t shown = 0;

    for (const auto& [directory, bytes] :
         directories) {

        fs::path dirPath(directory);

        // O diretório raiz já aparece no resumo.
        if (dirPath == root) {
            continue;
        }

        ++shown;

        std::cout
            << std::setw(3)
            << shown
            << ". "
            << std::setw(12)
            << humanSize(bytes)
            << "  "
            << relativeDisplay(
                   dirPath,
                   root
               )
            << '\n';

        if (shown >= topCount) {
            break;
        }
    }

    if (shown == 0) {
        std::cout
            << "Nenhum subdiretório encontrado.\n";
    }
}

// -----------------------------------------------------------------------------
// Help
// -----------------------------------------------------------------------------

static void printHelp(
    const char* programName
) {
    std::cout
        << "\nPOLYDEV | WX-TOOLS\n"
        << "Directory Analyzer\n\n"

        << "Uso:\n"
        << "  "
        << programName
        << " <diretorio>\n\n"

        << "Opcional:\n"
        << "  "
        << programName
        << " <diretorio> --top N\n\n"

        << "Exemplos:\n"
        << "  "
        << programName
        << " /home/degsu/polydev_lab\n\n"

        << "  "
        << programName
        << " /home/degsu/polydev_lab --top 20\n\n"

        << "A ferramenta opera somente em leitura.\n"
        << "Nenhum arquivo é alterado ou removido.\n";
}

// -----------------------------------------------------------------------------
// Main
// -----------------------------------------------------------------------------

int main(int argc, char* argv[]) {
    if (argc < 2) {
        printHelp(argv[0]);
        return 1;
    }

    std::string firstArg = argv[1];

    if (
        firstArg == "--help" ||
        firstArg == "-h"
    ) {
        printHelp(argv[0]);
        return 0;
    }

    fs::path target =
        fs::path(firstArg);

    std::size_t topCount = 10;

    for (int i = 2; i < argc; ++i) {
        std::string arg = argv[i];

        if (arg == "--top") {
            if (i + 1 >= argc) {
                std::cerr
                    << "Erro: informe um número após --top.\n";

                return 1;
            }

            try {
                long long value =
                    std::stoll(argv[++i]);

                if (value <= 0) {
                    throw std::invalid_argument(
                        "valor inválido"
                    );
                }

                topCount =
                    static_cast<std::size_t>(value);
            }
            catch (...) {
                std::cerr
                    << "Erro: valor inválido para --top.\n";

                return 1;
            }
        }
        else {
            std::cerr
                << "Erro: argumento desconhecido: "
                << arg
                << '\n';

            return 1;
        }
    }

    std::error_code ec;

    fs::path root =
        fs::absolute(target, ec);

    if (ec) {
        std::cerr
            << "Erro ao resolver o caminho: "
            << target.string()
            << '\n';

        return 1;
    }

    root =
        root.lexically_normal();

    if (!fs::exists(root, ec) || ec) {
        std::cerr
            << "Erro: diretório não encontrado:\n"
            << root.string()
            << '\n';

        return 1;
    }

    if (!fs::is_directory(root, ec) || ec) {
        std::cerr
            << "Erro: o caminho informado não é um diretório:\n"
            << root.string()
            << '\n';

        return 1;
    }

    std::cout
        << "\nAnalisando diretório...\n";

    AnalysisResult result =
        analyzeDirectory(root);

    printSummary(
        result,
        root
    );

    printLargestFiles(
        result,
        root,
        topCount
    );

    printExtensions(result);

    printLargestDirectories(
        result,
        root,
        topCount
    );

    std::cout << "\n";
    printSeparator();

    std::cout
        << "SAFE MODE: nenhum arquivo foi alterado ou removido.\n";

    printSeparator();

    return 0;
}