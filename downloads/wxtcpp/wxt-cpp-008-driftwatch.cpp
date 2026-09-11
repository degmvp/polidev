// ============================================================================
//  POLYDEV | WX-TOOLS
//  wxt-cpp-008-driftwatch.cpp
//  driftwatch — Monitor de crescimento de disco via snapshots (C++17)
//
//  driftwatch snap <dir>              -> captura o estado do disco
//  driftwatch diff <snapshot> [dir]   -> mostra o que cresceu, quanto e por quê
//
//  Compilação (VS 2022, Developer Command Prompt):
//    cl /nologo /std:c++17 /O2 /EHsc /utf-8 /W4 driftwatch.cpp /Fe:driftwatch.exe
//
//  Sem dependências externas (biblioteca padrão + Win32 p/ UTF-8 e cores).
// ============================================================================

#include <algorithm>
#include <cctype>
#include <chrono>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <sstream>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <utility>
#include <vector>

#ifdef _WIN32
  #define WIN32_LEAN_AND_MEAN
  #define NOMINMAX
  #include <windows.h>
  #include <io.h>
#else
  #include <unistd.h>
  #include <strings.h>
#endif

namespace fs = std::filesystem;

namespace {

// ------------------------------------------------------------------ constantes
constexpr const char* kAppName = "driftwatch";
constexpr const char* kVersion = "1.1.0";
constexpr const char* kMagic   = "DRIFTWATCH-SNAPSHOT";
constexpr int         kFormat  = 1;

#ifdef _WIN32
constexpr char kSep = '\\';
#else
constexpr char kSep = '/';
#endif

// -------------------------------------------------------------------- erros
struct CliError : std::runtime_error {
    explicit CliError(const std::string& msg) : std::runtime_error(msg) {}
};

// ------------------------------------------------------- conversões de texto
#ifdef _WIN32
std::string wideToUtf8(const std::wstring& w) {
    if (w.empty()) return {};
    int n = ::WideCharToMultiByte(CP_UTF8, 0, w.c_str(), (int)w.size(), nullptr, 0, nullptr, nullptr);
    std::string s((size_t)n, '\0');
    ::WideCharToMultiByte(CP_UTF8, 0, w.c_str(), (int)w.size(), &s[0], n, nullptr, nullptr);
    return s;
}
std::wstring utf8ToWide(const std::string& u) {
    if (u.empty()) return {};
    int n = ::MultiByteToWideChar(CP_UTF8, 0, u.c_str(), (int)u.size(), nullptr, 0);
    std::wstring w((size_t)n, L'\0');
    ::MultiByteToWideChar(CP_UTF8, 0, u.c_str(), (int)u.size(), &w[0], n);
    return w;
}
#endif

fs::path toPath(const std::string& utf8) {
#ifdef _WIN32
    return fs::path(utf8ToWide(utf8));
#else
    return fs::path(utf8);
#endif
}

std::string pathToUtf8(const fs::path& p) {
#ifdef _WIN32
    return wideToUtf8(p.wstring());
#else
    return p.string();
#endif
}

#ifdef _WIN32
bool isReparsePoint(const fs::path& p) {
    const DWORD attrs = ::GetFileAttributesW(p.c_str());
    return attrs != INVALID_FILE_ATTRIBUTES &&
           (attrs & FILE_ATTRIBUTE_REPARSE_POINT) != 0;
}
#endif

std::string toLower(std::string s) {
    for (char& c : s) c = (char)std::tolower((unsigned char)c);
    return s;
}

// ------------------------------------------------------------- utilitários
std::string escapeField(const std::string& s) {
    std::string o; o.reserve(s.size());
    for (char c : s) {
        switch (c) {
            case '\\': o += "\\\\"; break;
            case '\t': o += "\\t";  break;
            case '\r': o += "\\r";  break;
            case '\n': o += "\\n";  break;
            default:   o += c;
        }
    }
    return o;
}

bool unescapeField(const std::string& s, std::string* out) {
    out->clear(); out->reserve(s.size());
    for (size_t i = 0; i < s.size(); ++i) {
        char c = s[i];
        if (c == '\\') {
            if (++i >= s.size()) return false;
            switch (s[i]) {
                case '\\': *out += '\\'; break;
                case 't':  *out += '\t'; break;
                case 'r':  *out += '\r'; break;
                case 'n':  *out += '\n'; break;
                default: return false;
            }
        } else *out += c;
    }
    return true;
}

std::vector<std::string> splitTab(const std::string& line) {
    std::vector<std::string> out;
    size_t start = 0;
    for (;;) {
        size_t t = line.find('\t', start);
        if (t == std::string::npos) { out.push_back(line.substr(start)); break; }
        out.push_back(line.substr(start, t - start));
        start = t + 1;
    }
    return out;
}

bool parseUll(const std::string& s, uint64_t& out) {
    if (s.empty()) return false;
    char* end = nullptr;
    unsigned long long v = std::strtoull(s.c_str(), &end, 10);
    if (!end || *end != '\0') return false;
    out = (uint64_t)v;
    return true;
}

bool parseBytes(const std::string& in, uint64_t& out) {
    std::string s;
    for (char c : in) if (!std::isspace((unsigned char)c)) s += c;
    s = toLower(s);
    uint64_t mult = 1;
    if (!s.empty()) {
        const char last = s.back();
        if      (last == 'k') { mult = 1ull << 10; s.pop_back(); }
        else if (last == 'm') { mult = 1ull << 20; s.pop_back(); }
        else if (last == 'g') { mult = 1ull << 30; s.pop_back(); }
        else if (last == 't') { mult = 1ull << 40; s.pop_back(); }
    }
    if (s.empty()) return false;
    for (char c : s) if (!std::isdigit((unsigned char)c)) return false;
    unsigned long long v = 0;
    try { v = std::stoull(s); } catch (...) { return false; }
    if ((uint64_t)v > UINT64_MAX / mult) return false;
    out = (uint64_t)v * mult;
    return true;
}

std::string human(uint64_t b) {
    static const char* const kUnits[] = { "B", "KiB", "MiB", "GiB", "TiB", "PiB" };
    double v = (double)b;
    int u = 0;
    while (v >= 1024.0 && u < 5) { v /= 1024.0; ++u; }
    char buf[48];
    if (u == 0)
        std::snprintf(buf, sizeof(buf), "%llu B", (unsigned long long)b);
    else if (v >= 100.0)
        std::snprintf(buf, sizeof(buf), "%.0f %s", v, kUnits[u]);
    else
        std::snprintf(buf, sizeof(buf), "%.1f %s", v, kUnits[u]);
    return buf;
}

std::string humanDeltaBytes(long long d) {
    const uint64_t mag = d < 0 ? (uint64_t)(-(d + 1)) + 1 : (uint64_t)d;
    return (d < 0 ? "-" : "+") + human(mag);
}

std::string groupNum(uint64_t v) {
    std::string s = std::to_string(v);
    int pos = (int)s.size() - 3;
    while (pos > 0) { s.insert((size_t)pos, "."); pos -= 3; }
    return s;
}

std::string humanDeltaCount(long long v) {
    const uint64_t mag = v < 0 ? (uint64_t)(-(v + 1)) + 1 : (uint64_t)v;
    return (v < 0 ? "-" : "+") + groupNum(mag);
}

std::string padLeft (const std::string& s, size_t w) { return s.size() >= w ? s : std::string(w - s.size(), ' ') + s; }
std::string padRight(const std::string& s, size_t w) { return s.size() >= w ? s : s + std::string(w - s.size(), ' '); }

std::string truncateLeft(const std::string& s, size_t maxW) {
    if (s.size() <= maxW) return s;
    if (maxW <= 3) return s.substr(s.size() - maxW);
    return "..." + s.substr(s.size() - (maxW - 3));
}

std::string isoUtcNow() {
    std::time_t t = std::time(nullptr);
    std::tm tmv{};
#ifdef _WIN32
    if (gmtime_s(&tmv, &t) != 0) tmv = std::tm{};
#else
    gmtime_r(&t, &tmv);
#endif
    char buf[32];
    std::snprintf(buf, sizeof(buf), "%04d-%02d-%02dT%02d:%02d:%02dZ",
                  tmv.tm_year + 1900, tmv.tm_mon + 1, tmv.tm_mday,
                  tmv.tm_hour, tmv.tm_min, tmv.tm_sec);
    return buf;
}

std::string localTimestampForFile() {
    std::time_t t = std::time(nullptr);
    std::tm tmv{};
#ifdef _WIN32
    if (localtime_s(&tmv, &t) != 0) tmv = std::tm{};
#else
    localtime_r(&t, &tmv);
#endif
    char buf[24];
    std::snprintf(buf, sizeof(buf), "%04d%02d%02d-%02d%02d%02d",
                  tmv.tm_year + 1900, tmv.tm_mon + 1, tmv.tm_mday,
                  tmv.tm_hour, tmv.tm_min, tmv.tm_sec);
    return buf;
}

std::string sanitizeRootForFile(const std::string& root) {
    std::string s;
    for (char c : root) {
        if (std::isalnum((unsigned char)c)) s += (char)std::tolower((unsigned char)c);
        else if (s.empty() || s.back() != '-') s += '-';
    }
    while (!s.empty() && s.back() == '-') s.pop_back();
    return s;
}

// ------------------------------------------------------------- console/cores
void setupConsole() {
#ifdef _WIN32
    ::SetConsoleOutputCP(CP_UTF8);
    HANDLE h = ::GetStdHandle(STD_OUTPUT_HANDLE);
    DWORD mode = 0;
    if (h != INVALID_HANDLE_VALUE && ::GetConsoleMode(h, &mode))
        ::SetConsoleMode(h, mode | ENABLE_VIRTUAL_TERMINAL_PROCESSING);
#endif
}

bool stdoutIsConsole() {
#ifdef _WIN32
    return _isatty(_fileno(stdout)) != 0;
#else
    return ::isatty(::fileno(stdout)) != 0;
#endif
}

int consoleWidth() {
    int w = 100;
#ifdef _WIN32
    CONSOLE_SCREEN_BUFFER_INFO info{};
    if (::GetConsoleScreenBufferInfo(::GetStdHandle(STD_OUTPUT_HANDLE), &info)) {
        int cw = info.srWindow.Right - info.srWindow.Left + 1;
        if (cw >= 40 && cw <= 300) w = cw;
    }
#endif
    return w;
}

bool colorAuto(bool noColorFlag) {
    if (noColorFlag) return false;
#ifdef _WIN32
    {
        char* noColorValue = nullptr;
        size_t noColorLen = 0;
        if (_dupenv_s(&noColorValue, &noColorLen, "NO_COLOR") == 0 && noColorValue != nullptr) {
            std::free(noColorValue);
            return false;
        }
        std::free(noColorValue);
    }
#else
    if (std::getenv("NO_COLOR") != nullptr) return false;
#endif
    return stdoutIsConsole();
}

struct Style {
    bool on = false;
    std::string reset, bold, dim, red, green, yellow, cyan;
};

Style makeStyle(bool enabled) {
    Style s;
    s.on     = enabled;
    s.reset  = enabled ? "\x1b[0m" : "";
    s.bold   = enabled ? "\x1b[1m" : "";
    s.dim    = enabled ? "\x1b[2m" : "";
    s.red    = enabled ? "\x1b[31m" : "";
    s.green  = enabled ? "\x1b[32m" : "";
    s.yellow = enabled ? "\x1b[33m" : "";
    s.cyan   = enabled ? "\x1b[36m" : "";
    return s;
}

std::string paint(const Style& st, const std::string& code, const std::string& text) {
    return st.on ? (code + text + st.reset) : text;
}

std::string paintDelta(const Style& st, long long v, const std::string& text) {
    if (!st.on) return text;
    if (v > 0) return st.red + text + st.reset;
    if (v < 0) return st.green + text + st.reset;
    return st.dim + text + st.reset;
}

// ---------------------------------------------------------------- snapshot
struct DirStat { uint64_t bytes = 0; uint64_t files = 0; };

struct Snapshot {
    std::string rootUtf8;
    std::string createdIso;
    uint64_t minFileSize = 4ull << 20;
    uint64_t totalBytes  = 0;
    uint64_t totalFiles  = 0;
    uint64_t errors      = 0;
    std::vector<std::string> excludes;
    std::unordered_map<std::string, DirStat>   dirs;   // rel -> agregado (recursivo)
    std::unordered_map<std::string, uint64_t>  files;  // rel -> bytes (>= minFileSize)
};

bool saveSnapshot(const Snapshot& s, const fs::path& file, std::string& err) {
    std::error_code ec;
    const fs::path parent = file.parent_path();
    if (!parent.empty()) fs::create_directories(parent, ec);

    std::ofstream f(file, std::ios::binary | std::ios::trunc);
    if (!f) { err = "nao foi possivel gravar: " + pathToUtf8(file); return false; }

    std::ostringstream o;
    o << kMagic << '\t' << kFormat << '\n';
    o << "root\t"        << escapeField(s.rootUtf8) << '\n';
    o << "created\t"     << s.createdIso   << '\n';
    o << "minFileSize\t" << s.minFileSize  << '\n';
    o << "totalBytes\t"  << s.totalBytes   << '\n';
    o << "totalFiles\t"  << s.totalFiles   << '\n';
    o << "errors\t"      << s.errors       << '\n';
    for (const std::string& x : s.excludes) o << "X\t" << escapeField(x) << '\n';

    std::vector<std::string> keys;
    keys.reserve(s.dirs.size());
    for (const auto& kv : s.dirs) keys.push_back(kv.first);
    std::sort(keys.begin(), keys.end());
    for (const std::string& k : keys) {
        const DirStat& d = s.dirs.find(k)->second;
        o << "D\t" << escapeField(k) << '\t' << d.bytes << '\t' << d.files << '\n';
    }
    keys.clear();
    keys.reserve(s.files.size());
    for (const auto& kv : s.files) keys.push_back(kv.first);
    std::sort(keys.begin(), keys.end());
    for (const std::string& k : keys)
        o << "F\t" << escapeField(k) << '\t' << s.files.find(k)->second << '\n';
    o << "END\n";

    const std::string blob = o.str();
    f.write(blob.data(), (std::streamsize)blob.size());
    f.flush();
    if (!f) { err = "falha ao gravar dados em: " + pathToUtf8(file); return false; }
    return true;
}

bool loadSnapshot(const fs::path& file, Snapshot& s, std::string& err) {
    std::ifstream f(file, std::ios::binary);
    if (!f) { err = "nao foi possivel abrir: " + pathToUtf8(file); return false; }
    std::ostringstream buf;
    buf << f.rdbuf();
    const std::string data = buf.str();

    s = Snapshot{};
    size_t pos = 0;
    bool first = true;
    bool sawEnd = false;
    while (pos < data.size()) {
        const size_t nl = data.find('\n', pos);
        std::string line = data.substr(pos, (nl == std::string::npos ? data.size() : nl) - pos);
        pos = (nl == std::string::npos) ? data.size() : nl + 1;
        if (!line.empty() && line.back() == '\r') line.pop_back();
        if (line.empty()) continue;

        if (first) {
            first = false;
            const std::vector<std::string> hdr = splitTab(line);
            if (hdr.size() != 2 || hdr[0] != kMagic) {
                err = "arquivo nao e um snapshot do driftwatch: " + pathToUtf8(file);
                return false;
            }
            uint64_t fmt = 0;
            if (!parseUll(hdr[1], fmt) || fmt != (uint64_t)kFormat) {
                err = "versao de snapshot nao suportada: " + pathToUtf8(file);
                return false;
            }
            continue;
        }
        if (line == "END") { sawEnd = true; break; }

        const std::vector<std::string> fl = splitTab(line);
        if (fl.empty()) continue;
        const std::string& tag = fl[0];

        if (tag == "root" && fl.size() >= 2) {
            if (!unescapeField(fl[1], &s.rootUtf8)) { err = "campo root invalido"; return false; }
        }
        else if (tag == "created"     && fl.size() >= 2) s.createdIso = fl[1];
        else if (tag == "minFileSize" && fl.size() >= 2) (void)parseUll(fl[1], s.minFileSize);
        else if (tag == "totalBytes"  && fl.size() >= 2) (void)parseUll(fl[1], s.totalBytes);
        else if (tag == "totalFiles"  && fl.size() >= 2) (void)parseUll(fl[1], s.totalFiles);
        else if (tag == "errors"      && fl.size() >= 2) (void)parseUll(fl[1], s.errors);
        else if (tag == "X" && fl.size() >= 2) {
            std::string x;
            if (unescapeField(fl[1], &x)) s.excludes.push_back(x);
        }
        else if (tag == "D" && fl.size() >= 4) {
            std::string key;
            if (!unescapeField(fl[1], &key)) { err = "linha D invalida"; return false; }
            DirStat d;
            (void)parseUll(fl[2], d.bytes);
            (void)parseUll(fl[3], d.files);
            s.dirs.emplace(std::move(key), d);
        }
        else if (tag == "F" && fl.size() >= 3) {
            std::string key;
            if (!unescapeField(fl[1], &key)) { err = "linha F invalida"; return false; }
            uint64_t b = 0;
            (void)parseUll(fl[2], b);
            s.files.emplace(std::move(key), b);
        }
        // tags desconhecidas sao ignoradas (compatibilidade futura)
    }
    if (first || !sawEnd) { err = "snapshot vazio ou corrompido: " + pathToUtf8(file); return false; }
    return true;
}

// ---------------------------------------------------------------- varredura
#ifdef _WIN32
std::string relKey(const fs::path& p, const std::wstring& rootW) {
    const std::wstring w = p.wstring();
    if (w.size() >= rootW.size() && _wcsnicmp(w.c_str(), rootW.c_str(), rootW.size()) == 0) {
        size_t off = rootW.size();
        if (off < w.size() && w[off] == L'\\') ++off;
        return wideToUtf8(w.substr(off));
    }
    return wideToUtf8(w);
}
#else
std::string relKey(const fs::path& p, const std::string& rootS) {
    const std::string s = p.string();
    if (s.size() >= rootS.size() && strncasecmp(s.c_str(), rootS.c_str(), rootS.size()) == 0) {
        size_t off = rootS.size();
        if (off < s.size() && s[off] == '/') ++off;
        return s.substr(off);
    }
    return s;
}
#endif

fs::path normalizeRoot(const fs::path& in, std::string& err) {
    std::error_code ec;
    fs::path p = fs::absolute(in, ec);
    if (ec) { err = "caminho invalido: " + pathToUtf8(in); return {}; }
    const fs::path canon = fs::weakly_canonical(p, ec);
    if (!ec) p = canon;
#ifdef _WIN32
    std::wstring w = p.wstring();
    for (wchar_t& c : w) if (c == L'/') c = L'\\';
    while (w.size() > 3 && w.back() == L'\\') w.pop_back();
    if (w.size() == 2 && w[1] == L':') w.push_back(L'\\');
    return fs::path(w);
#else
    std::string s = p.string();
    while (s.size() > 1 && s.back() == '/') s.pop_back();
    if (s.empty()) s = "/";
    return fs::path(s);
#endif
}

// Varre a árvore e popula o snapshot:
//  - dirs: bytes/arquivos acumulados por diretório (inclui subdiretórios)
//  - files: arquivos individuais >= minFileSize (para achar os culpados)
bool scanTree(const fs::path& root,
              uint64_t minFileSize,
              const std::vector<std::string>& excludesLower,
              const fs::path& skipFile,
              bool quiet,
              Snapshot& out)
{
    out = Snapshot{};
    out.minFileSize = minFileSize;
    out.excludes    = excludesLower;
    out.rootUtf8    = pathToUtf8(root);

#ifdef _WIN32
    const std::wstring rootKey = root.wstring();
#else
    const std::string  rootKey = root.string();
#endif

    uint64_t filesSeen = 0, bytesSeen = 0, errors = 0, entries = 0;
    out.dirs[""]; // raiz

    const auto t0 = std::chrono::steady_clock::now();
    std::error_code ec;
    fs::recursive_directory_iterator it(root, fs::directory_options::skip_permission_denied, ec);
    if (ec) {
        std::fprintf(stderr, "erro: nao foi possivel varrer '%s': %s\n",
                     pathToUtf8(root).c_str(), ec.message().c_str());
        out.errors = 1;
        return false;
    }

    for (fs::recursive_directory_iterator end; it != end;) {
        std::error_code e;
        const fs::directory_entry ent = *it;
        const fs::path p = ent.path();

        if (skipFile.empty() || p != skipFile) {
            const fs::file_type st = ent.symlink_status(e).type();
            if (e) { ++errors; e.clear(); }

#ifdef _WIN32
            const bool reparseLink =
                (st == fs::file_type::symlink) || isReparsePoint(p);
#else
            const bool reparseLink = (st == fs::file_type::symlink);
#endif

            const std::string nameLow = toLower(pathToUtf8(p.filename()));
            bool excluded = false;
            for (const std::string& x : excludesLower)
                if (x == nameLow) { excluded = true; break; }

            bool descend = false;

            if (!reparseLink && !excluded && st == fs::file_type::directory) {
                descend = true;
                out.dirs[relKey(p, rootKey)]; // registra mesmo que ainda vazia
            }
            else if (!reparseLink && !excluded && st == fs::file_type::regular) {
                const uintmax_t szRaw = ent.file_size(e);
                if (e) {
                    ++errors;
                    e.clear();
                } else {
                    const uint64_t sz = static_cast<uint64_t>(szRaw);
                    ++filesSeen;
                    bytesSeen += sz;

                    const std::string rel = relKey(p, rootKey);
                    if (sz >= minFileSize) out.files.emplace(rel, sz);

                    // acumula em todos os ancestrais até a raiz
                    fs::path dir = p.parent_path();
                    for (;;) {
                        const std::string relD = relKey(dir, rootKey);
                        DirStat& d = out.dirs[relD];
                        d.bytes += sz;
                        d.files += 1;
                        if (relD.empty()) break;
                        fs::path parent = dir.parent_path();
                        if (parent == dir) break;
                        dir = std::move(parent);
                    }
                }
            }

            if (!descend) it.disable_recursion_pending();
        } else {
            it.disable_recursion_pending();
        }

        it.increment(e);
        if (e) {
            ++errors;
            e.clear();
            it.pop(e);
            if (e) break;
        }

        ++entries;
        if (!quiet && (entries % 16384) == 0) {
            const double secs =
                std::chrono::duration<double>(std::chrono::steady_clock::now() - t0).count();
            std::fprintf(stderr, "\r  varrendo... %s arquivos | %s | %llu erros | %.0fs   ",
                         groupNum(filesSeen).c_str(), human(bytesSeen).c_str(),
                         (unsigned long long)errors, secs);
            std::fflush(stderr);
        }
    }

    if (!quiet) std::fprintf(stderr, "\r%70s\r", "");

    out.totalBytes = bytesSeen;
    out.totalFiles = filesSeen;
    out.errors     = errors;
    return true;
}

// ------------------------------------------------------------------- diff
struct DirRow  { std::string key; long long dTotal, dSelf, dFiles; };
struct FileRow { std::string key; long long dBytes; uint64_t nowBytes; };

// "próprio" = bytes de arquivos diretos do diretório (sem subdiretórios)
std::unordered_map<std::string, long long> selfBytesOf(
        const std::unordered_map<std::string, DirStat>& dirs)
{
    std::unordered_map<std::string, long long> childBytes;
    childBytes.reserve(dirs.size() * 2);
    for (const auto& kv : dirs) {
        const std::string& k = kv.first;
        if (k.empty()) continue;
        const size_t pos = k.find_last_of(kSep);
        const std::string parent = (pos == std::string::npos) ? std::string() : k.substr(0, pos);
        childBytes[parent] += (long long)kv.second.bytes;
    }
    std::unordered_map<std::string, long long> self;
    self.reserve(dirs.size() * 2);
    for (const auto& kv : dirs) {
        auto it = childBytes.find(kv.first);
        const long long cb = (it == childBytes.end()) ? 0 : it->second;
        self[kv.first] = (long long)kv.second.bytes - cb;
    }
    return self;
}

std::vector<DirRow> dirDeltas(const Snapshot& oldS, const Snapshot& newS) {
    const auto selfO = selfBytesOf(oldS.dirs);
    const auto selfN = selfBytesOf(newS.dirs);
    auto at = [](const std::unordered_map<std::string, long long>& m,
                 const std::string& k) -> long long {
        auto it = m.find(k);
        return it == m.end() ? 0 : it->second;
    };

    std::vector<DirRow> rows;
    rows.reserve(newS.dirs.size() + 16);

    for (const auto& kv : newS.dirs) {
        long long nb = (long long)kv.second.bytes;
        long long nf = (long long)kv.second.files;
        long long ns = at(selfN, kv.first);
        long long ob = 0, ofl = 0, osl = 0;
        auto it = oldS.dirs.find(kv.first);
        if (it != oldS.dirs.end()) {
            ob  = (long long)it->second.bytes;
            ofl = (long long)it->second.files;
        }
        osl = at(selfO, kv.first);
        rows.push_back({ kv.first, nb - ob, ns - osl, nf - ofl });
    }
    for (const auto& kv : oldS.dirs) {
        if (newS.dirs.count(kv.first)) continue;
        rows.push_back({ kv.first,
                         -(long long)kv.second.bytes,
                         -at(selfO, kv.first),
                         -(long long)kv.second.files });
    }

    std::sort(rows.begin(), rows.end(), [](const DirRow& a, const DirRow& b) {
        if (a.dTotal != b.dTotal) return a.dTotal > b.dTotal;
        return a.dSelf > b.dSelf;
    });
    return rows;
}

void printRule(const Style& st, int width) {
    std::cout << paint(st, st.dim, std::string((size_t)(width < 110 ? width : 110), '-')) << "\n";
}

void printUsage() {
    std::cout << "\n"
              << kAppName << " " << kVersion << " - monitor de crescimento de disco via snapshots\n\n"
        "Uso:\n"
        "  driftwatch snap <dir> [opcoes]         captura o estado atual de <dir>\n"
        "  driftwatch diff <snapshot> [dir] [opcoes]\n"
        "                                         compara o estado atual com o snapshot\n"
        "  driftwatch help | version\n\n"
        "Opcoes de snap:\n"
        "  -o, --out <arquivo>      arquivo de saida (padrao: driftwatch-<raiz>-<data>.dwsnap)\n"
        "      --min-file-size <N>  rastreia arquivos individuais >= N (padrao: 4M)\n"
        "  -x, --exclude <nome>     ignora itens com esse nome (repetivel)\n"
        "      --force              sobrescreve o arquivo de saida se existir\n"
        "  -q, --quiet              sem progresso na tela\n"
        "      --no-color           desativa cores ANSI\n\n"
        "Opcoes de diff:\n"
        "      --top <N>            itens por secao (padrao: 15)\n"
        "      --min-growth <N>     so lista crescimentos >= N bytes\n"
        "      --fail-above <N>     sai com codigo 3 se o crescimento total exceder N\n"
        "  -q, --quiet              sem progresso na tela\n"
        "      --no-color           desativa cores ANSI\n\n"
        "Tamanhos aceitam sufixo binario: K, M, G, T (ex.: 4M, 1G, 512K).\n\n"
        "Fluxo tipico:\n"
        "  driftwatch snap C:\\Dados\n"
        "  ... tempo passa ...\n"
        "  driftwatch diff driftwatch-c--dados-20240102-093000.dwsnap\n\n"
        "Codigos de saida: 0 ok | 2 erro de uso/execucao | 3 crescimento acima de --fail-above\n\n";
}

// ------------------------------------------------------------------ comandos
int cmdSnap(const std::vector<std::string>& a) {
    std::vector<std::string> pos;
    std::string outArg;
    uint64_t minFileSize = 4ull << 20;
    std::vector<std::string> excludes;
    bool force = false, quiet = false, noColor = false;

    for (size_t i = 1; i < a.size(); ++i) {
        const std::string& s = a[i];
        auto val = [&](const char* flag) -> std::string {
            if (i + 1 >= a.size()) throw CliError(std::string("faltou valor para '") + flag + "'");
            return a[++i];
        };
        if      (s == "-o" || s == "--out") outArg = val("--out");
        else if (s == "--min-file-size") {
            if (!parseBytes(val("--min-file-size"), minFileSize) || minFileSize == 0)
                throw CliError("valor invalido em --min-file-size");
        }
        else if (s == "-x" || s == "--exclude") excludes.push_back(toLower(val("--exclude")));
        else if (s == "--force")                 force = true;
        else if (s == "-q" || s == "--quiet")    quiet = true;
        else if (s == "--no-color")              noColor = true;
        else if (s == "-h" || s == "--help")   { printUsage(); return 0; }
        else if (!s.empty() && s[0] == '-')      throw CliError("opcao desconhecida: '" + s + "'");
        else pos.push_back(s);
    }

    if (pos.empty())  throw CliError("informe o diretorio raiz (ex.: driftwatch snap C:\\Dados)");
    if (pos.size() > 1) throw CliError("informe apenas um diretorio raiz");

    std::string err;
    const fs::path root = normalizeRoot(toPath(pos[0]), err);
    if (!err.empty()) throw CliError(err);
    {
        std::error_code ec;
        if (!fs::is_directory(root, ec)) throw CliError("diretorio invalido: " + pathToUtf8(root));
    }

    fs::path outPath = outArg.empty()
        ? toPath(std::string("driftwatch-") + sanitizeRootForFile(pathToUtf8(root)) +
                 "-" + localTimestampForFile() + ".dwsnap")
        : toPath(outArg);

    if (!force) {
        std::error_code ec;
        if (fs::exists(outPath, ec) && !ec)
            throw CliError("arquivo ja existe: " + pathToUtf8(outPath) + " (use --force)");
    }

    std::error_code ec0;
    fs::path skipFile = fs::weakly_canonical(outPath, ec0);
    if (ec0) skipFile = outPath;

    Snapshot snap;
    if (!scanTree(root, minFileSize, excludes, skipFile, quiet, snap))
        throw CliError("falha ao varrer: " + pathToUtf8(root));
    snap.createdIso = isoUtcNow();

    if (!saveSnapshot(snap, outPath, err)) throw CliError(err);

    // ---- resumo
    const Style st = makeStyle(colorAuto(noColor));
    const int width = consoleWidth();
    auto line = [&](const std::string& k, const std::string& v) {
        std::cout << "  " << paint(st, st.dim, padRight(k, 14)) << v << "\n";
    };

    std::cout << "\n" << paint(st, st.bold, "Snapshot gravado com sucesso") << "\n";
    printRule(st, width);
    line("Arquivo:", pathToUtf8(outPath));
    line("Raiz:", snap.rootUtf8);
    line("Criado em:", snap.createdIso);
    line("Total:", human(snap.totalBytes) + " em " + groupNum(snap.totalFiles) +
                   " arquivos (" + groupNum(snap.dirs.size()) + " diretorios)");
    line("Rastreados:", groupNum(snap.files.size()) + " arquivos >= " + human(snap.minFileSize) +
                       " (ajustavel com --min-file-size)");
    std::string exStr;
    for (size_t i = 0; i < snap.excludes.size(); ++i) {
        if (i) exStr += ", ";
        exStr += snap.excludes[i];
    }
    line("Exclusoes:", exStr.empty() ? "-" : exStr);
    if (snap.errors)
        line("Erros:", groupNum(snap.errors) + " itens nao legiveis (permissao/reparse)");

    // maiores diretorios agora (baseline)
    std::vector<std::pair<uint64_t, const std::string*>> top;
    for (const auto& kv : snap.dirs)
        if (!kv.first.empty()) top.push_back({ kv.second.bytes, &kv.first });
    std::sort(top.begin(), top.end(),
              [](const std::pair<uint64_t, const std::string*>& x,
                 const std::pair<uint64_t, const std::string*>& y) { return x.first > y.first; });

    std::cout << "\n" << paint(st, st.bold, "Maiores diretorios agora (top 5, inclui subdiretorios)") << "\n";
    for (size_t i = 0; i < top.size() && i < 5; ++i)
        std::cout << "  " << paint(st, st.cyan, padLeft(human(top[i].first), 12)) << "  "
                  << truncateLeft(*top[i].second, (size_t)(width - 18 > 24 ? width - 18 : 24)) << "\n";

    std::cout << "\n" << paint(st, st.dim,
        "Proximo passo: depois de um tempo rode  driftwatch diff <arquivo>  para ver o que cresceu.") << "\n\n";
    return 0;
}

int cmdDiff(const std::vector<std::string>& a) {
    std::vector<std::string> pos;
    int top = 15;
    uint64_t minGrowth = 0, failAbove = 0;
    bool haveFailAbove = false, quiet = false, noColor = false;

    for (size_t i = 1; i < a.size(); ++i) {
        const std::string& s = a[i];
        auto val = [&](const char* flag) -> std::string {
            if (i + 1 >= a.size()) throw CliError(std::string("faltou valor para '") + flag + "'");
            return a[++i];
        };
        if      (s == "--top") {
            try { top = std::stoi(val("--top")); } catch (...) { throw CliError("--top invalido"); }
            if (top < 1) throw CliError("--top deve ser >= 1");
        }
        else if (s == "--min-growth") {
            if (!parseBytes(val("--min-growth"), minGrowth)) throw CliError("--min-growth invalido");
        }
        else if (s == "--fail-above") {
            if (!parseBytes(val("--fail-above"), failAbove)) throw CliError("--fail-above invalido");
            haveFailAbove = true;
        }
        else if (s == "-q" || s == "--quiet") quiet = true;
        else if (s == "--no-color")           noColor = true;
        else if (s == "-h" || s == "--help") { printUsage(); return 0; }
        else if (!s.empty() && s[0] == '-')   throw CliError("opcao desconhecida: '" + s + "'");
        else pos.push_back(s);
    }

    if (pos.empty()) throw CliError("informe o snapshot (ex.: driftwatch diff snap.dwsnap)");
    if (pos.size() > 2) throw CliError("argumentos demais");

    Snapshot oldS;
    std::string err;
    const fs::path snapPath = toPath(pos[0]);
    if (!loadSnapshot(snapPath, oldS, err)) throw CliError(err);

    std::string rootStr = pos.size() == 2 ? pos[1] : oldS.rootUtf8;
    const fs::path root = normalizeRoot(toPath(rootStr), err);
    if (!err.empty()) throw CliError(err);
    {
        std::error_code ec;
        if (!fs::is_directory(root, ec)) throw CliError("diretorio invalido: " + pathToUtf8(root));
    }

    if (!quiet)
        std::fprintf(stderr, "  varrendo estado atual (rastreando arquivos >= %s)...\n",
                     human(oldS.minFileSize).c_str());

    Snapshot cur;
    if (!scanTree(root, oldS.minFileSize, oldS.excludes, snapPath, quiet, cur))
        throw CliError("falha ao varrer: " + pathToUtf8(root));
    cur.createdIso = isoUtcNow();

    const Style st = makeStyle(colorAuto(noColor));
    const int width = consoleWidth();

    // ---- deltas
    const long long dTotal = (long long)cur.totalBytes - (long long)oldS.totalBytes;
    std::vector<DirRow> dirs = dirDeltas(oldS, cur);

    std::vector<FileRow> grown, added, removed;
    grown.reserve(cur.files.size() / 8 + 16);
    for (const auto& kv : cur.files) {
        auto it = oldS.files.find(kv.first);
        if (it == oldS.files.end())
            added.push_back({ kv.first, (long long)kv.second, kv.second });
        else if ((long long)kv.second != (long long)it->second)
            grown.push_back({ kv.first, (long long)kv.second - (long long)it->second, kv.second });
    }
    for (const auto& kv : oldS.files)
        if (cur.files.find(kv.first) == cur.files.end())
            removed.push_back({ kv.first, -(long long)kv.second, 0 });

    auto byDesc = [](const FileRow& x, const FileRow& y) { return x.dBytes > y.dBytes; };
    auto byAsc  = [](const FileRow& x, const FileRow& y) { return x.dBytes < y.dBytes; };
    std::sort(grown.begin(),   grown.end(),   byDesc);
    std::sort(added.begin(),   added.end(),   byDesc);
    std::sort(removed.begin(), removed.end(), byAsc);

    long long growingDirs = 0, shrinkingDirs = 0;
    for (const DirRow& r : dirs) {
        if (r.dTotal > 0) ++growingDirs;
        else if (r.dTotal < 0) ++shrinkingDirs;
    }
    uint64_t addedBytes = 0, removedBytes = 0, grownPos = 0, grownNeg = 0;
    for (const FileRow& r : added)   addedBytes   += (uint64_t)r.dBytes;
    for (const FileRow& r : removed) removedBytes += (uint64_t)(-r.dBytes);
    for (const FileRow& r : grown) {
        if (r.dBytes > 0) grownPos += (uint64_t)r.dBytes;
        else              grownNeg += (uint64_t)(-r.dBytes);
    }

    // ---- relatorio
    std::cout << "\n" << paint(st, st.bold,
        std::string("POLYDEV | WX-TOOLS - ") + kAppName + " " + kVersion + " - relatorio de crescimento") << "\n";
    printRule(st, width);
    auto line = [&](const std::string& k, const std::string& v) {
        std::cout << "  " << paint(st, st.dim, padRight(k, 15)) << v << "\n";
    };
    line("Snapshot:", pos[0]);
    line("Criado em:", oldS.createdIso);
    line("Raiz:", oldS.rootUtf8 + (pathToUtf8(root) != oldS.rootUtf8
                                   ? "   (varrido agora: " + pathToUtf8(root) + ")" : ""));
    line("Comparado em:", isoUtcNow());
    line("Antes:", human(oldS.totalBytes) + " em " + groupNum(oldS.totalFiles) +
                   " arquivos (" + groupNum(oldS.dirs.size()) + " diretorios)");
    line("Agora:", human(cur.totalBytes) + " em " + groupNum(cur.totalFiles) +
                   " arquivos (" + groupNum(cur.dirs.size()) + " diretorios)");

    std::string growth = humanDeltaBytes(dTotal);
    if (oldS.totalBytes) {
        char pctBuf[32];
        std::snprintf(pctBuf, sizeof(pctBuf), "  (%+.2f%%)",
                      100.0 * (double)dTotal / (double)oldS.totalBytes);
        growth += pctBuf;
    }
    std::cout << "  " << paint(st, st.dim, padRight("Crescimento:", 15))
              << paintDelta(st, dTotal, growth) << "\n";
    if (cur.errors || oldS.errors)
        line("Erros:", groupNum(cur.errors) + " agora / " + groupNum(oldS.errors) + " no snapshot");
    printRule(st, width);

    auto printDirRow = [&](const DirRow& r, int nameW) {
        const std::string name = r.key.empty() ? std::string("<raiz>") : r.key;
        std::cout << paintDelta(st, r.dTotal, padLeft(humanDeltaBytes(r.dTotal), 12)) << "  "
                  << paintDelta(st, r.dSelf,  padLeft(humanDeltaBytes(r.dSelf),  12)) << "  "
                  << paintDelta(st, r.dFiles, padLeft(humanDeltaCount(r.dFiles), 9))  << "  "
                  << truncateLeft(name, (size_t)nameW) << "\n";
    };

    auto dirSection = [&](int idx, const std::string& title, bool growMode) {
        std::cout << "\n" << paint(st, st.bold, "[" + std::to_string(idx) + "] " + title) << "\n";
        std::cout << paint(st, st.dim,
            "  " + padLeft("dTOTAL", 12) + "  " + padLeft("dPROPRIO", 12) + "  " +
            padLeft("dARQS", 9) + "  DIRETORIO   (dTOTAL inclui subdiretorios)") << "\n";
        const int nameW = width - 41 > 24 ? width - 41 : 24;
        int printed = 0;
        if (growMode) {
            for (const DirRow& r : dirs) {
                if (printed >= top) break;
                if (r.dTotal <= 0) break;
                if ((uint64_t)r.dTotal < minGrowth) break;
                printDirRow(r, nameW);
                ++printed;
            }
        } else {
            for (auto it = dirs.rbegin(); it != dirs.rend(); ++it) {
                if (printed >= top) break;
                if (it->dTotal >= 0) break;
                if ((uint64_t)(-it->dTotal) < minGrowth) break;
                printDirRow(*it, nameW);
                ++printed;
            }
        }
        if (!printed) std::cout << paint(st, st.dim, "  (nada a listar)") << "\n";
    };

    auto fileSection = [&](int idx, const std::string& title,
                           const std::vector<FileRow>& rows, bool filterGrowth) {
        std::cout << "\n" << paint(st, st.bold, "[" + std::to_string(idx) + "] " + title) << "\n";
        std::cout << paint(st, st.dim,
            "  " + padLeft("dTAMANHO", 12) + "  " + padLeft("ATUAL", 11) + "  ARQUIVO") << "\n";
        const int nameW = width - 29 > 24 ? width - 29 : 24;
        int printed = 0;
        for (const FileRow& r : rows) {
            if (printed >= top) break;
            if (filterGrowth && (uint64_t)r.dBytes < minGrowth) break;
            std::cout << paintDelta(st, r.dBytes, padLeft(humanDeltaBytes(r.dBytes), 12)) << "  "
                      << paintDelta(st, r.dBytes, padLeft(human(r.nowBytes), 11))       << "  "
                      << truncateLeft(r.key, (size_t)nameW) << "\n";
            ++printed;
        }
        if (!printed) std::cout << paint(st, st.dim, "  (nada a listar)") << "\n";
    };

    dirSection(1, "Diretorios que mais cresceram", true);
    if (!dirs.empty() && dirs.back().dTotal < 0)
        dirSection(2, "Diretorios que mais encolheram", false);
    if (!grown.empty())
        fileSection(3, "Principais causadores: arquivos que cresceram (>= " +
                       human(oldS.minFileSize) + ")", grown, true);
    if (!added.empty())
        fileSection(4, "Arquivos grandes novos (nao existiam no snapshot)", added, true);
    if (!removed.empty())
        fileSection(5, "Arquivos grandes removidos (espaco liberado)", removed, false);

    // ---- resumo final
    std::cout << "\n" << paint(st, st.bold, "Resumo") << "\n";
    std::cout << "  Diretorios: " << groupNum((uint64_t)growingDirs) << " crescendo, "
              << groupNum((uint64_t)shrinkingDirs) << " encolhendo\n";
    std::cout << "  Arquivos rastreados (>= " << human(oldS.minFileSize) << "): "
              << groupNum((uint64_t)grown.size())   << " cresceram (+"
              << human(grownPos) << " / -" << human(grownNeg) << "), "
              << groupNum((uint64_t)added.size())   << " novos (+"   << human(addedBytes)   << "), "
              << groupNum((uint64_t)removed.size()) << " removidos (-" << human(removedBytes) << ")\n";
    std::cout << "\n  Dica: agende 'driftwatch snap " << pathToUtf8(root)
              << "' para acompanhar periodo a periodo.\n\n";

    if (haveFailAbove && dTotal > (long long)failAbove) {
        std::fprintf(stderr, "%s\n", paint(st, st.red,
            "crescimento total " + humanDeltaBytes(dTotal) +
            " excedeu --fail-above (" + human(failAbove) + ")").c_str());
        return 3;
    }
    return 0;
}

int driftwatchMain(const std::vector<std::string>& args) {
    setupConsole();
    if (args.empty()) { printUsage(); return 0; }
    const std::string cmd = args[0];
    try {
        if (cmd == "snap") return cmdSnap(args);
        if (cmd == "diff") return cmdDiff(args);
        if (cmd == "help" || cmd == "--help" || cmd == "-h") { printUsage(); return 0; }
        if (cmd == "version" || cmd == "--version" || cmd == "-v") {
            std::cout << kAppName << " " << kVersion << "\n";
            return 0;
        }
        std::cerr << "erro: comando desconhecido: '" << cmd << "'\n";
        printUsage();
        return 2;
    } catch (const CliError& e) {
        std::cerr << "erro: " << e.what() << "\n";
        std::cerr << "use 'driftwatch help' para ver o uso correto.\n";
        return 2;
    } catch (const std::exception& e) {
        std::cerr << "erro inesperado: " << e.what() << "\n";
        return 2;
    }
}

} // namespace

#ifdef _WIN32
int wmain(int argc, wchar_t** argv) {
    std::vector<std::string> args;
    args.reserve((size_t)(argc > 1 ? argc - 1 : 0));
    for (int i = 1; i < argc; ++i) args.push_back(wideToUtf8(argv[i]));
    return driftwatchMain(args);
}
#else
int main(int argc, char** argv) {
    std::vector<std::string> args;
    args.reserve((size_t)(argc > 1 ? argc - 1 : 0));
    for (int i = 1; i < argc; ++i) args.push_back(argv[i]);
    return driftwatchMain(args);
}
#endif