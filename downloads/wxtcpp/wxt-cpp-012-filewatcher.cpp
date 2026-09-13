// fwdemo — monitora um diretorio e imprime as alteracoes em tempo real
//   fwdemo <dir> [--no-recursive] [--debounce N] [--exclude substr]...
#include "wxt-cpp-012-filewatcher.hpp"

#include <chrono>
#include <csignal>
#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <filesystem>
#include <string>
#include <thread>
#include <vector>

namespace fs = std::filesystem;

namespace {
volatile std::sig_atomic_t g_stop = 0;
#ifdef _WIN32
BOOL WINAPI ctrlHandler(DWORD t) {
    if (t == CTRL_C_EVENT || t == CTRL_BREAK_EVENT) { g_stop = 1; return TRUE; }
    return FALSE;
}
#else
void sigHandler(int) { g_stop = 1; }
#endif

std::string hhmmss() {
    const std::time_t t = std::chrono::system_clock::to_time_t(std::chrono::system_clock::now());
    std::tm tmv{};
#ifdef _WIN32
    localtime_s(&tmv, &t);
#else
    localtime_r(&t, &tmv);
#endif
    char b[16];
    std::snprintf(b, sizeof b, "%02d:%02d:%02d", tmv.tm_hour, tmv.tm_min, tmv.tm_sec);
    return b;
}
} // namespace

int main(int argc, char** argv) {
    std::vector<std::string> a;
    for (int i = 1; i < argc; ++i) a.push_back(argv[i]);

    std::string dir = ".";
    bool recursive = true;
    int  debounce  = 250;
    std::vector<std::string> excl;

    for (size_t i = 0; i < a.size(); ++i) {
        const std::string& s = a[i];
        if      (s == "--no-recursive") recursive = false;
        else if (s == "--debounce" && i + 1 < a.size()) debounce = std::atoi(a[++i].c_str());
        else if (s == "--exclude"  && i + 1 < a.size()) excl.push_back(a[++i]);
        else if (s == "-h" || s == "--help") {
            std::printf("uso: fwdemo <dir> [--no-recursive] [--debounce N] [--exclude substr]...\n");
            return 0;
        }
        else if (!s.empty() && s[0] == '-') { std::fprintf(stderr, "opcao desconhecida: %s\n", s.c_str()); return 2; }
        else dir = s;
    }

    std::error_code ec;
    fs::path root = fs::weakly_canonical(fs::path(dir), ec);
    if (ec) root = fs::path(dir);
    if (!fs::is_directory(root, ec)) {
        std::fprintf(stderr, "diretorio invalido: %s\n", dir.c_str());
        return 2;
    }

    auto lower = [](std::string s) {
        for (char& c : s) c = (char)std::tolower((unsigned char)c);
        return s;
    };
    std::vector<std::string> exclLow;
    for (const auto& e : excl) exclLow.push_back(lower(e));

    fw::Options opt;
    opt.recursive  = recursive;
    opt.debounceMs = debounce < 0 ? 0 : debounce;
    opt.filter     = [&exclLow, &lower](const fs::path& p) {
        const std::string s = lower(fw::pathToUtf8(p));
        for (const auto& x : exclLow)
            if (s.find(x) != std::string::npos) return false;
        return true;
    };
    opt.onError = [](const std::string& m) { std::fprintf(stderr, "[aviso] %s\n", m.c_str()); };

    fw::FileWatcher watcher;
    watcher.start(root, [](const std::vector<fw::Event>& evs) {
        for (const auto& e : evs) {
            std::printf("%s  %-8s  %s", hhmmss().c_str(),
                        fw::to_string(e.type), fw::pathToUtf8(e.path).c_str());
            if (e.type == fw::EventType::Renamed)
                std::printf("   (antes: %s)", fw::pathToUtf8(e.oldPath).c_str());
            std::printf("\n");
            std::fflush(stdout);
        }
    }, opt);

    std::printf("fwdemo — monitorando: %s\n", fw::pathToUtf8(root).c_str());
    std::printf("modo: %s | debounce: %d ms | Ctrl+C para sair\n\n",
                recursive ? "recursivo" : "somente o diretorio", opt.debounceMs);

#ifdef _WIN32
    ::SetConsoleCtrlHandler(ctrlHandler, TRUE);
#else
    std::signal(SIGINT,  sigHandler);
    std::signal(SIGTERM, sigHandler);
#endif

    while (!g_stop && watcher.isRunning())
        std::this_thread::sleep_for(std::chrono::milliseconds(100));

    if (g_stop) { std::printf("\nencerrando...\n"); watcher.stop(); }
    return 0;
}