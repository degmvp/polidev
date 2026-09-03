#include <iostream>
#include <filesystem>
#include <string>
#include <unordered_map>
#include <optional>
#include <vector>
#include <fstream>
#include <sstream>
#include <iomanip>
#include <chrono>
#include <algorithm>
#include <cctype>

namespace fs = std::filesystem;

// ============================================================
// POLYDEV - FILE ORGANIZER CLI
// C++17
//
// Organiza arquivos por extensao.
// Suporta:
//   --dry-run
//   --target
//   --rollback
//   log JSON
// ============================================================

struct Options {
    fs::path source;
    std::optional<fs::path> target;
    bool dryRun = false;
    bool rollback = false;
    std::optional<fs::path> rollbackFile;
};

struct Operation {
    fs::path original;
    fs::path destination;
    bool success = false;
    std::string error;
};

// ------------------------------------------------------------
// Converte string para minusculo
// ------------------------------------------------------------
std::string toLower(std::string value) {
    std::transform(
        value.begin(),
        value.end(),
        value.begin(),
        [](unsigned char c) {
            return static_cast<char>(std::tolower(c));
        }
    );

    return value;
}

// ------------------------------------------------------------
// Escapa strings para JSON
// ------------------------------------------------------------
std::string jsonEscape(const std::string& input) {
    std::ostringstream out;

    for (char c : input) {
        switch (c) {
            case '"':
                out << "\\\"";
                break;

            case '\\':
                out << "\\\\";
                break;

            case '\n':
                out << "\\n";
                break;

            case '\r':
                out << "\\r";
                break;

            case '\t':
                out << "\\t";
                break;

            default:
                out << c;
        }
    }

    return out.str();
}

// ------------------------------------------------------------
// Data/hora para nome de arquivo
// ------------------------------------------------------------
std::string timestamp() {
    auto now = std::chrono::system_clock::now();
    std::time_t time = std::chrono::system_clock::to_time_t(now);

    std::tm tm{};

#ifdef _WIN32
    localtime_s(&tm, &time);
#else
    localtime_r(&time, &tm);
#endif

    std::ostringstream oss;

    oss << std::put_time(&tm, "%Y%m%d_%H%M%S");

    return oss.str();
}

// ------------------------------------------------------------
// Data/hora para log
// ------------------------------------------------------------
std::string timestampReadable() {
    auto now = std::chrono::system_clock::now();
    std::time_t time = std::chrono::system_clock::to_time_t(now);

    std::tm tm{};

#ifdef _WIN32
    localtime_s(&tm, &time);
#else
    localtime_r(&time, &tm);
#endif

    std::ostringstream oss;

    oss << std::put_time(&tm, "%Y-%m-%d %H:%M:%S");

    return oss.str();
}

// ------------------------------------------------------------
// Mostra ajuda
// ------------------------------------------------------------
void showHelp(const char* program) {
    std::cout
        << "\nPOLYDEV - FILE ORGANIZER CLI\n\n"

        << "Uso:\n\n"

        << "  " << program << " <diretorio>\n"
        << "  " << program << " <diretorio> --dry-run\n"
        << "  " << program << " <diretorio> --target <diretorio>\n"
        << "  " << program << " --rollback <arquivo.json>\n\n"

        << "Exemplos:\n\n"

        << "  " << program << " /home/user/Downloads\n"
        << "  " << program << " /home/user/Downloads --dry-run\n"
        << "  " << program << " /home/user/Downloads --target /home/user/Organizado\n"
        << "  " << program << " --rollback organizer_20260901_103000.json\n\n";
}

// ------------------------------------------------------------
// Processa argumentos
// ------------------------------------------------------------
std::optional<Options> parseArguments(int argc, char* argv[]) {

    if (argc < 2) {
        return std::nullopt;
    }

    Options options;

    int i = 1;

    if (std::string(argv[i]) == "--rollback") {

        if (argc < 3) {
            std::cerr << "Erro: informe o arquivo de rollback.\n";
            return std::nullopt;
        }

        options.rollback = true;
        options.rollbackFile = fs::path(argv[i + 1]);

        return options;
    }

    options.source = fs::path(argv[i]);

    ++i;

    while (i < argc) {

        std::string arg = argv[i];

        if (arg == "--dry-run") {

            options.dryRun = true;
            ++i;
        }

        else if (arg == "--target") {

            if (i + 1 >= argc) {
                std::cerr << "Erro: --target precisa de um diretorio.\n";
                return std::nullopt;
            }

            options.target = fs::path(argv[i + 1]);

            i += 2;
        }

        else {

            std::cerr << "Opcao desconhecida: " << arg << "\n";
            return std::nullopt;
        }
    }

    return options;
}

// ------------------------------------------------------------
// Regras de classificacao
// ------------------------------------------------------------
std::unordered_map<std::string, std::string> createRules() {

    return {

        // Imagens
        {".jpg", "Imagens"},
        {".jpeg", "Imagens"},
        {".png", "Imagens"},
        {".gif", "Imagens"},
        {".bmp", "Imagens"},
        {".webp", "Imagens"},
        {".svg", "Imagens"},

        // Videos
        {".mp4", "Videos"},
        {".mkv", "Videos"},
        {".avi", "Videos"},
        {".mov", "Videos"},
        {".wmv", "Videos"},
        {".webm", "Videos"},

        // Audio
        {".mp3", "Musica"},
        {".wav", "Musica"},
        {".flac", "Musica"},
        {".aac", "Musica"},
        {".ogg", "Musica"},
        {".m4a", "Musica"},

        // Documentos
        {".pdf", "Documentos"},
        {".doc", "Documentos"},
        {".docx", "Documentos"},
        {".txt", "Documentos"},
        {".rtf", "Documentos"},
        {".odt", "Documentos"},

        // Planilhas
        {".xls", "Planilhas"},
        {".xlsx", "Planilhas"},
        {".ods", "Planilhas"},
        {".csv", "Planilhas"},

        // Apresentacoes
        {".ppt", "Apresentacoes"},
        {".pptx", "Apresentacoes"},
        {".odp", "Apresentacoes"},

        // Compactados
        {".zip", "Compactados"},
        {".rar", "Compactados"},
        {".7z", "Compactados"},
        {".tar", "Compactados"},
        {".gz", "Compactados"},
        {".bz2", "Compactados"},
        {".xz", "Compactados"},

        // Executaveis / instaladores
        {".exe", "Executaveis"},
        {".msi", "Executaveis"},
        {".deb", "Executaveis"},
        {".rpm", "Executaveis"},
        {".appimage", "Executaveis"},

        // Codigo fonte
        {".cpp", "Codigo"},
        {".c", "Codigo"},
        {".h", "Codigo"},
        {".hpp", "Codigo"},
        {".py", "Codigo"},
        {".js", "Codigo"},
        {".ts", "Codigo"},
        {".java", "Codigo"},
        {".go", "Codigo"},
        {".rs", "Codigo"},
        {".cs", "Codigo"},
        {".rb", "Codigo"},
        {".sh", "Codigo"},
        {".sql", "Codigo"},

        // Dados
        {".json", "Dados"},
        {".xml", "Dados"},
        {".yaml", "Dados"},
        {".yml", "Dados"}
    };
}

// ------------------------------------------------------------
// Resolve colisao de nomes
//
// arquivo.txt
// arquivo_1.txt
// arquivo_2.txt
// ------------------------------------------------------------
fs::path generateUniqueDestination(const fs::path& destination) {

    if (!fs::exists(destination)) {
        return destination;
    }

    fs::path parent = destination.parent_path();
    std::string stem = destination.stem().string();
    std::string extension = destination.extension().string();

    int counter = 1;

    while (true) {

        fs::path candidate =
            parent /
            (stem + "_" + std::to_string(counter) + extension);

        if (!fs::exists(candidate)) {
            return candidate;
        }

        ++counter;
    }
}

// ------------------------------------------------------------
// Salva log JSON
// ------------------------------------------------------------
bool saveLog(
    const fs::path& file,
    const fs::path& source,
    const fs::path& target,
    const std::vector<Operation>& operations
) {

    std::ofstream out(file);

    if (!out) {
        return false;
    }

    out << "{\n";

    out << "  \"tool\": \"POLYDEV File Organizer\",\n";
    out << "  \"timestamp\": \"" << timestampReadable() << "\",\n";

    out << "  \"source\": \""
        << jsonEscape(source.string())
        << "\",\n";

    out << "  \"target\": \""
        << jsonEscape(target.string())
        << "\",\n";

    out << "  \"operations\": [\n";

    for (std::size_t i = 0; i < operations.size(); ++i) {

        const auto& op = operations[i];

        out << "    {\n";

        out << "      \"original\": \""
            << jsonEscape(op.original.string())
            << "\",\n";

        out << "      \"destination\": \""
            << jsonEscape(op.destination.string())
            << "\",\n";

        out << "      \"success\": "
            << (op.success ? "true" : "false")
            << ",\n";

        out << "      \"error\": \""
            << jsonEscape(op.error)
            << "\"\n";

        out << "    }";

        if (i + 1 < operations.size()) {
            out << ",";
        }

        out << "\n";
    }

    out << "  ]\n";
    out << "}\n";

    return true;
}

// ------------------------------------------------------------
// Extrai campos simples do JSON gerado pela propria ferramenta
//
// Nao e parser JSON generico.
// Serve especificamente para o manifest criado acima.
// ------------------------------------------------------------
std::optional<std::string> extractJsonString(
    const std::string& line,
    const std::string& key
) {

    std::string token = "\"" + key + "\"";

    auto pos = line.find(token);

    if (pos == std::string::npos) {
        return std::nullopt;
    }

    pos = line.find(':', pos);

    if (pos == std::string::npos) {
        return std::nullopt;
    }

    pos = line.find('"', pos);

    if (pos == std::string::npos) {
        return std::nullopt;
    }

    ++pos;

    std::string result;

    bool escape = false;

    for (; pos < line.size(); ++pos) {

        char c = line[pos];

        if (escape) {

            switch (c) {

                case '\\':
                    result += '\\';
                    break;

                case '"':
                    result += '"';
                    break;

                case 'n':
                    result += '\n';
                    break;

                case 'r':
                    result += '\r';
                    break;

                case 't':
                    result += '\t';
                    break;

                default:
                    result += c;
            }

            escape = false;
        }

        else {

            if (c == '\\') {
                escape = true;
            }

            else if (c == '"') {
                break;
            }

            else {
                result += c;
            }
        }
    }

    return result;
}

// ------------------------------------------------------------
// Rollback
// ------------------------------------------------------------
int rollback(const fs::path& logFile) {

    if (!fs::exists(logFile)) {

        std::cerr
            << "Erro: arquivo de rollback nao encontrado: "
            << logFile
            << "\n";

        return 1;
    }

    std::ifstream in(logFile);

    if (!in) {

        std::cerr
            << "Erro ao abrir arquivo de rollback.\n";

        return 1;
    }

    std::vector<std::pair<fs::path, fs::path>> operations;

    std::string line;

    std::optional<fs::path> original;
    std::optional<fs::path> destination;

    while (std::getline(in, line)) {

        auto o = extractJsonString(line, "original");

        if (o) {
            original = fs::path(*o);
        }

        auto d = extractJsonString(line, "destination");

        if (d) {
            destination = fs::path(*d);
        }

        if (original && destination) {

            operations.push_back({
                *original,
                *destination
            });

            original.reset();
            destination.reset();
        }
    }

    if (operations.empty()) {

        std::cerr
            << "Nenhuma operacao encontrada no arquivo.\n";

        return 1;
    }

    std::size_t restored = 0;
    std::size_t failed = 0;

    std::cout
        << "\nPOLYDEV FILE ORGANIZER - ROLLBACK\n\n";

    // rollback deve ocorrer em ordem inversa
    for (auto it = operations.rbegin();
         it != operations.rend();
         ++it) {

        const fs::path& originalPath = it->first;
        const fs::path& movedPath = it->second;

        if (!fs::exists(movedPath)) {

            std::cerr
                << "[IGNORADO] Arquivo nao encontrado: "
                << movedPath
                << "\n";

            ++failed;

            continue;
        }

        try {

            fs::create_directories(originalPath.parent_path());

            fs::path restorePath = originalPath;

            if (fs::exists(restorePath)) {

                restorePath =
                    generateUniqueDestination(restorePath);
            }

            fs::rename(
                movedPath,
                restorePath
            );

            std::cout
                << "[RESTAURADO] "
                << movedPath.filename()
                << " -> "
                << restorePath
                << "\n";

            ++restored;
        }

        catch (const fs::filesystem_error& e) {

            std::cerr
                << "[ERRO] "
                << movedPath
                << ": "
                << e.what()
                << "\n";

            ++failed;
        }
    }

    std::cout
        << "\nRollback concluido.\n";

    std::cout
        << "Restaurados : "
        << restored
        << "\n";

    std::cout
        << "Falhas      : "
        << failed
        << "\n\n";

    return failed == 0 ? 0 : 2;
}

// ------------------------------------------------------------
// MAIN
// ------------------------------------------------------------
int main(int argc, char* argv[]) {

    auto optionsResult =
        parseArguments(argc, argv);

    if (!optionsResult) {

        showHelp(argv[0]);

        return 1;
    }

    Options options =
        *optionsResult;

    // --------------------------------------------------------
    // Rollback
    // --------------------------------------------------------

    if (options.rollback) {

        return rollback(
            *options.rollbackFile
        );
    }

    fs::path source =
        fs::absolute(options.source);

    if (!fs::exists(source) ||
        !fs::is_directory(source)) {

        std::cerr
            << "Erro: diretorio invalido: "
            << source
            << "\n";

        return 1;
    }

    fs::path target =
        options.target
        ? fs::absolute(*options.target)
        : source;

    if (!options.dryRun) {

        try {

            fs::create_directories(target);

        }

        catch (const fs::filesystem_error& e) {

            std::cerr
                << "Erro ao criar diretorio destino: "
                << e.what()
                << "\n";

            return 1;
        }
    }

    auto rules =
        createRules();

    std::vector<Operation> operations;

    std::size_t scanned = 0;
    std::size_t moved = 0;
    std::size_t failed = 0;
    std::size_t ignored = 0;

    std::cout
        << "\n========================================\n";

    std::cout
        << " POLYDEV - FILE ORGANIZER CLI\n";

    std::cout
        << "========================================\n\n";

    std::cout
        << "Origem : "
        << source
        << "\n";

    std::cout
        << "Destino: "
        << target
        << "\n";

    if (options.dryRun) {

        std::cout
            << "Modo   : DRY-RUN\n";
    }

    else {

        std::cout
            << "Modo   : EXECUCAO\n";
    }

    std::cout << "\n";

    try {

        for (const auto& entry :
             fs::directory_iterator(source)) {

            if (!entry.is_regular_file()) {

                ++ignored;

                continue;
            }

            ++scanned;

            fs::path original =
                entry.path();

            std::string extension =
                toLower(
                    original.extension().string()
                );

            std::string category =
                "Outros";

            auto rule =
                rules.find(extension);

            if (rule != rules.end()) {

                category =
                    rule->second;
            }

            fs::path categoryFolder =
                target / category;

            fs::path destination =
                categoryFolder /
                original.filename();

            destination =
                generateUniqueDestination(
                    destination
                );

            Operation operation;

            operation.original =
                original;

            operation.destination =
                destination;

            if (options.dryRun) {

                std::cout
                    << "[DRY-RUN] "
                    << original.filename()
                    << " -> "
                    << category
                    << "/"
                    << destination.filename()
                    << "\n";

                operation.success =
                    true;

                operations.push_back(
                    operation
                );

                continue;
            }

            try {

                fs::create_directories(
                    categoryFolder
                );

                fs::rename(
                    original,
                    destination
                );

                operation.success =
                    true;

                ++moved;

                std::cout
                    << "[MOVIDO] "
                    << original.filename()
                    << " -> "
                    << category
                    << "/"
                    << destination.filename()
                    << "\n";
            }

            catch (const fs::filesystem_error& e) {

                operation.success =
                    false;

                operation.error =
                    e.what();

                ++failed;

                std::cerr
                    << "[ERRO] "
                    << original.filename()
                    << ": "
                    << e.what()
                    << "\n";
            }

            operations.push_back(
                operation
            );
        }
    }

    catch (const fs::filesystem_error& e) {

        std::cerr
            << "\nErro ao percorrer diretorio: "
            << e.what()
            << "\n";

        return 1;
    }

    // --------------------------------------------------------
    // Log
    // --------------------------------------------------------

    fs::path logFile =
        "organizer_" +
        timestamp() +
        ".json";

    if (!options.dryRun) {

        if (saveLog(
                logFile,
                source,
                target,
                operations)) {

            std::cout
                << "\nLog criado: "
                << logFile
                << "\n";
        }

        else {

            std::cerr
                << "\nAviso: nao foi possivel criar log.\n";
        }
    }

    // --------------------------------------------------------
    // Resumo
    // --------------------------------------------------------

    std::cout
        << "\n========================================\n";

    std::cout
        << " RESUMO\n";

    std::cout
        << "========================================\n";

    std::cout
        << "Arquivos analisados : "
        << scanned
        << "\n";

    if (options.dryRun) {

        std::cout
            << "Movimentos simulados: "
            << operations.size()
            << "\n";
    }

    else {

        std::cout
            << "Arquivos movidos     : "
            << moved
            << "\n";
    }

    std::cout
        << "Ignorados            : "
        << ignored
        << "\n";

    std::cout
        << "Falhas               : "
        << failed
        << "\n";

    std::cout
        << "========================================\n\n";

    if (options.dryRun) {

        std::cout
            << "Nenhum arquivo foi alterado.\n\n";
    }

    else {

        std::cout
            << "Para desfazer:\n\n";

        std::cout
            << argv[0]
            << " --rollback "
            << logFile
            << "\n\n";
    }

    return failed == 0 ? 0 : 2;
}

