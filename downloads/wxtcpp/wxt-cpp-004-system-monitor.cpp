/*
 * POLYDEV | WX-TOOLS — wxt-cpp-004-system-monitor v1.0
 * Compilação: g++-13 -std=c++17 -O2 wxt-cpp-004-system-monitor.cpp -o wxt-cpp-004-system-monitor
 * Requer: Linux (lê /proc, sysinfo, statvfs)
 */

#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <map>
#include <set>
#include <algorithm>
#include <iomanip>
#include <filesystem>
#include <optional>
#include <functional>
#include <chrono>
#include <thread>
#include <cstring>
#include <cstdlib>

#include <dirent.h>
#include <sys/sysinfo.h>
#include <sys/statvfs.h>
#include <unistd.h>
#include <sys/types.h>

namespace fs = std::filesystem;

// ========== Cores no Terminal ==========
namespace color {
    const char* reset   = "\033[0m";
    const char* bold    = "\033[1m";
    const char* dim     = "\033[2m";
    const char* red     = "\033[31m";
    const char* green   = "\033[32m";
    const char* yellow  = "\033[33m";
    const char* blue    = "\033[34m";
    const char* magenta = "\033[35m";
    const char* cyan    = "\033[36m";
    const char* white   = "\033[37m";
    const char* bg_red  = "\033[41m";
    const char* bg_green = "\033[42m";
}

bool use_color = true;

// ========== Barra de Progresso ==========
void progress_bar(float pct, int width = 30, const std::string& label = "") {
    int filled = static_cast<int>(pct / 100.0f * width);
    if (filled > width) filled = width;
    if (filled < 0) filled = 0;

    const char* bar_color = color::green;
    if (pct > 70.0f) bar_color = color::yellow;
    if (pct > 90.0f) bar_color = color::red;

    if (use_color) {
        std::cout << color::dim << label << color::reset
                  << "[" << bar_color << std::string(filled, '#') << color::reset
                  << std::string(width - filled, '-') << "] "
                  << bar_color << std::fixed << std::setprecision(1) << pct << "%" << color::reset;
    } else {
        std::cout << label << "[" << std::string(filled, '#')
                  << std::string(width - filled, '-') << "] "
                  << std::fixed << std::setprecision(1) << pct << "%";
    }
}

void end_progress() { std::cout << std::endl; }

// ========== Parser de CLI ==========
struct CliParser {
    std::string program_name;
    std::string subcommand;
    std::map<std::string, std::string> options;
    std::vector<std::string> positional;
    bool help_requested = false;

    void parse(int argc, char* argv[]) {
        program_name = fs::path(argv[0]).filename();
        for (int i = 1; i < argc; ++i) {
            std::string arg = argv[i];
            if (arg == "-h" || arg == "--help") { help_requested = true; continue; }
            if (arg == "--no-color") { use_color = false; continue; }

            if (arg.rfind("--") == 0) {
                auto eq = arg.find('=');
                if (eq != std::string::npos) {
                    options[arg.substr(2, eq - 2)] = arg.substr(eq + 1);
                } else {
                    std::string key = arg.substr(2);
                    if (i + 1 < argc && std::string(argv[i + 1])[0] != '-') {
                        options[key] = argv[++i];
                    } else {
                        options[key] = "1";
                    }
                }
            } else if (arg.size() == 2 && arg[0] == '-' && arg[1] != '-') {
                std::string key(1, arg[1]);
                if (i + 1 < argc && std::string(argv[i + 1])[0] != '-') {
                    options[key] = argv[++i];
                } else {
                    options[key] = "1";
                }
            } else {
                if (subcommand.empty()) subcommand = arg;
                else positional.push_back(arg);
            }
        }
    }

    bool has(const std::string& key) const { return options.count(key) > 0; }
    std::string get(const std::string& key, const std::string& def = "") const {
        auto it = options.find(key); return it != options.end() ? it->second : def;
    }
    int get_int(const std::string& key, int def = 0) const {
        auto it = options.find(key);
        if (it != options.end()) { try { return std::stoi(it->second); } catch (...) {} }
        return def;
    }
};

// ========== Informações de Processo ==========
struct ProcessInfo {
    int pid = 0;
    std::string name;
    std::string cmdline;
    char state = '?';
    long rss_pages = 0;
    long vsize = 0;
    unsigned long utime = 0;
    unsigned long stime = 0;
    unsigned long total_time = 0;
    int threads = 1;
    float cpu_pct = 0.0f;
    float mem_pct = 0.0f;
};

static ProcessInfo read_proc_stat(int pid) {
    ProcessInfo p{}; p.pid = pid;
    std::ifstream f("/proc/" + std::to_string(pid) + "/stat");
    if (!f) return p;
    std::string line; std::getline(f, line);

    auto lp = line.find('(');
    auto rp = line.rfind(')');
    if (lp != std::string::npos && rp != std::string::npos)
        p.name = line.substr(lp + 1, rp - lp - 1);

    std::istringstream iss(line.substr(rp + 2));
    std::vector<std::string> tk;
    std::string t; while (iss >> t) tk.push_back(t);

    if (tk.size() >= 22) {
        p.state = tk[0].empty() ? '?' : tk[0][0];
        p.utime     = std::stoul(tk[11]);
        p.stime     = std::stoul(tk[12]);
        p.threads   = std::stoi(tk[17]);
        p.vsize     = std::stol(tk[20]);
        p.rss_pages = std::stol(tk[21]);
    }
    p.total_time = p.utime + p.stime;
    return p;
}

static std::string read_proc_cmdline(int pid) {
    std::ifstream f("/proc/" + std::to_string(pid) + "/cmdline", std::ios::binary);
    if (!f) return "";

    std::string r((std::istreambuf_iterator<char>(f)),
                  std::istreambuf_iterator<char>());

    std::replace(r.begin(), r.end(), '\0', ' ');
    while (!r.empty() && r.back() == ' ') r.pop_back();
    return r;
}

static float get_uptime() { std::ifstream f("/proc/uptime"); float v = 0; f >> v; return v; }
static long get_page_size() { return sysconf(_SC_PAGESIZE); }
static long get_total_ram() { struct sysinfo si; sysinfo(&si); return si.totalram * si.mem_unit; }
static int get_cpu_count() { return sysconf(_SC_NPROCESSORS_ONLN); }

// ========== Comando: procs ==========
void cmd_procs(const CliParser& cli) {
    int count       = cli.get_int("count", 20);
    std::string sort_by = cli.get("sort", "cpu");
    std::string filter  = cli.get("filter", "");

    long page_sz  = get_page_size();
    long total_ram = get_total_ram();
    float uptime   = get_uptime();
    int ncpu       = get_cpu_count();
    long clk_tck   = sysconf(_SC_CLK_TCK);

    std::vector<ProcessInfo> procs;
    for (auto& e : fs::directory_iterator("/proc")) {
        if (!e.is_directory()) continue;
        std::string nm = e.path().filename();
        if (nm.empty() || !std::isdigit(nm[0])) continue;
        int pid = std::stoi(nm);
        auto p = read_proc_stat(pid);
        p.cmdline = read_proc_cmdline(pid);
        if (!p.name.empty()) {
            p.mem_pct = (float)(p.rss_pages * page_sz) / total_ram * 100.0f;
            p.cpu_pct = clk_tck > 0
                ? (float)p.total_time / clk_tck / std::max(uptime, 0.01f) / ncpu * 100.0f
                : 0.0f;
            procs.push_back(p);
        }
    }

    if (!filter.empty()) {
        procs.erase(std::remove_if(procs.begin(), procs.end(),
            [&](const ProcessInfo& p) {
                return p.name.find(filter) == std::string::npos &&
                       p.cmdline.find(filter) == std::string::npos;
            }), procs.end());
    }

    if (sort_by == "mem")
        std::sort(procs.begin(), procs.end(), [](auto& a, auto& b) { return a.mem_pct > b.mem_pct; });
    else if (sort_by == "pid")
        std::sort(procs.begin(), procs.end(), [](auto& a, auto& b) { return a.pid < b.pid; });
    else
        std::sort(procs.begin(), procs.end(), [](auto& a, auto& b) { return a.cpu_pct > b.cpu_pct; });

    if (use_color) std::cout << color::bold << color::cyan;
    std::cout << std::left
              << std::setw(8)  << "PID"
              << std::setw(10) << "CPU%"
              << std::setw(10) << "MEM%"
              << std::setw(12) << "RSS(MB)"
              << std::setw(6)  << "S"
              << std::setw(8)  << "THR"
              << "COMMAND";
    if (use_color) std::cout << color::reset;
    std::cout << "\n" << std::string(85, '-') << "\n";

    int shown = 0;
    for (auto& p : procs) {
        if (shown++ >= count) break;
        double rss_mb = (double)(p.rss_pages * page_sz) / (1024.0 * 1024.0);

        if (use_color) {
            if (p.cpu_pct > 50 || p.mem_pct > 50) std::cout << color::red;
            else if (p.cpu_pct > 20 || p.mem_pct > 20) std::cout << color::yellow;
            else std::cout << color::green;
        }

        std::cout << std::left << std::fixed << std::setprecision(1)
                  << std::setw(8)  << p.pid
                  << std::setw(10) << p.cpu_pct
                  << std::setw(10) << p.mem_pct
                  << std::setw(12) << rss_mb
                  << std::setw(6)  << p.state
                  << std::setw(8)  << p.threads;

        if (use_color) std::cout << color::bold;
        std::cout << (p.cmdline.empty() ? "[" + p.name + "]" : p.cmdline);
        if (use_color) std::cout << color::reset;
        std::cout << "\n";
    }

    std::cout << "\n";
    if (use_color) std::cout << color::dim;
    std::cout << "Total: " << procs.size()
              << " | Exibindo: " << std::min(count, (int)procs.size())
              << " | CPUs: " << ncpu
              << " | Uptime: " << (int)uptime << "s";
    if (use_color) std::cout << color::reset;
    std::cout << "\n";
}

// ========== Comando: disk ==========
void cmd_disk(const CliParser& cli) {
    std::string path = cli.positional.empty() ? cli.get("path", "/") : cli.positional[0];
    bool human = !cli.has("bytes");

    auto fmt = [&](unsigned long long b) -> std::string {
        if (!human) return std::to_string(b) + " B";
        const char* u[] = {"B","KB","MB","GB","TB","PB"};
        int i = 0; double s = b;
        while (s >= 1024 && i < 5) { s /= 1024; i++; }
        std::ostringstream o; o << std::fixed << std::setprecision(2) << s << " " << u[i];
        return o.str();
    };

    struct statvfs sv;
    if (statvfs(path.c_str(), &sv) != 0) {
        std::cerr << "Erro: não foi possível obter info de " << path << "\n";
        return;
    }

    unsigned long long total = sv.f_blocks * sv.f_frsize;
    unsigned long long free_  = sv.f_bfree  * sv.f_frsize;
    unsigned long long avail  = sv.f_bavail * sv.f_frsize;
    unsigned long long used   = total - free_;
    float pct = total > 0 ? (float)used / total * 100.0f : 0.0f;

    if (use_color) std::cout << color::bold << color::cyan;
    std::cout << "Uso de Disco: " << path;
    if (use_color) std::cout << color::reset;
    std::cout << "\n\n";

    progress_bar(pct, 40, " Disco ");
    end_progress();
    std::cout << "\n";

    if (use_color) std::cout << color::bold;
    std::cout << "  Total:     " << fmt(total) << "\n";
    std::cout << "  Usado:     " << fmt(used)  << "\n";
    std::cout << "  Disponível:" << fmt(avail) << " (para usuário)\n";
    std::cout << "  Livre:     " << fmt(free_) << " (total livre)\n";
    if (use_color) std::cout << color::reset;
    std::cout << "\n  Blocos: " << sv.f_blocks
              << " | Tam. bloco: " << sv.f_frsize
              << " | Inodes: " << sv.f_files
              << " | Inodes livres: " << sv.f_ffree << "\n";

    if (cli.has("all")) {
        std::cout << "\n";
        if (use_color) std::cout << color::bold << color::cyan;
        std::cout << "Todas as partições montadas:";
        if (use_color) std::cout << color::reset;
        std::cout << "\n\n";

        std::ifstream mounts("/proc/mounts");
        std::string line; std::set<std::string> seen;
        while (std::getline(mounts, line)) {
            std::istringstream iss(line);
            std::string dev, mnt, fstype;
            iss >> dev >> mnt >> fstype;
            if (dev.find("/dev/") == 0 && seen.insert(mnt).second) {
                struct statvfs sv2;
                if (statvfs(mnt.c_str(), &sv2) == 0) {
                    unsigned long long t2 = sv2.f_blocks * sv2.f_frsize;
                    unsigned long long u2 = t2 - (sv2.f_bfree * sv2.f_frsize);
                    float p2 = t2 > 0 ? (float)u2 / t2 * 100.0f : 0.0f;
                    progress_bar(p2, 25, " " + mnt + " ");
                    std::cout << "  " << fmt(u2) << "/" << fmt(t2);
                    end_progress();
                }
            }
        }
    }
}

// ========== Comando: mem ==========
void cmd_mem(const CliParser& cli) {
    bool human = !cli.has("bytes");
    int watch  = cli.get_int("watch", 0);

    auto fmt = [&](unsigned long long b) -> std::string {
        if (!human) return std::to_string(b) + " B";
        const char* u[] = {"B","KB","MB","GB","TB"};
        int i = 0; double s = b;
        while (s >= 1024 && i < 4) { s /= 1024; i++; }
        std::ostringstream o; o << std::fixed << std::setprecision(2) << s << " " << u[i];
        return o.str();
    };

    do {
        if (watch > 0) std::cout << "\033[2J\033[H";

        struct sysinfo si; sysinfo(&si);
        unsigned long long total_ram  = si.totalram  * si.mem_unit;
        unsigned long long free_ram   = si.freeram   * si.mem_unit;
        unsigned long long buffers     = si.bufferram * si.mem_unit;
        unsigned long long shared      = si.sharedram * si.mem_unit;
        unsigned long long used_ram    = total_ram - free_ram - buffers;
        float ram_pct = total_ram > 0 ? (float)used_ram / total_ram * 100.0f : 0.0f;

        unsigned long long total_swap = si.totalswap * si.mem_unit;
        unsigned long long free_swap  = si.freeswap  * si.mem_unit;
        unsigned long long used_swap  = total_swap - free_swap;
        float swap_pct = total_swap > 0 ? (float)used_swap / total_swap * 100.0f : 0.0f;

        if (use_color) std::cout << color::bold << color::cyan;
        std::cout << "Uso de Memória";
        if (use_color) std::cout << color::reset;
        std::cout << "\n\n";

        progress_bar(ram_pct, 40, " RAM  ");
        end_progress();
        std::cout << "\n";
        if (use_color) std::cout << color::bold;
        std::cout << "  Total:     " << fmt(total_ram)  << "\n";
        std::cout << "  Usado:     " << fmt(used_ram)   << "\n";
        std::cout << "  Livre:     " << fmt(free_ram)   << "\n";
        std::cout << "  Buffers:   " << fmt(buffers)    << "\n";
        std::cout << "  Shared:    " << fmt(shared)     << "\n";
        if (use_color) std::cout << color::reset;
        std::cout << "\n";

        if (total_swap > 0) {
            progress_bar(swap_pct, 40, " Swap ");
            end_progress();
            std::cout << "\n";
            if (use_color) std::cout << color::bold;
            std::cout << "  Total:     " << fmt(total_swap) << "\n";
            std::cout << "  Usado:     " << fmt(used_swap)  << "\n";
            std::cout << "  Livre:     " << fmt(free_swap)  << "\n";
            if (use_color) std::cout << color::reset;
        } else {
            std::cout << "  Swap: desabilitado\n";
        }

        std::cout << "\n";
        if (use_color) std::cout << color::dim;
        std::cout << "  Uptime: " << si.uptime << "s"
                  << " | Load: " << std::fixed << std::setprecision(2)
                  << si.loads[0]/65536.0 << " "
                  << si.loads[1]/65536.0 << " "
                  << si.loads[2]/65536.0;
        if (use_color) std::cout << color::reset;
        std::cout << "\n";

        if (watch > 0) {
            std::this_thread::sleep_for(std::chrono::seconds(watch));
        }
    } while (watch > 0);
}

// ========== Comando: logs ==========
void cmd_logs(const CliParser& cli) {
    int lines      = cli.get_int("lines", 20);
    std::string filter = cli.get("filter", "");
    std::string file   = cli.get("file", "");
    bool follow = cli.has("follow") || cli.has("f");

    if (file.empty()) {
        for (const auto& p : {"/var/log/syslog", "/var/log/kern.log", "/var/log/auth.log", "/var/log/dmesg"}) {
            if (fs::exists(p)) { file = p; break; }
        }
        if (file.empty()) {
            std::cerr << "Nenhum log encontrado. Use --file <caminho>.\n";
            return;
        }
    }

    if (use_color) std::cout << color::bold << color::cyan;
    std::cout << "Logs: " << file;
    if (!filter.empty()) std::cout << " | Filtro: \"" << filter << "\"";
    if (use_color) std::cout << color::reset;
    std::cout << "\n\n";

    std::ifstream f(file);
    if (!f) {
        std::cerr << "Erro ao abrir " << file << " (tente sudo).\n";
        return;
    }

    std::vector<std::string> all;
    std::string l;
    while (std::getline(f, l)) {
        if (filter.empty() || l.find(filter) != std::string::npos)
            all.push_back(l);
    }

    int start = std::max(0, (int)all.size() - lines);
    for (int i = start; i < (int)all.size(); i++) {
        const auto& s = all[i];
        if (use_color) {
            std::string sl = s;
            std::transform(sl.begin(), sl.end(), sl.begin(), ::tolower);
            if (sl.find("error") != std::string::npos || sl.find("crit") != std::string::npos || sl.find("emerg") != std::string::npos)
                std::cout << color::red;
            else if (sl.find("warn") != std::string::npos)
                std::cout << color::yellow;
            else if (sl.find("info") != std::string::npos)
                std::cout << color::green;
            else if (sl.find("debug") != std::string::npos)
                std::cout << color::dim;
            else
                std::cout << color::cyan;
        }
        std::cout << s;
        if (use_color) std::cout << color::reset;
        std::cout << "\n";
    }

    if (follow) {
        if (use_color) std::cout << color::dim;
        std::cout << "\n--- Seguindo log (Ctrl+C p/ sair) ---\n";
        if (use_color) std::cout << color::reset;
        f.clear(); f.seekg(0, std::ios::end);
        while (true) {
            std::string nl;
            if (std::getline(f, nl)) {
                if (filter.empty() || nl.find(filter) != std::string::npos)
                    std::cout << nl << "\n" << std::flush;
            } else {
                std::this_thread::sleep_for(std::chrono::milliseconds(500));
                f.clear();
            }
        }
    }
}

// ========== Ajuda ==========
void print_help() {
    if (use_color) std::cout << color::bold << color::cyan;
    std::cout << "POLYDEV | WX-TOOLS — wxt-cpp-004-system-monitor v1.0\n";
    if (use_color) std::cout << color::reset;
    std::cout << "\nUso: wxt-cpp-004-system-monitor <comando> [opções]\n\n";
    std::cout << "Comandos:\n";
    std::cout << "  procs   Monitora processos do sistema\n";
    std::cout << "  disk    Exibe uso de disco e partições\n";
    std::cout << "  mem     Exibe uso de memória e swap\n";
    std::cout << "  logs    Visualiza e filtra logs do sistema\n\n";
    std::cout << "Opções globais:\n";
    std::cout << "  --no-color    Desabilita cores no terminal\n";
    std::cout << "  -h, --help    Exibe esta ajuda\n\n";
    std::cout << "Comando 'procs':\n";
    std::cout << "  --sort FIELD  Ordena por: cpu (padrão), mem, pid\n";
    std::cout << "  --filter STR  Filtra processos por nome/cmdline\n";
    std::cout << "  --count N     Número de processos (padrão: 20)\n\n";
    std::cout << "Comando 'disk':\n";
    std::cout << "  --path DIR    Caminho (padrão: /)\n";
    std::cout << "  --all         Lista todas partições montadas\n";
    std::cout << "  --bytes       Exibe em bytes\n\n";
    std::cout << "Comando 'mem':\n";
    std::cout << "  --watch N     Atualiza a cada N segundos\n";
    std::cout << "  --bytes       Exibe em bytes\n\n";
    std::cout << "Comando 'logs':\n";
    std::cout << "  --file PATH   Arquivo de log\n";
    std::cout << "  --lines N     Últimas N linhas (padrão: 20)\n";
    std::cout << "  --filter STR  Filtra linhas contendo STR\n";
    std::cout << "  --follow, -f  Segue log em tempo real\n";
}

// ========== Main ==========
int main(int argc, char* argv[]) {
    CliParser cli; cli.parse(argc, argv);

    if (cli.help_requested || cli.subcommand.empty()) {
        print_help();
        return 0;
    }

    if      (cli.subcommand == "procs") cmd_procs(cli);
    else if (cli.subcommand == "disk")  cmd_disk(cli);
    else if (cli.subcommand == "mem")   cmd_mem(cli);
    else if (cli.subcommand == "logs")  cmd_logs(cli);
    else {
        std::cerr << "Comando desconhecido: " << cli.subcommand << "\n";
        print_help();
        return 1;
    }
    return 0;
}
