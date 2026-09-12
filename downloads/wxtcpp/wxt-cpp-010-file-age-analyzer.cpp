// WX-TOOLS | C++ | 010 | File Age Analyzer (C++17, Windows/Linux)
// Diagnóstico somente-leitura: classifica arquivos por idade (mtime),
// contabiliza arquivos e espaço por faixa. NÃO apaga, move ou modifica nada.
//
//   wxt-cpp-010-file-age-analyzer scan <dir> [--buckets 30,90,365,1095] [--depth 1] [--top 10]

#include <algorithm>
#include <chrono>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <filesystem>
#include <iomanip>
#include <iostream>
#include <map>
#include <queue>
#include <sstream>
#include <string>
#include <vector>

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#include <windows.h>
#include <io.h>
#else
#include <unistd.h>
#endif

namespace fs = std::filesystem;
using Bytes = std::uint64_t;

static fs::path toPath(const std::string& u8) { return fs::u8path(u8); }
static std::string keyOf(const fs::path& p)   { return p.generic_u8string(); }

// ---------- formatação ----------
static std::string human(Bytes b) {
    const char* u[] = { "B", "KB", "MB", "GB", "TB" };
    double v = static_cast<double>(b);
    int i = 0;
    while (v >= 1024.0 && i < 4) { v /= 1024.0; ++i; }
    std::ostringstream o;
    o << std::fixed << std::setprecision(i == 0 ? 0 : (v < 10 ? 2 : 1)) << v << ' ' << u[i];
    return o.str();
}

static std::string sepNum(std::uint64_t v) {          // 84213 -> "84.213"
    std::string s = std::to_string(v);
    int pos = static_cast<int>(s.size()) - 3;
    while (pos > 0) { s.insert(static_cast<std::size_t>(pos), "."); pos -= 3; }
    return s;
}

static std::string humanAge(std::int64_t ageSec) {
    const double d = ageSec / 86400.0;
    std::ostringstream o;
    if (d < 1.0 / 24)   return "<1 h";
    if (d < 1.0)        { o << static_cast<int>(d * 24) << " h"; }
    else if (d < 60)    { o << static_cast<int>(d) << " dias"; }
    else if (d < 365)   { o << std::fixed << std::setprecision(0) << d / 30.44 << " meses"; }
    else                { o << std::fixed << std::setprecision(1) << d / 365.25 << " anos"; }
    return o.str();
}

// ---------- agregação ----------
struct Options {
    std::vector<std::int64_t> bounds{30, 90, 365, 1095};   // dias
    int depth = 1;   // nível do detalhamento por diretório (0 = desliga)
    int topN  = 10;  // maiores arquivos listados (0 = desliga)
};

struct Bucket { std::uint64_t files = 0; Bytes bytes = 0;
                void add(std::uint64_t f, Bytes b) { files += f; bytes += b; } };

struct BigFile { Bytes size; std::int64_t ageSec; std::string path; };
struct BigCmp  { bool operator()(const BigFile& a, const BigFile& b) const { return a.size > b.size; } };

struct Stats {
    std::vector<Bucket> total;                              // por faixa
    std::map<std::string, std::vector<Bucket>> dirs;        // dir nível N -> por faixa
    std::priority_queue<BigFile, std::vector<BigFile>, BigCmp> top;  // min-heap
    std::uint64_t scanned = 0, errors = 0;
    explicit Stats(std::size_t nb) : total(nb + 1) {}
};

static bool stderrIsTty() {
#ifdef _WIN32
    return _isatty(_fileno(stderr)) != 0;
#else
    return isatty(fileno(stderr)) != 0;
#endif
}

// ---------- varredura (somente leitura) ----------
static void walk(const fs::path& dir, const std::string& rel, Stats& st, const Options& opt,
                 const fs::file_time_type::clock::time_point& now) {
    std::error_code ec;
    fs::directory_iterator it(dir, fs::directory_options::skip_permission_denied, ec);
    if (ec) { ++st.errors; return; }
    for (fs::directory_iterator end; !ec && it != end; it.increment(ec)) {
        ec.clear();
        std::error_code e2;
        const fs::file_type t = it->symlink_status(e2).type();
        if (e2) { ++st.errors; continue; }
        bool isLink = (t == fs::file_type::symlink);
#ifdef _WIN32
        // Junctions e outros reparse points podem criar loops ou dupla contagem.
        // std::filesystem::file_type não possui um tipo "junction" no C++17,
        // então no Windows consultamos diretamente os atributos do arquivo.
        const DWORD attrs = GetFileAttributesW(it->path().c_str());
        if (attrs != INVALID_FILE_ATTRIBUTES && (attrs & FILE_ATTRIBUTE_REPARSE_POINT))
            isLink = true;
#endif
        if (isLink) continue;

        if (t == fs::file_type::directory) {
            const std::string name = keyOf(it->path().filename());
            walk(it->path(), rel.empty() ? name : rel + "/" + name, st, opt, now);
        } else if (t == fs::file_type::regular) {
            const Bytes sz = it->file_size(e2);
            if (e2) { ++st.errors; continue; }
            const auto ftime = it->last_write_time(e2);
            if (e2) { ++st.errors; continue; }

            std::int64_t ageSec = std::chrono::duration_cast<std::chrono::seconds>(now - ftime).count();
            if (ageSec < 0) ageSec = 0;                      // relógio adiantado / skew

            std::size_t bi = 0;                              // faixa do arquivo
            for (std::size_t i = 0; i < opt.bounds.size(); ++i)
                if (ageSec >= opt.bounds[i] * 86400) bi = i + 1;
                else break;

            const std::string name = keyOf(it->path().filename());
            const std::string full = rel.empty() ? name : rel + "/" + name;

            ++st.scanned;
            st.total[bi].add(1, sz);

            if (opt.depth > 0) {                             // diretório de nível N
                // Agrupa pelo diretório relativo, nunca pelo nome do arquivo.
                std::string dirKey = rel.empty() ? std::string(".") : rel;
                int slashes = 0;
                for (std::size_t i = 0; i < dirKey.size(); ++i) {
                    if (dirKey[i] == '/' && ++slashes == opt.depth) {
                        dirKey.resize(i);
                        break;
                    }
                }
                auto& v = st.dirs[dirKey];
                if (v.size() != st.total.size()) v.resize(st.total.size());
                v[bi].add(1, sz);
            }

            if (opt.topN > 0) {                              // top maiores arquivos
                if (static_cast<int>(st.top.size()) < opt.topN)
                    st.top.push({ sz, ageSec, full });
                else if (sz > st.top.top().size) { st.top.pop(); st.top.push({ sz, ageSec, full }); }
            }

            if (stderrIsTty() && (st.scanned % 25000) == 0)
                std::fprintf(stderr, "\r  ... %s arquivos", sepNum(st.scanned).c_str());
        }
    }
}

// ---------- relatório ----------
static std::vector<std::string> bucketLabels(const std::vector<std::int64_t>& b) {
    const std::vector<std::int64_t> def{30, 90, 365, 1095};
    std::vector<std::string> out(b.size() + 1);
    if (b == def) {
        out = { "< 30 dias", "30-90 dias", "90 dias-1 ano", "1-3 anos", "> 3 anos" };
    } else {
        auto dl = [](std::int64_t d) { return std::to_string(d) + "d"; };
        out[0] = "< " + dl(b[0]);
        for (std::size_t i = 1; i < b.size(); ++i) out[i] = dl(b[i - 1]) + "-" + dl(b[i]);
        out[b.size()] = "> " + dl(b.back());
    }
    return out;
}

static std::vector<std::string> compactLabels(const std::vector<std::int64_t>& b) {
    auto dl = [](std::int64_t d) -> std::string {
        if (d % 365 == 0) return std::to_string(d / 365) + "a";
        return std::to_string(d) + "d";
    };
    std::vector<std::string> out(b.size() + 1);
    out[0] = "<" + dl(b[0]);
    for (std::size_t i = 1; i < b.size(); ++i) out[i] = dl(b[i - 1]) + "-" + dl(b[i]);
    out[b.size()] = ">" + dl(b.back());
    return out;
}

static void printReport(const fs::path& root, Stats& st, const Options& opt) {
    const auto labels = bucketLabels(opt.bounds);
    Bytes grand = 0; std::uint64_t files = 0;
    for (const auto& b : st.total) { grand += b.bytes; files += b.files; }

    std::cout << "File Age Analyzer  (somente leitura)\n"
              << "Raiz: " << keyOf(root) << '\n'
              << "Arquivos: " << sepNum(files);
    if (st.errors) std::cout << "   (ignorados: " << sepNum(st.errors) << " — permissão/erro)";
    std::cout << "\nTotal: " << human(grand) << "\n\n";

    const int W1 = 16, W2 = 12, W3 = 12, W4 = 8;
    std::cout << std::left  << std::setw(W1) << "IDADE"          << std::right
              << std::setw(W2) << "ARQUIVOS" << std::setw(W3) << "TAMANHO"
              << std::setw(W4) << "% TAM" << '\n'
              << std::string(W1 + W2 + W3 + W4, '-') << '\n';

    for (std::size_t i = 0; i < st.total.size(); ++i) {
        const double pct = grand ? 100.0 * static_cast<double>(st.total[i].bytes)
                                 / static_cast<double>(grand) : 0.0;
        std::cout << std::left << std::setw(W1) << labels[i] << std::right
                  << std::setw(W2) << sepNum(st.total[i].files)
                  << std::setw(W3) << human(st.total[i].bytes)
                  << std::setw(W3 - 4) << "" // respiro
                  << std::fixed << std::setprecision(1)
                  << std::setw(4) << pct << '%' << '\n';
    }

    if (opt.depth > 0 && !st.dirs.empty()) {
        std::vector<std::pair<std::string, Bytes>> order;
        for (const auto& [k, v] : st.dirs) {
            Bytes t = 0; for (const auto& b : v) t += b.bytes;
            order.emplace_back(k, t);
        }
        std::sort(order.begin(), order.end(),
                  [](const auto& a, const auto& b) { return a.second > b.second; });

        const auto cl = compactLabels(opt.bounds);
        std::cout << "\nPOR DIRETORIO (nivel " << opt.depth << ") — tamanho por faixa\n"
                  << std::left << std::setw(30) << "DIRETORIO" << std::right;
        for (const auto& s : cl) std::cout << std::setw(11) << s;
        std::cout << std::setw(11) << "TOTAL" << '\n'
                  << std::string(30 + 11 * (cl.size() + 1), '-') << '\n';

        for (const auto& [k, t] : order) {
            const auto& v = st.dirs.at(k);
            std::string name = k;
            if (name.size() > 29) name = name.substr(0, 28) + "..";
            std::cout << std::left << std::setw(30) << name << std::right;
            for (const auto& b : v)
                std::cout << std::setw(11) << (b.bytes ? human(b.bytes) : "-");
            std::cout << std::setw(11) << human(t) << '\n';
        }
    }

    if (opt.topN > 0 && !st.top.empty()) {
        std::vector<BigFile> v;
        while (!st.top.empty()) { v.push_back(st.top.top()); st.top.pop(); }
        std::sort(v.begin(), v.end(),
                  [](const BigFile& a, const BigFile& b) { return a.size > b.size; });
        std::cout << "\nTOP " << v.size() << " ARQUIVOS (maiores)\n";
        for (const auto& f : v)
            std::cout << std::right << std::setw(11) << human(f.size)
                      << std::setw(11) << humanAge(f.ageSec) << "   " << f.path << '\n';
    }
}

// ---------- CLI ----------
static void usage() {
    std::cout <<
        "POLYDEV | WX-TOOLS | C++ | 010 | File Age Analyzer\n"
        "Somente leitura — nao apaga, move ou modifica arquivos.\n"
        "Uso:\n"
        "  wxt-cpp-010-file-age-analyzer scan <dir> [opcoes]\n"
        "    --buckets 30,90,365,1095  faixas em dias (padrao)\n"
        "    --depth N                 detalhar diretorios no nivel N (padrao 1, 0 = off)\n"
        "    --top N                   listar N maiores arquivos (padrao 10, 0 = off)\n";
}

#ifdef _WIN32
int wmain(int argc, wchar_t* argv[])
#else
int main(int argc, char* argv[])
#endif
{
#ifdef _WIN32
    SetConsoleOutputCP(CP_UTF8);
#endif
    std::vector<std::string> args;
    for (int i = 1; i < argc; ++i) {
#ifdef _WIN32
        args.push_back(fs::path(argv[i]).u8string());
#else
        args.push_back(argv[i]);
#endif
    }

    if (args.empty() || args[0] != "scan" || args.size() < 2) { usage(); return args.empty() ? 0 : 1; }

    Options opt;
    for (std::size_t i = 2; i < args.size(); ++i) {
        if (args[i] == "--buckets" && i + 1 < args.size()) {
            opt.bounds.clear();
            std::stringstream ss(args[++i]); std::string tok;
            while (std::getline(ss, tok, ',')) {
                const int v = std::atoi(tok.c_str());
                if (v > 0) opt.bounds.push_back(v);
            }
            std::sort(opt.bounds.begin(), opt.bounds.end());
            if (opt.bounds.empty()) opt.bounds = {30, 90, 365, 1095};
        }
        else if (args[i] == "--depth" && i + 1 < args.size()) opt.depth = std::atoi(args[++i].c_str());
        else if (args[i] == "--top"   && i + 1 < args.size()) opt.topN  = std::atoi(args[++i].c_str());
    }

    std::error_code ec;
    fs::path rootAbs = fs::absolute(toPath(args[1]), ec).lexically_normal();
    if (ec || !fs::is_directory(rootAbs, ec)) {
        std::cerr << "Diretorio invalido: " << args[1] << '\n';
        return 1;
    }

    Stats st(opt.bounds.size());
    std::cout << "Analisando " << keyOf(rootAbs) << " ...\n";
    const auto now = fs::file_time_type::clock::now();   // capturado 1x = idades consistentes
    walk(rootAbs, "", st, opt, now);
    if (stderrIsTty()) std::fprintf(stderr, "\r%64s\r", "");

    printReport(rootAbs, st, opt);
    return 0;
}