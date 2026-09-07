/*
=============================================================
WX-TOOLS | C++ | 002 | Duplicate File Finder CLI

Finalidade:
Localizar arquivos duplicados dentro de um diretório,
sem apagar ou modificar nenhum arquivo.

Recursos:
- Varredura recursiva
- Agrupamento inicial por tamanho
- Hash apenas em arquivos candidatos
- Filtro por tamanho mínimo
- Filtro por extensão
- Exportação opcional para JSON
- Operação somente leitura

POLYDEV | WX-TOOLS
Ferramentas reais. Problemas reais. Código homologado.
=============================================================
*/

#include <algorithm>
#include <cctype>
#include <cstdint>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <map>
#include <sstream>
#include <string>
#include <unordered_map>
#include <vector>

namespace fs = std::filesystem;

struct Options {
    fs::path directory;
    std::uintmax_t min_size = 0;
    std::string extension;
    std::string export_file;
    bool export_json = false;
};

struct Stats {
    std::uintmax_t files_scanned = 0;
    std::uintmax_t candidate_files = 0;
    std::uintmax_t duplicate_files = 0;
    std::uintmax_t duplicate_groups = 0;
    std::uintmax_t recoverable_bytes = 0;
    std::uintmax_t read_errors = 0;
};

using FileGroup = std::vector<fs::path>;

static void print_usage(const char* program) {
    std::cout
        << "\nPOLYDEV - DUPLICATE FILE FINDER CLI\n\n"
        << "Uso:\n\n"
        << "  " << program << " <diretorio>\n"
        << "  " << program << " <diretorio> --min-size <valor>\n"
        << "  " << program << " <diretorio> --extension <extensao>\n"
        << "  " << program << " <diretorio> --export <arquivo.json>\n\n"
        << "Exemplos:\n\n"
        << "  " << program << " /home/user/Downloads\n"
        << "  " << program << " /home/user/Downloads --min-size 1MB\n"
        << "  " << program << " /home/user/Downloads --extension .pdf\n"
        << "  " << program << " /home/user/Downloads --export duplicados.json\n\n";
}

static std::string to_lower(std::string value) {
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

static std::uintmax_t parse_size(std::string value) {
    value.erase(
        std::remove_if(
            value.begin(),
            value.end(),
            [](unsigned char c) {
                return std::isspace(c);
            }
        ),
        value.end()
    );

    if (value.empty()) {
        throw std::runtime_error("Valor vazio para --min-size.");
    }

    std::size_t pos = 0;

    while (
        pos < value.size() &&
        (std::isdigit(static_cast<unsigned char>(value[pos])) ||
         value[pos] == '.')
    ) {
        ++pos;
    }

    if (pos == 0) {
        throw std::runtime_error("Tamanho inválido: " + value);
    }

    const double number = std::stod(value.substr(0, pos));

    std::string suffix =
        to_lower(value.substr(pos));

    std::uintmax_t multiplier = 1;

    if (suffix.empty() || suffix == "b") {
        multiplier = 1;
    }
    else if (suffix == "kb" || suffix == "k") {
        multiplier = 1024ULL;
    }
    else if (suffix == "mb" || suffix == "m") {
        multiplier = 1024ULL * 1024ULL;
    }
    else if (suffix == "gb" || suffix == "g") {
        multiplier =
            1024ULL * 1024ULL * 1024ULL;
    }
    else if (suffix == "tb" || suffix == "t") {
        multiplier =
            1024ULL *
            1024ULL *
            1024ULL *
            1024ULL;
    }
    else {
        throw std::runtime_error(
            "Sufixo de tamanho inválido: " + suffix
        );
    }

    return static_cast<std::uintmax_t>(
        number * static_cast<double>(multiplier)
    );
}

static std::string human_size(std::uintmax_t bytes) {
    const char* units[] = {
        "B",
        "KB",
        "MB",
        "GB",
        "TB"
    };

    double value =
        static_cast<double>(bytes);

    std::size_t unit = 0;

    while (
        value >= 1024.0 &&
        unit < 4
    ) {
        value /= 1024.0;
        ++unit;
    }

    std::ostringstream out;

    out
        << std::fixed
        << std::setprecision(
            unit == 0 ? 0 : 2
        )
        << value
        << " "
        << units[unit];

    return out.str();
}

static std::uint64_t hash_file(const fs::path& file) {
    std::ifstream input(
        file,
        std::ios::binary
    );

    if (!input) {
        throw std::runtime_error(
            "Não foi possível abrir: " +
            file.string()
        );
    }

    constexpr std::uint64_t FNV_OFFSET =
        14695981039346656037ULL;

    constexpr std::uint64_t FNV_PRIME =
        1099511628211ULL;

    std::uint64_t hash =
        FNV_OFFSET;

    char buffer[64 * 1024];

    while (input) {
        input.read(
            buffer,
            sizeof(buffer)
        );

        const std::streamsize count =
            input.gcount();

        for (
            std::streamsize i = 0;
            i < count;
            ++i
        ) {
            hash ^=
                static_cast<unsigned char>(
                    buffer[i]
                );

            hash *=
                FNV_PRIME;
        }
    }

    return hash;
}

static bool same_content(
    const fs::path& a,
    const fs::path& b
) {
    std::ifstream fa(
        a,
        std::ios::binary
    );

    std::ifstream fb(
        b,
        std::ios::binary
    );

    if (!fa || !fb) {
        return false;
    }

    constexpr std::size_t BUFFER_SIZE =
        64 * 1024;

    char ba[BUFFER_SIZE];
    char bb[BUFFER_SIZE];

    while (fa && fb) {
        fa.read(
            ba,
            BUFFER_SIZE
        );

        fb.read(
            bb,
            BUFFER_SIZE
        );

        const auto ca =
            fa.gcount();

        const auto cb =
            fb.gcount();

        if (ca != cb) {
            return false;
        }

        if (
            !std::equal(
                ba,
                ba + ca,
                bb
            )
        ) {
            return false;
        }
    }

    return true;
}

static std::string json_escape(
    const std::string& value
) {
    std::ostringstream out;

    for (char c : value) {
        switch (c) {
            case '\\':
                out << "\\\\";
                break;

            case '"':
                out << "\\\"";
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
                break;
        }
    }

    return out.str();
}

static void export_json(
    const std::string& file_name,
    const std::vector<FileGroup>& groups,
    const Stats& stats
) {
    std::ofstream out(file_name);

    if (!out) {
        throw std::runtime_error(
            "Não foi possível criar arquivo JSON: " +
            file_name
        );
    }

    out << "{\n";

    out
        << "  \"files_scanned\": "
        << stats.files_scanned
        << ",\n";

    out
        << "  \"duplicate_groups\": "
        << stats.duplicate_groups
        << ",\n";

    out
        << "  \"duplicate_files\": "
        << stats.duplicate_files
        << ",\n";

    out
        << "  \"recoverable_bytes\": "
        << stats.recoverable_bytes
        << ",\n";

    out << "  \"groups\": [\n";

    for (
        std::size_t i = 0;
        i < groups.size();
        ++i
    ) {
        out << "    {\n";

        out
            << "      \"group\": "
            << (i + 1)
            << ",\n";

        out
            << "      \"files\": [\n";

        for (
            std::size_t j = 0;
            j < groups[i].size();
            ++j
        ) {
            out
                << "        \""
                << json_escape(
                    groups[i][j].string()
                )
                << "\"";

            if (
                j + 1 <
                groups[i].size()
            ) {
                out << ",";
            }

            out << "\n";
        }

        out << "      ]\n";
        out << "    }";

        if (
            i + 1 <
            groups.size()
        ) {
            out << ",";
        }

        out << "\n";
    }

    out << "  ]\n";
    out << "}\n";
}

static Options parse_arguments(
    int argc,
    char* argv[]
) {
    if (argc < 2) {
        print_usage(argv[0]);
        std::exit(1);
    }

    Options options;

    options.directory =
        fs::path(argv[1]);

    for (
        int i = 2;
        i < argc;
        ++i
    ) {
        const std::string arg =
            argv[i];

        if (arg == "--min-size") {
            if (i + 1 >= argc) {
                throw std::runtime_error(
                    "--min-size exige um valor."
                );
            }

            options.min_size =
                parse_size(argv[++i]);
        }
        else if (arg == "--extension") {
            if (i + 1 >= argc) {
                throw std::runtime_error(
                    "--extension exige uma extensão."
                );
            }

            options.extension =
                to_lower(argv[++i]);

            if (
                !options.extension.empty() &&
                options.extension.front() != '.'
            ) {
                options.extension =
                    "." +
                    options.extension;
            }
        }
        else if (arg == "--export") {
            if (i + 1 >= argc) {
                throw std::runtime_error(
                    "--export exige um arquivo."
                );
            }

            options.export_file =
                argv[++i];

            options.export_json =
                true;
        }
        else if (
            arg == "--help" ||
            arg == "-h"
        ) {
            print_usage(argv[0]);
            std::exit(0);
        }
        else {
            throw std::runtime_error(
                "Opção desconhecida: " + arg
            );
        }
    }

    return options;
}

int main(
    int argc,
    char* argv[]
) {
    try {
        const Options options =
            parse_arguments(
                argc,
                argv
            );

        if (
            !fs::exists(
                options.directory
            )
        ) {
            std::cerr
                << "Erro: diretório não existe.\n";

            return 1;
        }

        if (
            !fs::is_directory(
                options.directory
            )
        ) {
            std::cerr
                << "Erro: caminho informado não é um diretório.\n";

            return 1;
        }

        std::cout
            << "\nPOLYDEV - DUPLICATE FILE FINDER CLI\n\n";

        std::cout
            << "Diretório: "
            << fs::absolute(
                options.directory
            )
            << "\n";

        if (options.min_size > 0) {
            std::cout
                << "Tamanho mínimo: "
                << human_size(
                    options.min_size
                )
                << "\n";
        }

        if (
            !options.extension.empty()
        ) {
            std::cout
                << "Extensão: "
                << options.extension
                << "\n";
        }

        std::cout
            << "\nAnalisando arquivos...\n\n";

        Stats stats;

        std::map<
            std::uintmax_t,
            std::vector<fs::path>
        > by_size;

        fs::directory_options dir_options =
            fs::directory_options::skip_permission_denied;

        std::error_code ec;

        fs::recursive_directory_iterator it(
            options.directory,
            dir_options,
            ec
        );

        fs::recursive_directory_iterator end;

        while (it != end) {
            if (ec) {
                ++stats.read_errors;
                ec.clear();

                it.increment(ec);

                continue;
            }

            const fs::directory_entry& entry =
                *it;

            if (
                entry.is_regular_file(ec)
            ) {
                ++stats.files_scanned;

                if (ec) {
                    ++stats.read_errors;
                    ec.clear();

                    it.increment(ec);

                    continue;
                }

                if (
                    !options.extension.empty()
                ) {
                    const std::string ext =
                        to_lower(
                            entry.path()
                                .extension()
                                .string()
                        );

                    if (
                        ext !=
                        options.extension
                    ) {
                        it.increment(ec);
                        continue;
                    }
                }

                const std::uintmax_t size =
                    entry.file_size(ec);

                if (ec) {
                    ++stats.read_errors;
                    ec.clear();

                    it.increment(ec);

                    continue;
                }

                if (
                    size <
                    options.min_size
                ) {
                    it.increment(ec);
                    continue;
                }

                by_size[size]
                    .push_back(
                        entry.path()
                    );
            }

            it.increment(ec);
        }

        std::vector<FileGroup>
            duplicate_groups;

        for (
            const auto& [size, files] :
            by_size
        ) {
            if (
                files.size() < 2
            ) {
                continue;
            }

            stats.candidate_files +=
                files.size();

            std::unordered_map<
                std::uint64_t,
                FileGroup
            > by_hash;

            for (
                const auto& file :
                files
            ) {
                try {
                    const auto hash =
                        hash_file(file);

                    by_hash[hash]
                        .push_back(file);
                }
                catch (...) {
                    ++stats.read_errors;
                }
            }

            for (
                auto& [hash, hash_files] :
                by_hash
            ) {
                (void)hash;

                if (
                    hash_files.size() < 2
                ) {
                    continue;
                }

                std::vector<bool>
                    used(
                        hash_files.size(),
                        false
                    );

                for (
                    std::size_t i = 0;
                    i < hash_files.size();
                    ++i
                ) {
                    if (used[i]) {
                        continue;
                    }

                    FileGroup confirmed;

                    confirmed.push_back(
                        hash_files[i]
                    );

                    used[i] = true;

                    for (
                        std::size_t j =
                            i + 1;
                        j < hash_files.size();
                        ++j
                    ) {
                        if (used[j]) {
                            continue;
                        }

                        if (
                            same_content(
                                hash_files[i],
                                hash_files[j]
                            )
                        ) {
                            confirmed.push_back(
                                hash_files[j]
                            );

                            used[j] = true;
                        }
                    }

                    if (
                        confirmed.size() > 1
                    ) {
                        duplicate_groups
                            .push_back(
                                confirmed
                            );

                        stats.duplicate_groups++;

                        stats.duplicate_files +=
                            confirmed.size() - 1;

                        stats.recoverable_bytes +=
                            size *
                            (
                                confirmed.size() - 1
                            );
                    }
                }
            }
        }

        if (
            duplicate_groups.empty()
        ) {
            std::cout
                << "Nenhum arquivo duplicado encontrado.\n";
        }
        else {
            for (
                std::size_t i = 0;
                i < duplicate_groups.size();
                ++i
            ) {
                const auto& group =
                    duplicate_groups[i];

                std::error_code size_ec;

                const auto file_size =
                    fs::file_size(
                        group.front(),
                        size_ec
                    );

                std::cout
                    << "GRUPO "
                    << std::setw(3)
                    << std::setfill('0')
                    << (i + 1)
                    << std::setfill(' ')
                    << "\n";

                if (!size_ec) {
                    std::cout
                        << "Tamanho: "
                        << human_size(
                            file_size
                        )
                        << "\n";
                }

                for (
                    const auto& file :
                    group
                ) {
                    std::cout
                        << "  "
                        << file
                        << "\n";
                }

                std::cout << "\n";
            }
        }

        std::cout
            << "========================================\n";

        std::cout
            << "Arquivos analisados: "
            << stats.files_scanned
            << "\n";

        std::cout
            << "Arquivos candidatos: "
            << stats.candidate_files
            << "\n";

        std::cout
            << "Grupos duplicados: "
            << stats.duplicate_groups
            << "\n";

        std::cout
            << "Duplicados adicionais: "
            << stats.duplicate_files
            << "\n";

        std::cout
            << "Espaço potencialmente recuperável: "
            << human_size(
                stats.recoverable_bytes
            )
            << "\n";

        std::cout
            << "Erros de leitura: "
            << stats.read_errors
            << "\n";

        std::cout
            << "========================================\n";

        if (
            options.export_json
        ) {
            export_json(
                options.export_file,
                duplicate_groups,
                stats
            );

            std::cout
                << "\nJSON exportado: "
                << options.export_file
                << "\n";
        }

        std::cout
            << "\nModo seguro: nenhum arquivo foi alterado ou removido.\n\n";

        return 0;
    }
    catch (
        const std::exception& ex
    ) {
        std::cerr
            << "\nErro: "
            << ex.what()
            << "\n";

        return 1;
    }
}