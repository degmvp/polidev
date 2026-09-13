// ============================================================================
//  POLYDEV | WX-TOOLS | C++ | 011 | Cross-Platform Logger — biblioteca de logging C++17 (header-only)
//  Windows (MSVC 2022) / Linux (GCC, Clang) — sem dependências externas
//
//  Uso rápido:
//    #include "CrossPlatformLogger.hpp"
//    LOG_INFO("conectado a {} na porta {}", host, port);
//
//  NOTA: expressões com vírgula fora de parênteses (ex.: templates com
//  mais de um argumento) devem ser envolvidas em parênteses extras:
//    LOG_INFO("{}", (std::make_pair(1, 2)));
// ============================================================================
#include <atomic>
#include <chrono>
#include <cctype>
#include <cstdint>
#include <cstdio>

#ifdef _MSC_VER
#pragma warning(disable: 4996) // fopen is used only by the POSIX branch
#endif
#include <cstring>
#include <ctime>
#include <filesystem>
#include <memory>
#include <mutex>
#include <sstream>
#include <stdexcept>
#include <string>
#include <thread>
#include <utility>
#include <vector>

#ifdef _WIN32
  #ifndef WIN32_LEAN_AND_MEAN
    #define WIN32_LEAN_AND_MEAN
  #endif
  #ifndef NOMINMAX
    #define NOMINMAX
  #endif
  #include <windows.h>
#else
  #include <unistd.h>
#endif

namespace cpl {

// ------------------------------------------------------------------ níveis
enum class LogLevel : int {
    Trace = 0, Debug = 1, Info = 2, Warn = 3, Error = 4, Fatal = 5, Off = 6
};

inline const char* to_string(LogLevel lv) {
    switch (lv) {
        case LogLevel::Trace: return "TRACE";
        case LogLevel::Debug: return "DEBUG";
        case LogLevel::Info:  return "INFO";
        case LogLevel::Warn:  return "WARN";
        case LogLevel::Error: return "ERROR";
        case LogLevel::Fatal: return "FATAL";
        default:              return "?????";
    }
}

inline bool parseLevel(const std::string& s, LogLevel& out) {
    std::string v;
    for (char c : s) v += (char)std::toupper((unsigned char)c);
    if (v == "TRACE")                    { out = LogLevel::Trace; return true; }
    if (v == "DEBUG")                    { out = LogLevel::Debug; return true; }
    if (v == "INFO")                     { out = LogLevel::Info;  return true; }
    if (v == "WARN" || v == "WARNING")   { out = LogLevel::Warn;  return true; }
    if (v == "ERROR" || v == "ERR")      { out = LogLevel::Error; return true; }
    if (v == "FATAL" || v == "CRITICAL") { out = LogLevel::Fatal; return true; }
    if (v == "OFF" || v == "NONE")       { out = LogLevel::Off;   return true; }
    return false;
}

// ------------------------------------------------------------ conversões
#ifdef _WIN32
inline std::string wideToUtf8(const std::wstring& w) {
    if (w.empty()) return {};
    const int n = ::WideCharToMultiByte(CP_UTF8, 0, w.c_str(), (int)w.size(), nullptr, 0, nullptr, nullptr);
    std::string s((size_t)n, '\0');
    ::WideCharToMultiByte(CP_UTF8, 0, w.c_str(), (int)w.size(), &s[0], n, nullptr, nullptr);
    return s;
}
inline std::wstring utf8ToWide(const std::string& u) {
    if (u.empty()) return {};
    const int n = ::MultiByteToWideChar(CP_UTF8, 0, u.c_str(), (int)u.size(), nullptr, 0);
    std::wstring w((size_t)n, L'\0');
    ::MultiByteToWideChar(CP_UTF8, 0, u.c_str(), (int)u.size(), &w[0], n);
    return w;
}
#endif

inline std::string pathToUtf8(const std::filesystem::path& p) {
#ifdef _WIN32
    return wideToUtf8(p.wstring());
#else
    return p.string();
#endif
}

// ----------------------------------------------------------- utilitários
inline const char* baseName(const char* path) {
    if (!path) return "";
    const char* a = std::strrchr(path, '/');
    const char* b = std::strrchr(path, '\\');
    const char* p = (a && b) ? (a > b ? a : b) : (a ? a : b);
    return p ? p + 1 : path;
}

inline std::string padRight(std::string s, size_t w) {
    return s.size() >= w ? s : s + std::string(w - s.size(), ' ');
}

inline std::string formatTimeMs(std::chrono::system_clock::time_point tp, const std::string& fmt) {
    namespace ch = std::chrono;
    const std::time_t t = ch::system_clock::to_time_t(tp);
    const int ms = (int)(ch::duration_cast<ch::milliseconds>(tp.time_since_epoch()).count() % 1000);
    std::tm tmv{};
#ifdef _WIN32
    if (::localtime_s(&tmv, &t) != 0) tmv = std::tm{};
#else
    if (::localtime_r(&t, &tmv) == nullptr) tmv = std::tm{};
#endif
    char buf[96];
    if (std::strftime(buf, sizeof(buf), fmt.c_str(), &tmv) == 0) buf[0] = '\0';
    char out[112];
    std::snprintf(out, sizeof(out), "%s.%03d", buf, ms);
    return out;
}

inline const char* levelAnsi(LogLevel lv) {
    switch (lv) {
        case LogLevel::Trace: return "\x1b[90m";   // cinza
        case LogLevel::Debug: return "\x1b[36m";   // ciano
        case LogLevel::Info:  return "\x1b[32m";   // verde
        case LogLevel::Warn:  return "\x1b[33m";   // amarelo
        case LogLevel::Error: return "\x1b[31m";   // vermelho
        case LogLevel::Fatal: return "\x1b[1;31m"; // vermelho forte
        default: return "";
    }
}

// -------------------------------------------------- formatação "{}" segura
namespace detail {

inline void fmtTail(std::ostringstream&) {}

template <typename T, typename... Rest>
void fmtTail(std::ostringstream& os, T&& v, Rest&&... rest) {
    os << std::forward<T>(v);
    fmtTail(os, std::forward<Rest>(rest)...);
}

inline void apply(std::ostringstream& os, const std::string& f, size_t pos) {
    os << f.substr(pos);
}

template <typename T, typename... Rest>
void apply(std::ostringstream& os, const std::string& f, size_t pos, T&& v, Rest&&... rest) {
    const size_t b = f.find("{}", pos);
    if (b == std::string::npos) {                 // args excedentes vão no fim
        os << f.substr(pos);
        fmtTail(os, std::forward<T>(v), std::forward<Rest>(rest)...);
        return;
    }
    os << f.substr(pos, b - pos);
    os << std::forward<T>(v);
    apply(os, f, b + 2, std::forward<Rest>(rest)...);
}

} // namespace detail

template <typename... Args>
std::string format(const std::string& fmt, Args&&... args) {
    std::ostringstream os;
    detail::apply(os, fmt, 0, std::forward<Args>(args)...);
    return os.str();
}

// ----------------------------------------------------------------- registro
struct LogRecord {
    std::chrono::system_clock::time_point time;
    LogLevel         level   = LogLevel::Info;
    std::thread::id  threadId{};
    const char*      file    = "";
    int              line    = 0;
    const char*      function = "";
    std::string      message;
};

struct FormatOptions {
    bool        showTime     = true;
    bool        showLevel    = true;
    bool        showThread   = false;
    bool        showSource   = false;   // [arquivo.cpp:42]
    bool        showFunction = false;
    std::string timeFormat   = "%Y-%m-%d %H:%M:%S";
};

inline std::string buildLine(const LogRecord& rec, const FormatOptions& o, bool color) {
    std::ostringstream os;
    const char* dim   = color ? "\x1b[2m" : "";
    const char* reset = color ? "\x1b[0m" : "";
    const char* lvCol = color ? levelAnsi(rec.level) : "";

    if (o.showTime)
        os << dim << '[' << formatTimeMs(rec.time, o.timeFormat) << ']' << reset << ' ';
    if (o.showLevel)
        os << lvCol << '[' << padRight(to_string(rec.level), 5) << ']' << reset << ' ';
    if (o.showThread)
        os << dim << '[' << rec.threadId << ']' << reset << ' ';
    if (o.showSource)
        os << dim << '[' << rec.file << ':' << rec.line << ']' << reset << ' ';
    if (o.showFunction)
        os << dim << '[' << rec.function << ']' << reset << ' ';
    os << rec.message << '\n';
    return os.str();
}

// ------------------------------------------------------------------- sinks
class ILogSink {
public:
    virtual ~ILogSink() = default;
    virtual void write(const LogRecord& rec, const FormatOptions& opts) = 0;
    virtual void flush() {}
    void    setLevel(LogLevel lv) { level_.store(lv, std::memory_order_relaxed); }
    LogLevel level() const        { return level_.load(std::memory_order_relaxed); }
private:
    std::atomic<LogLevel> level_{LogLevel::Trace};
};

// ---------------------------------------------------------------- console
class ConsoleSink : public ILogSink {
public:
    explicit ConsoleSink(bool colors = true, bool warnAndAboveToStderr = true)
        : colorsEnabled_(colors), toStderr_(warnAndAboveToStderr)
    {
#ifdef _WIN32
        hOut_ = ::GetStdHandle(STD_OUTPUT_HANDLE);
        hErr_ = ::GetStdHandle(STD_ERROR_HANDLE);
        baseAttrOut_ = currentAttr(hOut_);
        baseAttrErr_ = currentAttr(hErr_);
        ::SetConsoleOutputCP(CP_UTF8);          // mensagens UTF-8 no console
#else
        colorOut_ = colorsEnabled_ && ::isatty(::fileno(stdout)) != 0;
        colorErr_ = colorsEnabled_ && ::isatty(::fileno(stderr)) != 0;
#endif
    }

    void setColors(bool on)                { colorsEnabled_ = on; }
    void setWarnAndAboveToStderr(bool on)  { toStderr_ = on; }

    void write(const LogRecord& rec, const FormatOptions& opts) override {
        const bool useErr = toStderr_ &&
            static_cast<int>(rec.level) >= static_cast<int>(LogLevel::Warn);
        std::FILE* out = useErr ? stderr : stdout;

#ifdef _WIN32
        HANDLE h = useErr ? hErr_ : hOut_;
        const bool console = isConsoleHandle(h);
        const WORD base = useErr ? baseAttrErr_ : baseAttrOut_;

        // Windows: nunca envia sequencias ANSI para o console.
        // Console real usa atributos Win32; redirecionamento recebe texto puro.
        const std::string line = buildLine(rec, opts, false);
        if (colorsEnabled_ && console)
            ::SetConsoleTextAttribute(h, levelAttr(rec.level, base));

        std::fwrite(line.data(), 1, line.size(), out);
        std::fflush(out);

        if (colorsEnabled_ && console)
            ::SetConsoleTextAttribute(h, base);
#else
        const std::string line = buildLine(rec, opts, useErr ? colorErr_ : colorOut_);
        std::fwrite(line.data(), 1, line.size(), out);
        std::fflush(out);
#endif
    }

private:
#ifdef _WIN32
    static bool isConsoleHandle(HANDLE h) {
        DWORD m = 0;
        return h != nullptr && h != INVALID_HANDLE_VALUE && ::GetConsoleMode(h, &m) != 0;
    }
    static WORD currentAttr(HANDLE h) {
        CONSOLE_SCREEN_BUFFER_INFO i{};
        if (isConsoleHandle(h) && ::GetConsoleScreenBufferInfo(h, &i)) return i.wAttributes;
        return FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE;
    }
    static WORD levelAttr(LogLevel lv, WORD base) {
        const WORD bg = base & (BACKGROUND_BLUE | BACKGROUND_GREEN |
                                BACKGROUND_RED | BACKGROUND_INTENSITY);
        switch (lv) {
            case LogLevel::Trace: return bg | FOREGROUND_INTENSITY;
            case LogLevel::Debug: return bg | FOREGROUND_GREEN | FOREGROUND_BLUE | FOREGROUND_INTENSITY;
            case LogLevel::Info:  return bg | FOREGROUND_GREEN | FOREGROUND_INTENSITY;
            case LogLevel::Warn:  return bg | FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_INTENSITY;
            case LogLevel::Error: return bg | FOREGROUND_RED | FOREGROUND_INTENSITY;
            case LogLevel::Fatal: return bg | BACKGROUND_RED | BACKGROUND_INTENSITY |
                                         FOREGROUND_RED | FOREGROUND_GREEN |
                                         FOREGROUND_BLUE | FOREGROUND_INTENSITY;
            default: return base;
        }
    }

    HANDLE hOut_ = nullptr, hErr_ = nullptr;
    WORD   baseAttrOut_ = 7, baseAttrErr_ = 7;
#endif
    bool colorsEnabled_ = true;
    bool toStderr_      = true;
    bool colorOut_ = false, colorErr_ = false; // POSIX
};

// ------------------------------------------------- arquivo com rotação
class FileSink : public ILogSink {
public:
    // maxBytes = 0 desativa a rotação; maxBackups = quantidade de .N.log mantidos
    explicit FileSink(const std::filesystem::path& path,
                      uintmax_t maxBytes = 5ull * 1024 * 1024,
                      int maxBackups = 3,
                      bool truncate = false)
        : path_(path), maxBytes_(maxBytes), maxBackups_(maxBackups < 0 ? 0 : maxBackups)
    {
        openFile(truncate);
        if (!f_)
            throw std::runtime_error("CrossPlatformLogger: falha ao abrir arquivo de log: " +
                                     pathToUtf8(path_));
    }

    ~FileSink() override {
        if (f_) { std::fclose(f_); f_ = nullptr; }
    }

    const std::filesystem::path& path() const { return path_; }

    void write(const LogRecord& rec, const FormatOptions& opts) override {
        if (!f_) return;
        const std::string line = buildLine(rec, opts, false);
        if (maxBytes_ > 0 && written_ + (uintmax_t)line.size() > maxBytes_) rotate();
        if (!f_) return;
        std::fwrite(line.data(), 1, line.size(), f_);
        written_ += line.size();
        if (static_cast<int>(rec.level) >= static_cast<int>(LogLevel::Warn))
            std::fflush(f_);                    // WARN+ nunca se perde num crash
    }

    void flush() override { if (f_) std::fflush(f_); }

private:
    std::filesystem::path withIndex(int i) const {
        const std::string suf = "." + std::to_string(i);
#ifdef _WIN32
        const std::wstring wsuf(suf.begin(), suf.end());   // só dígitos: seguro
        return std::filesystem::path(path_.wstring() + wsuf);
#else
        return std::filesystem::path(path_.string() + suf);
#endif
    }

    void openRaw(bool truncate) {
#ifdef _WIN32
        f_ = ::_wfopen(path_.c_str(), truncate ? L"wb" : L"ab");
#else
        f_ = std::fopen(path_.string().c_str(), truncate ? "wb" : "ab");
#endif
        if (!f_) { written_ = 0; return; }
        std::fseek(f_, 0, SEEK_END);
        const long sz = std::ftell(f_);
        written_ = sz > 0 ? (uintmax_t)sz : 0;
    }

    void openFile(bool truncate) {
        openRaw(truncate);
        if (f_ && !truncate && maxBytes_ > 0 && written_ >= maxBytes_)
            rotate();                            // arquivo já estava cheio
    }

    void rotate() {
        if (f_) { std::fclose(f_); f_ = nullptr; }
        std::error_code ec;
        if (maxBackups_ == 0) {
            std::filesystem::remove(path_, ec);
        } else {
            for (int i = maxBackups_ - 1; i >= 1; --i) {
                const std::filesystem::path from = withIndex(i);
                const std::filesystem::path to   = withIndex(i + 1);
                if (std::filesystem::exists(from, ec)) {
                    std::filesystem::remove(to, ec);      // Windows: rename falha se existe
                    std::filesystem::rename(from, to, ec);
                }
            }
            const std::filesystem::path first = withIndex(1);
            std::filesystem::remove(first, ec);
            std::filesystem::rename(path_, first, ec);
        }
        openRaw(true);
        // se f_ ficar nulo aqui, writes subsequentes são silenciosamente ignorados
    }

    std::filesystem::path path_;
    uintmax_t  maxBytes_;
    int        maxBackups_;
    std::FILE* f_ = nullptr;
    uintmax_t  written_ = 0;
};

// ------------------------------------------------------------------ Logger
class Logger {
public:
    static Logger& instance() {
        static Logger g;                        // thread-safe desde C++11
        return g;
    }

    Logger(const Logger&) = delete;
    Logger& operator=(const Logger&) = delete;

    // ---- nível global (menor nível aceito por qualquer sink)
    void setLevel(LogLevel lv) { level_.store(lv, std::memory_order_relaxed); }
    LogLevel level() const     { return level_.load(std::memory_order_relaxed); }
    bool shouldLog(LogLevel lv) const {
        return lv != LogLevel::Off &&
               static_cast<int>(lv) >= static_cast<int>(level_.load(std::memory_order_relaxed));
    }

    // ---- sinks
    void addSink(std::shared_ptr<ILogSink> sink) {
        if (!sink) return;
        std::lock_guard<std::mutex> lk(mtx_);
        sinks_.push_back(std::move(sink));
    }
    void clearSinks() {
        std::lock_guard<std::mutex> lk(mtx_);
        sinks_.clear();
    }
    std::shared_ptr<ConsoleSink> addConsole(bool colors = true) {
        auto s = std::make_shared<ConsoleSink>(colors);
        addSink(s);
        return s;
    }
    // Lança std::runtime_error se não conseguir abrir o arquivo.
    std::shared_ptr<FileSink> addFile(const std::filesystem::path& path,
                                      uintmax_t maxBytes = 5ull * 1024 * 1024,
                                      int maxBackups = 3,
                                      bool truncate = false) {
        auto s = std::make_shared<FileSink>(path, maxBytes, maxBackups, truncate);
        addSink(s);
        return s;
    }

    // ---- opções de formatação (aplicadas a todos os sinks)
    FormatOptions& options()        { return opts_; }
    void setTimeFormat(const std::string& f) { opts_.timeFormat = f; }
    void setShowTime(bool v)        { opts_.showTime = v; }
    void setShowLevel(bool v)       { opts_.showLevel = v; }
    void setShowThread(bool v)      { opts_.showThread = v; }
    void setShowSource(bool v)      { opts_.showSource = v; }
    void setShowFunction(bool v)    { opts_.showFunction = v; }

#ifdef _WIN32
    // espelha as mensagens no depurador (DbgView / Output do Visual Studio)
    void setDebugOutput(bool on) { debugOut_.store(on, std::memory_order_relaxed); }
#endif

    void log(LogLevel lv, const char* file, int line, const char* func, std::string message) {
        if (!shouldLog(lv)) return;

        LogRecord rec;
        rec.time      = std::chrono::system_clock::now();
        rec.level     = lv;
        rec.threadId  = std::this_thread::get_id();
        rec.file      = baseName(file);
        rec.line      = line;
        rec.function  = func ? func : "";
        rec.message   = std::move(message);

#ifdef _WIN32
        if (debugOut_.load(std::memory_order_relaxed)) {
            const std::wstring w = utf8ToWide(rec.message + "\r\n");
            ::OutputDebugStringW(w.c_str());
        }
#endif
        std::lock_guard<std::mutex> lk(mtx_);   // serializa todos os sinks
        for (const auto& s : sinks_)
            if (rec.level >= s->level() && s->level() != LogLevel::Off)
                s->write(rec, opts_);
    }

    void flush() {
        std::lock_guard<std::mutex> lk(mtx_);
        for (const auto& s : sinks_) s->flush();
    }

    void shutdown() {
        std::lock_guard<std::mutex> lk(mtx_);
        for (const auto& s : sinks_) s->flush();
        sinks_.clear();
    }

private:
    Logger() { sinks_.push_back(std::make_shared<ConsoleSink>(true)); } // padrão: console
    ~Logger() = default;

    std::vector<std::shared_ptr<ILogSink>> sinks_;
    std::mutex            mtx_;
    std::atomic<LogLevel> level_{LogLevel::Info};
    FormatOptions         opts_;
    std::atomic<bool>     debugOut_{false};
};

} // namespace cpl

// ------------------------------------------------------------------ macros
#if defined(_MSC_VER)
#  define CPL_LOG_FUNCTION __FUNCTION__
#else
#  define CPL_LOG_FUNCTION __func__
#endif

#define CPL_LOG(lv, ...)                                                          \
    do {                                                                          \
        if (::cpl::Logger::instance().shouldLog(lv))                              \
            ::cpl::Logger::instance().log(lv, __FILE__, __LINE__,                 \
                                          CPL_LOG_FUNCTION,                       \
                                          ::cpl::format(__VA_ARGS__));            \
    } while (0)

#define CPL_LOG_TRACE(...) CPL_LOG(::cpl::LogLevel::Trace, __VA_ARGS__)
#define CPL_LOG_DEBUG(...) CPL_LOG(::cpl::LogLevel::Debug, __VA_ARGS__)
#define CPL_LOG_INFO(...)  CPL_LOG(::cpl::LogLevel::Info,  __VA_ARGS__)
#define CPL_LOG_WARN(...)  CPL_LOG(::cpl::LogLevel::Warn,  __VA_ARGS__)
#define CPL_LOG_ERROR(...) CPL_LOG(::cpl::LogLevel::Error, __VA_ARGS__)
#define CPL_LOG_FATAL(...) CPL_LOG(::cpl::LogLevel::Fatal, __VA_ARGS__)

// apelidos curtos (desativados se já existirem no seu projeto)
#ifndef LOG_TRACE
#  define LOG_TRACE(...) CPL_LOG_TRACE(__VA_ARGS__)
#endif
#ifndef LOG_DEBUG
#  define LOG_DEBUG(...) CPL_LOG_DEBUG(__VA_ARGS__)
#endif
#ifndef LOG_INFO
#  define LOG_INFO(...)  CPL_LOG_INFO(__VA_ARGS__)
#endif
#ifndef LOG_WARN
#  define LOG_WARN(...)  CPL_LOG_WARN(__VA_ARGS__)
#endif
#ifndef LOG_ERROR
#  define LOG_ERROR(...) CPL_LOG_ERROR(__VA_ARGS__)
#endif
#ifndef LOG_FATAL
#  define LOG_FATAL(...) CPL_LOG_FATAL(__VA_ARGS__)
#endif
// ============================================================================
//  WX-TOOLS 011 - Cross Platform Logger | executable self-test
//  Define CPL_NO_DEMO_MAIN when embedding this file as a library.
// ============================================================================
#ifndef CPL_NO_DEMO_MAIN
int main() {
    using namespace cpl;

    auto& logger = Logger::instance();
    logger.setLevel(LogLevel::Trace);
    logger.setShowThread(true);
    logger.setShowSource(true);

    // Self-test: uma unica saida de console e todos os niveis em stdout.
    logger.clearSinks();
    auto console = logger.addConsole(true);
    console->setLevel(LogLevel::Trace);
    console->setWarnAndAboveToStderr(false);

    try {
        auto file = logger.addFile("wxt-cpp-011-cross-platform-logger.log",
                                   1024 * 1024, 3, true);
        file->setLevel(LogLevel::Trace);

        LOG_TRACE("TRACE - logger iniciado");
        LOG_DEBUG("DEBUG - teste de formatacao: {} + {} = {}", 2, 3, 5);
        LOG_INFO("INFO - Cross Platform Logger ativo");
        LOG_WARN("WARN - teste de aviso");
        LOG_ERROR("ERROR - teste controlado");
        LOG_FATAL("FATAL - teste controlado, sem encerrar o processo");
        LOG_INFO("UTF-8 - acentos: informacao, conexao, operacao");
        LOG_INFO("Arquivo de log: {}", "wxt-cpp-011-cross-platform-logger.log");

        logger.flush();
        logger.shutdown();
    } catch (const std::exception& e) {
        std::fprintf(stderr, "WX-TOOLS 011: falha no teste: %s\n", e.what());
        return 1;
    }

    return 0;
}
#endif
