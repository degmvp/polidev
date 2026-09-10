/* ============================================================================
 *  filetools.cpp — Utilitário Multiplataforma de Operações com Arquivos
 *  Compilação: C++17 | Plataformas: Linux Ubuntu 24.04 + Windows 11
 *  Autor: Gerado por OreateAI
 * ========================================================================== */

#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <map>
#include <algorithm>
#include <iomanip>
#include <chrono>
#include <functional>
#include <cstdint>
#include <cstring>
#include <cctype>

#ifdef _WIN32
  #include <windows.h>
  #include <io.h>
  #include <fcntl.h>
#else
  #include <sys/stat.h>
  #include <sys/statvfs.h>
  #include <unistd.h>
#endif

#include <filesystem>
namespace fs = std::filesystem;

// ===================== Cores ANSI no Terminal =====================
namespace color {
#ifdef _WIN32
    static bool ansi_enabled = false;
    void enable_ansi() {
        if (ansi_enabled) return;
        HANDLE h = GetStdHandle(STD_OUTPUT_HANDLE);
        DWORD mode = 0;
        if (GetConsoleMode(h, &mode)) {
            mode |= ENABLE_VIRTUAL_TERMINAL_PROCESSING;
            SetConsoleMode(h, mode);
        }
        SetConsoleOutputCP(CP_UTF8);
        ansi_enabled = true;
    }
#else
    void enable_ansi() {} // Linux já suporta ANSI nativamente
#endif

    const char* reset()   { return "\033[0m"; }
    const char* red()     { return "\033[31m"; }
    const char* green()   { return "\033[32m"; }
    const char* yellow()  { return "\033[33m"; }
    const char* blue()    { return "\033[34m"; }
    const char* magenta() { return "\033[35m"; }
    const char* cyan()    { return "\033[36m"; }
    const char* white()   { return "\033[37m"; }
    const char* bold()    { return "\033[1m"; }
    const char* dim()    { return "\033[2m"; }
}

// ===================== Barra de Progresso =====================
class ProgressBar {
    size_t current_, total_;
    int width_;
    std::string label_;
public:
    ProgressBar(const std::string& label, size_t total, int width = 40)
        : current_(0), total_(total), width_(width), label_(label) {}

    void update(size_t current) {
        current_ = current;
        float pct = total_ > 0 ? static_cast<float>(current_) / total_ : 0.0f;
        int filled = static_cast<int>(pct * width_);
        std::cout << "\r" << color::cyan() << label_ << color::reset() << " [";
        std::cout << color::green();
        for (int i = 0; i < filled; ++i) std::cout << "#";
        std::cout << color::dim();
        for (int i = filled; i < width_; ++i) std::cout << "-";
        std::cout << color::reset() << "] " << std::fixed << std::setprecision(1)
                  << (pct * 100.0f) << "%";
        std::cout << std::flush;
    }

    void done() {
        update(total_);
        std::cout << " " << color::green() << "OK" << color::reset() << "\n";
    }
};

// ===================== Parser de CLI =====================
struct Arg {
    std::string name, value;
    bool is_flag;
};

class CLIParser {
    std::string prog_name_;
    std::vector<Arg> args_;
public:
    CLIParser(const std::string& name) : prog_name_(name) {}

    void parse(int argc, char* argv[]) {
        for (int i = 1; i < argc; ++i) {
            std::string s = argv[i];
            if (s.rfind("--", 0) == 0) {
                auto eq = s.find('=');
                if (eq != std::string::npos) {
                    args_.push_back({s.substr(2, eq - 2), s.substr(eq + 1), false});
                } else if (i + 1 < argc && argv[i + 1][0] != '-') {
                    args_.push_back({s.substr(2), argv[++i], false});
                } else {
                    args_.push_back({s.substr(2), "", true});
                }
            } else if (s.rfind("-", 0) == 0 && s.size() == 2) {
                args_.push_back({s.substr(1), "", true});
            } else {
                args_.push_back({"", s, false});
            }
        }
    }

    bool has(const std::string& name) const {
        return std::any_of(args_.begin(), args_.end(),
            [&](const Arg& a) { return a.name == name; });
    }

    std::string value(const std::string& name, const std::string& def = "") const {
        for (auto& a : args_)
            if (a.name == name && !a.value.empty()) return a.value;
        return def;
    }

    std::string positional(int idx, const std::string& def = "") const {
        int c = 0;
        for (auto& a : args_)
            if (a.name.empty() && c++ == idx) return a.value;
        return def;
    }

    int pos_count() const {
        int c = 0;
        for (auto& a : args_)
            if (a.name.empty()) ++c;
        return c;
    }

    void print_help() const {
        std::cout << color::bold() << prog_name_ << color::reset()
                  << " — Utilitário Multiplataforma de Operações com Arquivos\n\n";
        std::cout << color::cyan() << "Comandos:" << color::reset() << "\n";
        std::cout << "  find       Procurar arquivos por nome, extensão, tamanho ou data\n";
        std::cout << "  clean      Limpar arquivos temporários e cache\n";
        std::cout << "  organize   Organizar arquivos por categoria (extensão)\n";
        std::cout << "  hash       Calcular hash SHA-256 e MD5 de arquivos\n\n";
        std::cout << color::cyan() << "Opções globais:" << color::reset() << "\n";
        std::cout << "  --dry-run  Simular operações sem modificar nada\n";
        std::cout << "  --dir=<p>  Diretório alvo (padrão: diretório atual)\n";
        std::cout << "  --verbose  Mostrar detalhes extras\n";
        std::cout << "  --help     Mostrar esta ajuda\n";
    }
};

// ===================== SHA-256 (Implementação Pura C++17) =====================
class SHA256 {
    static constexpr uint32_t K[64] = {
        0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,
        0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
        0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,
        0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
        0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,
        0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
        0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,
        0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
        0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,
        0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
        0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,
        0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
        0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,
        0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
        0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,
        0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2
    };
    uint32_t H[8];
    uint8_t  buf[64];
    uint64_t total_len = 0;
    size_t   buf_len  = 0;

    static uint32_t rotr(uint32_t x, int n) { return (x >> n) | (x << (32 - n)); }
    static uint32_t ch(uint32_t x, uint32_t y, uint32_t z)  { return (x & y) ^ (~x & z); }
    static uint32_t maj(uint32_t x, uint32_t y, uint32_t z) { return (x & y) ^ (x & z) ^ (y & z); }
    static uint32_t sigma0(uint32_t x) { return rotr(x,2) ^ rotr(x,13) ^ rotr(x,22); }
    static uint32_t sigma1(uint32_t x) { return rotr(x,6) ^ rotr(x,11) ^ rotr(x,25); }
    static uint32_t gamma0(uint32_t x) { return rotr(x,7) ^ rotr(x,18) ^ (x >> 3); }
    static uint32_t gamma1(uint32_t x) { return rotr(x,17) ^ rotr(x,19) ^ (x >> 10); }

    void transform(const uint8_t block[64]) {
        uint32_t W[64];
        for (int i = 0; i < 16; ++i)
            W[i] = (uint32_t(block[i*4]) << 24) | (uint32_t(block[i*4+1]) << 16) |
                    (uint32_t(block[i*4+2]) << 8) | uint32_t(block[i*4+3]);
        for (int i = 16; i < 64; ++i)
            W[i] = gamma1(W[i-2]) + W[i-7] + gamma0(W[i-15]) + W[i-16];

        uint32_t a = H[0], b = H[1], c = H[2], d = H[3];
        uint32_t e = H[4], f = H[5], g = H[6], h = H[7];

        for (int i = 0; i < 64; ++i) {
            uint32_t T1 = h + sigma1(e) + ch(e,f,g) + K[i] + W[i];
            uint32_t T2 = sigma0(a) + maj(a,b,c);
            h = g; g = f; f = e; e = d + T1;
            d = c; c = b; b = a; a = T1 + T2;
        }
        H[0] += a; H[1] += b; H[2] += c; H[3] += d;
        H[4] += e; H[5] += f; H[6] += g; H[7] += h;
    }

    void pad() {
        uint64_t total_bits = (total_len + buf_len) * 8;
        buf[buf_len++] = 0x80;
        if (buf_len > 56) {
            while (buf_len < 64) buf[buf_len++] = 0x00;
            transform(buf);
            buf_len = 0;
        }
        while (buf_len < 56) buf[buf_len++] = 0x00;
        for (int i = 7; i >= 0; --i) buf[buf_len++] = (total_bits >> (i * 8)) & 0xFF;
        transform(buf);
    }

public:
    SHA256() {
        H[0]=0x6a09e667; H[1]=0xbb67ae85; H[2]=0x3c6ef372; H[3]=0xa54ff53a;
        H[4]=0x510e527f; H[5]=0x9b05688c; H[6]=0x1f83d9ab; H[7]=0x5be0cd19;
        buf_len = 0; total_len = 0;
        std::memset(buf, 0, 64);
    }

    void update(const uint8_t* data, size_t len) {
        for (size_t i = 0; i < len; ++i) {
            buf[buf_len++] = data[i];
            if (buf_len == 64) {
                transform(buf);
                total_len += 64;
                buf_len = 0;
            }
        }
    }

    void update_file(const std::string& path) {
        std::ifstream f(path, std::ios::binary);
        if (!f) return;
        constexpr size_t BS = 65536;
        std::vector<uint8_t> block(BS);
        while (f) {
            f.read(reinterpret_cast<char*>(block.data()), BS);
            auto n = f.gcount();
            if (n > 0) update(block.data(), static_cast<size_t>(n));
        }
    }

    std::string hex_digest() {
        pad();
        std::ostringstream o;
        for (int i = 0; i < 8; ++i)
            for (int j = 3; j >= 0; --j)
                o << std::hex << std::setfill('0') << std::setw(2)
                  << (uint32_t)((H[i] >> (j * 8)) & 0xFF);
        return o.str();
    }
};

// ===================== MD5 (Implementação Pura C++17) =====================
class MD5 {
    static constexpr uint32_t T[64] = {
        0xd76aa478,0xe8c7b756,0x242070db,0xc1bdceee,
        0xf57c0faf,0x4787c62a,0xa8304613,0xfd469501,
        0x698098d8,0x8b44f7af,0xffff5bb1,0x895cd7be,
        0x6b901122,0xfd987193,0xa679438e,0x49b40821,
        0xf61e2562,0xc040b340,0x265e5a51,0xe9b6c7aa,
        0xd62f105d,0x02441453,0xd8a1e681,0xe7d3fbc8,
        0x21e1cde6,0xc33707d6,0xf4d50d87,0x455a14ed,
        0xa9e3e905,0xfcefa3f8,0x676f02d9,0x8d2a4c8a,
        0xfffa3942,0x8771f681,0x6d9d6122,0xfde5380c,
        0xa4beea44,0x4bdecfa9,0xf6bb4b60,0xbebfbc70,
        0x289b7ec6,0xeaa127fa,0xd4ef3085,0x04881d05,
        0xd9d4d039,0xe6db99e5,0x1fa27cf8,0xc4ac5665,
        0xf4292244,0x432aff97,0xab9423a7,0xfc93a039,
        0x655b59c3,0x8f0ccc92,0xffeff47d,0x85845dd1,
        0x6fa87e4f,0xfe2ce6e0,0xa3014314,0x4e0811a1,
        0xf7537e82,0xbd3af235,0x2ad7d2bb,0xeb86d391
    };
    static constexpr int s[64] = {
        7,12,17,22, 7,12,17,22, 7,12,17,22, 7,12,17,22,
        5, 9,14,20, 5, 9,14,20, 5, 9,14,20, 5, 9,14,20,
        4,11,16,23, 4,11,16,23, 4,11,16,23, 4,11,16,23,
        6,10,15,21, 6,10,15,21, 6,10,15,21, 6,10,15,21
    };
    uint32_t state[4];
    uint8_t  buf[64];
    uint64_t total_len = 0;
    size_t   buf_len  = 0;

    static uint32_t rotl(uint32_t x, int n) { return (x << n) | (x >> (32 - n)); }

    void transform(const uint8_t block[64]) {
        uint32_t M[16];
        for (int i = 0; i < 16; ++i)
            M[i] = (uint32_t(block[i*4])) | (uint32_t(block[i*4+1]) << 8) |
                   (uint32_t(block[i*4+2]) << 16) | (uint32_t(block[i*4+3]) << 24);

        uint32_t a = state[0], b = state[1], c = state[2], d = state[3];

        for (int i = 0; i < 64; ++i) {
            uint32_t f, g;
            if (i < 16)      { f = (b & c) | (~b & d); g = uint32_t(i); }
            else if (i < 32) { f = (d & b) | (~d & c); g = uint32_t((5*i + 1) % 16); }
            else if (i < 48) { f = b ^ c ^ d;           g = uint32_t((3*i + 5) % 16); }
            else             { f = c ^ (b | ~d);        g = uint32_t((7*i) % 16); }

            f = f + a + T[i] + M[g];
            a = d; d = c; c = b;
            b = b + rotl(f, s[i]);
        }
        state[0] += a; state[1] += b; state[2] += c; state[3] += d;
    }

    void pad() {
        uint64_t total_bits = (total_len + buf_len) * 8;
        buf[buf_len++] = 0x80;
        if (buf_len > 56) {
            while (buf_len < 64) buf[buf_len++] = 0x00;
            transform(buf);
            buf_len = 0;
        }
        while (buf_len < 56) buf[buf_len++] = 0x00;
        for (int i = 0; i < 8; ++i) buf[buf_len++] = (total_bits >> (i * 8)) & 0xFF;
        transform(buf);
    }

public:
    MD5() {
        state[0] = 0x67452301;
        state[1] = 0xefcdab89;
        state[2] = 0x98badcfe;
        state[3] = 0x10325476;
        buf_len = 0; total_len = 0;
        std::memset(buf, 0, 64);
    }

    void update(const uint8_t* data, size_t len) {
        for (size_t i = 0; i < len; ++i) {
            buf[buf_len++] = data[i];
            if (buf_len == 64) {
                transform(buf);
                total_len += 64;
                buf_len = 0;
            }
        }
    }

    void update_file(const std::string& path) {
        std::ifstream f(path, std::ios::binary);
        if (!f) return;
        constexpr size_t BS = 65536;
        std::vector<uint8_t> block(BS);
        while (f) {
            f.read(reinterpret_cast<char*>(block.data()), BS);
            auto n = f.gcount();
            if (n > 0) update(block.data(), static_cast<size_t>(n));
        }
    }

    std::string hex_digest() {
        pad();
        std::ostringstream o;
        for (int i = 0; i < 4; ++i)
            for (int j = 0; j < 4; ++j)
                o << std::hex << std::setfill('0') << std::setw(2)
                  << (uint32_t)((state[i] >> (j * 8)) & 0xFF);
        return o.str();
    }
};

// ===================== Utilidades =====================
std::string format_size(uint64_t bytes) {
    const char* units[] = {"B", "KB", "MB", "GB", "TB"};
    int u = 0;
    double sz = static_cast<double>(bytes);
    while (sz >= 1024.0 && u < 4) { sz /= 1024.0; ++u; }
    std::ostringstream o;
    o << std::fixed << std::setprecision(2) << sz << " " << units[u];
    return o.str();
}

std::string format_time(fs::file_time_type ftime) {
    auto sctp = std::chrono::time_point_cast<std::chrono::system_clock::duration>(
        ftime - fs::file_time_type::clock::now() + std::chrono::system_clock::now());
    auto tt = std::chrono::system_clock::to_time_t(sctp);
    char buf[64];
    std::strftime(buf, sizeof(buf), "%Y-%m-%d %H:%M:%S", std::localtime(&tt));
    return std::string(buf);
}

std::string category_for_ext(const std::string& ext) {
    static std::map<std::string, std::string> cats = {
        {"pdf","Documentos"},{"doc","Documentos"},{"docx","Documentos"},{"odt","Documentos"},
        {"txt","Documentos"},{"rtf","Documentos"},{"tex","Documentos"},{"md","Documentos"},
        {"xls","Documentos"},{"xlsx","Documentos"},{"csv","Documentos"},{"ppt","Documentos"},
        {"pptx","Documentos"},{"odp","Documentos"},{"ods","Documentos"},
        {"jpg","Imagens"},{"jpeg","Imagens"},{"png","Imagens"},{"gif","Imagens"},
        {"bmp","Imagens"},{"svg","Imagens"},{"ico","Imagens"},{"webp","Imagens"},
        {"tiff","Imagens"},{"tif","Imagens"},{"psd","Imagens"},
        {"mp4","Videos"},{"avi","Videos"},{"mkv","Videos"},{"mov","Videos"},
        {"wmv","Videos"},{"flv","Videos"},{"webm","Videos"},{"m4v","Videos"},
        {"mpg","Videos"},{"mpeg","Videos"},{"3gp","Videos"},
        {"mp3","Audio"},{"wav","Audio"},{"flac","Audio"},{"ogg","Audio"},
        {"aac","Audio"},{"wma","Audio"},{"m4a","Audio"},{"opus","Audio"},
        {"cpp","Codigo"},{"c","Codigo"},{"h","Codigo"},{"hpp","Codigo"},
        {"py","Codigo"},{"js","Codigo"},{"ts","Codigo"},{"java","Codigo"},
        {"go","Codigo"},{"rs","Codigo"},{"rb","Codigo"},{"php","Codigo"},
        {"cs","Codigo"},{"swift","Codigo"},{"kt","Codigo"},{"sh","Codigo"},
        {"bat","Codigo"},{"ps1","Codigo"},{"html","Codigo"},{"css","Codigo"},
        {"json","Codigo"},{"xml","Codigo"},{"yaml","Codigo"},{"yml","Codigo"},
        {"sql","Codigo"},{"toml","Codigo"},{"ini","Codigo"},{"cfg","Codigo"},
        {"zip","Compactados"},{"rar","Compactados"},{"7z","Compactados"},
        {"tar","Compactados"},{"gz","Compactados"},{"bz2","Compactados"},
        {"xz","Compactados"},{"zst","Compactados"},{"cab","Compactados"},
        {"exe","Executaveis"},{"msi","Executaveis"},{"deb","Executaveis"},
        {"rpm","Executaveis"},{"appimage","Executaveis"},{"dmg","Executaveis"},
        {"ttf","Fontes"},{"otf","Fontes"},{"woff","Fontes"},{"woff2","Fontes"},
    };
    std::string e = ext;
    std::transform(e.begin(), e.end(), e.begin(), ::tolower);
    if (!e.empty() && e[0] == '.') e = e.substr(1);
    auto it = cats.find(e);
    return it != cats.end() ? it->second : "Outros";
}

bool is_temp_file(const std::string& name) {
    static std::vector<std::string> patterns = {
        ".tmp", ".bak", ".swp", ".swo", "~", ".DS_Store", "Thumbs.db",
        ".log", ".old", ".orig", ".save", ".part", ".crdownload"
    };
    std::string n = name;
    std::transform(n.begin(), n.end(), n.begin(), ::tolower);
    for (auto& p : patterns) {
        if (n.size() >= p.size() &&
            n.compare(n.size() - p.size(), p.size(), p) == 0)
            return true;
    }
    return false;
}

bool is_cache_dir(const std::string& name) {
    static std::vector<std::string> cache_names = {
        "__pycache__", ".cache", "node_modules", ".npm", ".tmp", "Cache", "cache"
    };
    std::string n = name;
    for (auto& c : cache_names)
        if (n == c) return true;
    return false;
}

// ===================== Comando: find =====================
int cmd_find(CLIParser& cli) {
    std::string dir = cli.value("dir", ".");
    std::string name = cli.value("name", "");
    std::string ext  = cli.value("ext", "");
    std::string size_range = cli.value("size", "");
    int days = 0;
    try { days = std::stoi(cli.value("days", "0")); } catch (...) {}
    bool verbose = cli.has("verbose");

    std::cout << color::bold() << "\n🔍 Busca de Arquivos" << color::reset() << "\n";
    std::cout << "Diretório: " << color::cyan() << fs::absolute(dir).string() << color::reset() << "\n";
    if (!name.empty())  std::cout << "Nome contém:   " << name << "\n";
    if (!ext.empty())   std::cout << "Extensão:      " << ext << "\n";
    if (!size_range.empty()) std::cout << "Tamanho:       " << size_range << "\n";
    if (days > 0)      std::cout << "Modificados em últimos " << days << " dias\n";

    uint64_t min_sz = 0, max_sz = UINT64_MAX;
    if (!size_range.empty()) {
        char op = 0;
        uint64_t val = 0;
        std::string unit;
        std::istringstream iss(size_range);
        iss >> op >> val >> unit;
        uint64_t mult = 1;
        std::transform(unit.begin(), unit.end(), unit.begin(), ::tolower);
        if (unit == "kb") mult = 1024;
        else if (unit == "mb") mult = 1024*1024;
        else if (unit == "gb") mult = 1024ULL*1024*1024;
        val *= mult;
        if (op == '<') max_sz = val - 1;
        else if (op == '>') min_sz = val;
        else if (op == '=') { min_sz = val; max_sz = val; }
    }

    auto now = std::chrono::system_clock::now();
    auto cutoff = now - std::chrono::hours(24 * days);
    std::error_code ec;
    int count = 0;
    uint64_t total_bytes = 0;

    ProgressBar progress("Escaneando", 0);
    size_t scanned = 0;
    std::vector<fs::path> results;

    for (auto& entry : fs::recursive_directory_iterator(dir, fs::directory_options::skip_permission_denied, ec)) {
        if (!entry.is_regular_file(ec)) continue;
        ++scanned;
        if (scanned % 100 == 0) progress.update(scanned);

        auto fpath = entry.path();
        auto fname = fpath.filename().string();

        if (!name.empty()) {
            std::string fl = fname;
            std::string nl = name;
            std::transform(fl.begin(), fl.end(), fl.begin(), ::tolower);
            std::transform(nl.begin(), nl.end(), nl.begin(), ::tolower);
            if (fl.find(nl) == std::string::npos) continue;
        }

        if (!ext.empty()) {
            std::string fe = fpath.extension().string();
            std::transform(fe.begin(), fe.end(), fe.begin(), ::tolower);
            std::string el = ext;
            std::transform(el.begin(), el.end(), el.begin(), ::tolower);
            if (el[0] != '.') el = "." + el;
            if (fe != el) continue;
        }

        uint64_t fsize = fs::file_size(fpath, ec);
        if (ec) continue;
        if (fsize < min_sz || fsize > max_sz) continue;

        if (days > 0) {
            auto ftime = fs::last_write_time(fpath, ec);
            if (ec) continue;
            auto sctp = std::chrono::time_point_cast<std::chrono::system_clock::duration>(
                ftime - fs::file_time_type::clock::now() + now);
            if (sctp < cutoff) continue;
        }

        results.push_back(fpath);
        total_bytes += fsize;
        ++count;
    }

    progress.update(scanned);
    std::cout << "\r" << std::string(80, ' ') << "\r";
    std::cout << color::green() << "\n✓ " << count << " arquivo(s) encontrado(s)";
    std::cout << " (" << format_size(total_bytes) << " total)" << color::reset() << "\n\n";

    for (auto& p : results) {
        std::error_code ec2;
        uint64_t sz = fs::file_size(p, ec2);
        auto ft = fs::last_write_time(p, ec2);
        std::cout << "  " << color::cyan() << std::left << std::setw(50)
                  << p.string().substr(0, 50) << color::reset();
        std::cout << std::right << std::setw(10) << format_size(sz);
        if (!ec2) std::cout << "  " << color::dim() << format_time(ft) << color::reset();
        std::cout << "\n";
    }
    return 0;
}

// ===================== Comando: clean =====================
int cmd_clean(CLIParser& cli) {
    std::string dir = cli.value("dir", ".");
    bool dry_run = cli.has("dry-run");
    bool verbose = cli.has("verbose");

    std::cout << color::bold() << "\n🧹 Limpeza de Arquivos Temporários" << color::reset() << "\n";
    std::cout << "Diretório: " << color::cyan() << fs::absolute(dir).string() << color::reset() << "\n";
    if (dry_run)
        std::cout << color::yellow() << "MODO SIMULAÇÃO (dry-run) — nenhum arquivo será removido" << color::reset() << "\n";

    int file_count = 0, dir_count = 0;
    uint64_t freed = 0;
    std::error_code ec;

    struct Item { fs::path path; uint64_t size; bool is_dir; };
    std::vector<Item> items;

    for (auto& entry : fs::recursive_directory_iterator(dir, fs::directory_options::skip_permission_denied, ec)) {
        if (entry.is_regular_file(ec) && is_temp_file(entry.path().filename().string())) {
            uint64_t sz = fs::file_size(entry.path(), ec);
            if (!ec) items.push_back({entry.path(), sz, false});
        } else if (entry.is_directory(ec) && is_cache_dir(entry.path().filename().string())) {
            uint64_t sz = 0;
            for (auto& sub : fs::recursive_directory_iterator(entry.path(), fs::directory_options::skip_permission_denied, ec))
                if (sub.is_regular_file(ec)) sz += fs::file_size(sub.path(), ec);
            items.push_back({entry.path(), sz, true});
        }
    }

    if (items.empty()) {
        std::cout << color::green() << "\n✓ Nenhum arquivo temporário encontrado!" << color::reset() << "\n";
        return 0;
    }

    ProgressBar progress("Limpando", items.size());
    for (size_t i = 0; i < items.size(); ++i) {
        progress.update(i + 1);
        auto& item = items[i];
        if (verbose || dry_run) {
            std::cout << "\n  " << (item.is_dir ? "📁" : "📄") << " "
                      << item.path.string() << " (" << format_size(item.size) << ")";
        }
        if (!dry_run) {
            if (item.is_dir) {
                fs::remove_all(item.path, ec);
                if (!ec) { dir_count++; freed += item.size; }
            } else {
                fs::remove(item.path, ec);
                if (!ec) { file_count++; freed += item.size; }
            }
        } else {
            if (item.is_dir) dir_count++; else file_count++;
            freed += item.size;
        }
    }
    std::cout << "\n";

    std::cout << color::green() << "\n✓ Resultado:" << color::reset() << "\n";
    std::cout << "  Arquivos removidos:  " << file_count << "\n";
    std::cout << "  Diretórios removidos: " << dir_count << "\n";
    std::cout << "  Espaço liberado:     " << color::yellow() << format_size(freed) << color::reset() << "\n";
    if (dry_run)
        std::cout << color::yellow() << "  (Simulação — remova --dry-run para executar)" << color::reset() << "\n";
    return 0;
}

// ===================== Comando: organize =====================
int cmd_organize(CLIParser& cli) {
    std::string dir = cli.value("dir", ".");
    bool dry_run = cli.has("dry-run");
    bool verbose = cli.has("verbose");

    std::cout << color::bold() << "\n📁 Organização de Arquivos" << color::reset() << "\n";
    std::cout << "Diretório: " << color::cyan() << fs::absolute(dir).string() << color::reset() << "\n";
    if (dry_run)
        std::cout << color::yellow() << "MODO SIMULAÇÃO (dry-run) — nenhum arquivo será movido" << color::reset() << "\n";

    std::error_code ec;
    std::map<std::string, std::vector<fs::path>> groups;

    for (auto& entry : fs::directory_iterator(dir, ec)) {
        if (!entry.is_regular_file(ec)) continue;
        auto ext = entry.path().extension().string();
        std::string cat = category_for_ext(ext);
        groups[cat].push_back(entry.path());
    }

    if (groups.empty()) {
        std::cout << color::yellow() << "Nenhum arquivo encontrado no diretório." << color::reset() << "\n";
        return 0;
    }

    int moved = 0;
    ProgressBar progress("Organizando", 0);
    size_t total = 0;
    for (auto& [cat, files] : groups) total += files.size();
    progress = ProgressBar("Organizando", total);

    for (auto& [cat, files] : groups) {
        std::cout << "\n" << color::magenta() << "[" << cat << "]" << color::reset()
                  << " — " << files.size() << " arquivo(s)\n";

        fs::path cat_dir = fs::path(dir) / cat;
        if (!dry_run) {
            fs::create_directories(cat_dir, ec);
        }

        for (auto& fpath : files) {
            ++moved;
            progress.update(moved);
            auto dest = cat_dir / fpath.filename();
            if (verbose || dry_run)
                std::cout << "  " << fpath.filename().string() << " → "
                          << (cat / fpath.filename()).string() << "\n";
            if (!dry_run) {
                fs::rename(fpath, dest, ec);
                if (ec && verbose)
                    std::cout << color::red() << "    Erro: " << ec.message() << color::reset() << "\n";
            }
        }
    }
    std::cout << "\n";

    std::cout << color::green() << "\n✓ " << moved << " arquivo(s) organizados em "
              << groups.size() << " categorias" << color::reset() << "\n";
    if (dry_run)
        std::cout << color::yellow() << "  (Simulação — remova --dry-run para executar)" << color::reset() << "\n";
    return 0;
}

// ===================== Comando: hash =====================
int cmd_hash(CLIParser& cli) {
    std::string file_path = cli.positional(1);
    if (file_path.empty() && !cli.value("file").empty())
        file_path = cli.value("file");
    if (file_path.empty()) {
        std::cerr << color::red() << "Erro: informe um arquivo. Uso: filetools hash <arquivo>" << color::reset() << "\n";
        return 1;
    }

    std::string algo = cli.value("algo", "both");
    std::transform(algo.begin(), algo.end(), algo.begin(), ::tolower);
    bool do_sha256 = (algo == "sha256" || algo == "both");
    bool do_md5    = (algo == "md5"    || algo == "both");

    if (!fs::exists(file_path)) {
        std::cerr << color::red() << "Erro: arquivo não encontrado: " << file_path << color::reset() << "\n";
        return 1;
    }

    uint64_t fsize = fs::file_size(file_path);
    std::cout << color::bold() << "\n🔐 Hash de Arquivo" << color::reset() << "\n";
    std::cout << "Arquivo: " << color::cyan() << fs::absolute(file_path).string() << color::reset() << "\n";
    std::cout << "Tamanho: " << format_size(fsize) << "\n\n";

    ProgressBar progress("Calculando", do_sha256 && do_md5 ? 2 : 1);
    int step = 0;

    if (do_sha256) {
        SHA256 sha;
        sha.update_file(file_path);
        auto hash = sha.hex_digest();
        progress.update(++step);
        std::cout << "\r" << std::string(80, ' ') << "\r";
        std::cout << "  " << color::green() << "SHA-256" << color::reset() << ": " << hash << "\n";
    }

    if (do_md5) {
        MD5 md5;
        md5.update_file(file_path);
        auto hash = md5.hex_digest();
        progress.update(++step);
        std::cout << "\r" << std::string(80, ' ') << "\r";
        std::cout << "  " << color::green() << "MD5" << color::reset() << ":    " << hash << "\n";
    }

    std::cout << "\n";
    return 0;
}

// ===================== Main =====================
int main(int argc, char* argv[]) {
    color::enable_ansi();
    CLIParser cli("filetools");
    cli.parse(argc, argv);

    if (cli.has("help") || argc < 2) {
        cli.print_help();
        return 0;
    }

    std::string cmd = cli.positional(0);

    if (cmd == "find")     return cmd_find(cli);
    if (cmd == "clean")    return cmd_clean(cli);
    if (cmd == "organize") return cmd_organize(cli);
    if (cmd == "hash")     return cmd_hash(cli);

    std::cerr << color::red() << "Comando desconhecido: " << cmd << color::reset() << "\n";
    std::cerr << "Use: filetools --help\n";
    return 1;
}
