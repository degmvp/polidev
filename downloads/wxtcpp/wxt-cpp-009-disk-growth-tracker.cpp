
// ============================================================================
//  POLYDEV | WX-TOOLS
//  C++ | 009 | Disk Growth Tracker
//
//  Monitora o crescimento do disco através de snapshots.
//  Compara dois estados e identifica quais diretórios cresceram ou diminuíram.
//
//  Comandos:
//    dgt snap <dir> [-o arquivo.snap]
//    dgt diff antigo.snap novo.snap [--depth N] [--top N] [--min 1MB]
//
//  Arquivo   : wxt-cpp-009-disk-growth-tracker.cpp
//  Linguagem : C++17
//  Plataforma: Windows / Linux
// ============================================================================

#include <algorithm>
#include <cctype>
#include <chrono>
#include <cstdint>
#include <cstdlib>
#include <ctime>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <map>
#include <sstream>
#include <string>
#include <vector>

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <windows.h>
#endif

namespace fs = std::filesystem;
using Bytes = std::uint64_t;
using Sizes = std::map<std::string, Bytes>;   // dir -> bytes acumulados (inclui filhos)

// ---------- helpers de path UTF-8 ----------

static fs::path toPath(const std::string& u8) {
    return fs::u8path(u8);
}

static std::string keyOf(const fs::path& p) {
    return p.generic_u8string(); // sempre '/'
}

// ---------- varredura ----------
// Pós-ordem: soma cada arquivo e propaga para os pais.
// Symlinks/junctions pulados: evita ciclo e contagem dupla.

static Bytes walkDir(const fs::path& dir, Sizes& out) {
    Bytes total = 0;
    std::error_code ec;

    for (fs::directory_iterator it(
             dir,
             fs::directory_options::skip_permission_denied,
             ec),
         end;
         !ec && it != end;
         it.increment(ec)) {

        ec.clear();

        std::error_code ec2;
        const fs::file_type t = it->symlink_status(ec2).type();

        if (ec2)
            continue;

        bool isLink = (t == fs::file_type::symlink);

#ifdef _MSC_VER
        isLink = isLink || (t == fs::file_type::junction);
#endif

        if (isLink)
            continue;

        if (t == fs::file_type::directory) {
            total += walkDir(it->path(), out);
        }
        else if (t == fs::file_type::regular) {
            const Bytes sz = it->file_size(ec2);

            if (!ec2)
                total += sz;
        }
    }

    out[keyOf(dir)] = total;
    return total;
}

// ---------- snapshot ----------
// Formato:
// DGT1 <TAB> data/hora <TAB> root
// bytes <TAB> path

struct Snapshot {
    std::string when;
    std::string root;
    Sizes dirs;
};

static std::string nowStamp() {
    const std::time_t t =
        std::chrono::system_clock::to_time_t(
            std::chrono::system_clock::now());

    std::tm tm{};

#ifdef _WIN32
    localtime_s(&tm, &t);
#else
    localtime_r(&t, &tm);
#endif

    char buf[32];

    std::strftime(
        buf,
        sizeof buf,
        "%Y-%m-%d %H:%M:%S",
        &tm
    );

    return buf;
}

static bool saveSnap(
    const fs::path& file,
    const std::string& rootU8,
    const Sizes& sizes) {

    std::ofstream f(file, std::ios::binary);

    if (!f)
        return false;

    f << "DGT1\t"
      << nowStamp()
      << '\t'
      << rootU8
      << '\n';

    for (const auto& [p, b] : sizes)
        f << b << '\t' << p << '\n';

    return static_cast<bool>(f);
}

static bool loadSnap(
    const fs::path& file,
    Snapshot& s) {

    std::ifstream f(file, std::ios::binary);

    if (!f)
        return false;

    std::string line;

    if (!std::getline(f, line))
        return false;

    const auto t1 = line.find('\t');

    const auto t2 =
        t1 == std::string::npos
            ? t1
            : line.find('\t', t1 + 1);

    if (t1 == std::string::npos ||
        t2 == std::string::npos ||
        line.compare(0, 4, "DGT1") != 0) {

        return false;
    }

    s.when = line.substr(
        t1 + 1,
        t2 - t1 - 1
    );

    s.root = line.substr(t2 + 1);

    while (std::getline(f, line)) {

        const auto tab = line.find('\t');

        if (tab == std::string::npos)
            continue;

        s.dirs[line.substr(tab + 1)] =
            std::strtoull(
                line.c_str(),
                nullptr,
                10
            );
    }

    return true;
}

// ---------- formatação ----------

static std::string human(Bytes b) {

    const char* u[] = {
        "B",
        "KB",
        "MB",
        "GB",
        "TB"
    };

    double v = static_cast<double>(b);
    int i = 0;

    while (v >= 1024.0 && i < 4) {
        v /= 1024.0;
        ++i;
    }

    std::ostringstream o;

    o << std::fixed
      << std::setprecision(
             i == 0
                 ? 0
                 : (v < 10 ? 2 : 1))
      << v
      << ' '
      << u[i];

    return o.str();
}

static std::string humanDelta(std::int64_t d) {

    if (d == 0)
        return "0 B";

    return (d > 0 ? "+" : "-") +
           human(
               static_cast<Bytes>(
                   d > 0 ? d : -d
               )
           );
}

static Bytes parseSize(const std::string& s) {

    std::size_t i = 0;

    while (i < s.size() &&
           (std::isdigit(
                static_cast<unsigned char>(s[i]))
            || s[i] == '.')) {

        ++i;
    }

    std::string suf = s.substr(i);

    for (char& c : suf) {
        c = static_cast<char>(
            std::toupper(
                static_cast<unsigned char>(c)
            )
        );
    }

    double mult = 1;

    if (suf == "KB" || suf == "K")
        mult = 1024;

    else if (suf == "MB" || suf == "M")
        mult = 1024.0 * 1024;

    else if (suf == "GB" || suf == "G")
        mult = 1024.0 * 1024 * 1024;

    else if (suf == "TB" || suf == "T")
        mult = 1024.0 * 1024 * 1024 * 1024;

    return static_cast<Bytes>(
        std::atof(
            s.substr(0, i).c_str()
        ) * mult
    );
}

// ---------- diff ----------

struct Delta {
    std::string path;
    std::int64_t change;
};

static std::string displayPath(
    const std::string& root,
    const std::string& p) {

    if (p.size() > root.size() &&
        p.compare(0, root.size(), root) == 0) {

        return p.substr(
            root.size() +
            (root.back() == '/' ? 0 : 1)
        );
    }

    return p;
}

static int slashCount(const std::string& s) {

    return static_cast<int>(
        std::count(
            s.begin(),
            s.end(),
            '/'
        )
    );
}

static void runDiff(
    const Snapshot& a,
    const Snapshot& b,
    int depth,
    int topN,
    Bytes minBytes) {

    std::vector<Delta> list;

    const int base = slashCount(a.root);

    auto depthOk =
        [&](const std::string& p) {

            return slashCount(p) - base <= depth;
        };

    for (const auto& [p, nb] : b.dirs) {

        if (!depthOk(p) || p == a.root)
            continue;

        std::int64_t change;

        const auto it = a.dirs.find(p);

        if (it == a.dirs.end()) {

            change =
                static_cast<std::int64_t>(nb);
        }
        else {

            change =
                static_cast<std::int64_t>(nb) -
                static_cast<std::int64_t>(
                    it->second
                );
        }

        if (change == 0)
            continue;

        const Bytes mag =
            change > 0
                ? static_cast<Bytes>(change)
                : static_cast<Bytes>(-change);

        if (mag < minBytes)
            continue;

        list.push_back({
            p,
            change
        });
    }

    // Diretórios que existiam no snapshot antigo
    // e desapareceram no novo.

    for (const auto& [p, ob] : a.dirs) {

        if (b.dirs.count(p) ||
            !depthOk(p) ||
            ob < minBytes) {

            continue;
        }

        list.push_back({
            p,
            -static_cast<std::int64_t>(ob)
        });
    }

    std::sort(
        list.begin(),
        list.end(),
        [](const Delta& x, const Delta& y) {

            return std::llabs(x.change) >
                   std::llabs(y.change);
        }
    );

    std::cout
        << "Antigo: "
        << a.when
        << "   ("
        << a.root
        << ")\n"

        << "Novo:   "
        << b.when
        << "   ("
        << b.root
        << ")\n\n";

    if (list.empty()) {

        std::cout
            << "Nenhuma mudança >= "
            << human(minBytes)
            << " até profundidade "
            << depth
            << ".\n";

        return;
    }

    int shown = 0;

    for (const auto& d : list) {

        if (shown++ >= topN)
            break;

        std::cout
            << std::setw(12)
            << humanDelta(d.change)
            << "   "
            << displayPath(
                   a.root,
                   d.path
               )
            << '\n';
    }

    const auto ra = a.dirs.find(a.root);
    const auto rb = b.dirs.find(b.root);

    if (ra != a.dirs.end() &&
        rb != b.dirs.end()) {

        std::cout
            << '\n'
            << std::setw(12)
            << humanDelta(
                   static_cast<std::int64_t>(
                       rb->second
                   ) -
                   static_cast<std::int64_t>(
                       ra->second
                   )
               )
            << "   variação total\n";
    }
}

// ---------- ajuda ----------

static void usage() {

    std::cout
        << "POLYDEV | WX-TOOLS\n"
        << "C++ | 009 | Disk Growth Tracker\n\n"

        << "Uso:\n"

        << "  dgt snap <dir> [-o arquivo.snap]\n"

        << "  dgt diff antigo.snap novo.snap "
           "[--depth 2] [--top 20] [--min 1MB]\n";
}

// ---------- main ----------

#ifdef _WIN32

int wmain(
    int argc,
    wchar_t* argv[])

#else

int main(
    int argc,
    char* argv[])

#endif
{

#ifdef _WIN32
    SetConsoleOutputCP(CP_UTF8);
#endif

    std::vector<std::string> args;

    for (int i = 1; i < argc; ++i) {

#ifdef _WIN32

        args.push_back(
            fs::path(argv[i]).u8string()
        );

#else

        args.push_back(argv[i]);

#endif
    }

    if (args.empty()) {
        usage();
        return 0;
    }

    const std::string& cmd = args[0];

    // ---------- SNAP ----------

    if (cmd == "snap" &&
        args.size() >= 2) {

        std::string outFile;

        for (std::size_t i = 2;
             i + 1 < args.size();
             ++i) {

            if (args[i] == "-o")
                outFile = args[i + 1];
        }

        std::error_code ec;

        fs::path rootAbs =
            fs::absolute(
                toPath(args[1]),
                ec
            ).lexically_normal();

        if (ec ||
            !fs::is_directory(
                rootAbs,
                ec
            )) {

            std::cerr
                << "Diretório inválido: "
                << args[1]
                << '\n';

            return 1;
        }

        const std::string rootU8 =
            keyOf(rootAbs);

        std::cout
            << "Varrendo "
            << rootU8
            << " (pode demorar)...\n";

        Sizes sizes;

        walkDir(
            rootAbs,
            sizes
        );

        std::string stamp =
            nowStamp();

        for (char& c : stamp) {

            if (c == ' ' ||
                c == ':') {

                c = '-';
            }
        }

        if (outFile.empty()) {

            outFile =
                "dgt-" +
                stamp +
                ".snap";
        }

        if (!saveSnap(
                toPath(outFile),
                rootU8,
                sizes)) {

            std::cerr
                << "Falha ao escrever "
                << outFile
                << '\n';

            return 1;
        }

        std::cout
            << "Snapshot salvo: "
            << outFile
            << '\n'

            << "  diretórios: "
            << sizes.size()
            << '\n'

            << "  total: "
            << human(
                   sizes[rootU8]
               )
            << '\n';

        return 0;
    }

    // ---------- DIFF ----------

    if (cmd == "diff" &&
        args.size() >= 3) {

        Snapshot a;
        Snapshot b;

        if (!loadSnap(
                toPath(args[1]),
                a)) {

            std::cerr
                << "Falha ao ler "
                << args[1]
                << '\n';

            return 1;
        }

        if (!loadSnap(
                toPath(args[2]),
                b)) {

            std::cerr
                << "Falha ao ler "
                << args[2]
                << '\n';

            return 1;
        }

        int depth = 2;
        int topN = 20;

        Bytes minBytes =
            1024 * 1024;

        for (std::size_t i = 3;
             i < args.size();
             ++i) {

            if (args[i] == "--depth" &&
                i + 1 < args.size()) {

                depth =
                    std::atoi(
                        args[++i].c_str()
                    );
            }

            else if (
                args[i] == "--top" &&
                i + 1 < args.size()) {

                topN =
                    std::atoi(
                        args[++i].c_str()
                    );
            }

            else if (
                args[i] == "--min" &&
                i + 1 < args.size()) {

                minBytes =
                    parseSize(
                        args[++i]
                    );
            }
        }

        runDiff(
            a,
            b,
            depth,
            topN,
            minBytes
        );

        return 0;
    }

    usage();
    return 1;
}

