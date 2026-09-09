/*
 * POLYDEV | WX-TOOLS — wxt-cpp-005-network-tools v1.0
 * Compilação: g++-13 -std=c++17 -O2 wxt-cpp-005-network-tools.cpp -o wxt-cpp-005-network-tools -lpthread
 * Requer: Linux Ubuntu 24.04+, ferramentas: ip, ping, nslookup, ss/netstat
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
#include <mutex>
#include <future>
#include <atomic>
#include <cstring>
#include <cstdlib>
#include <cstdio>
#include <array>

#include <dirent.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/time.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <signal.h>
#include <netdb.h>
#include <cctype>

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

    if (use_color)
        std::cout << color::dim << label << color::reset
                  << "[" << bar_color << std::string(filled, '#') << color::reset
                  << std::string(width - filled, '-') << "] "
                  << bar_color << std::fixed << std::setprecision(1) << pct << "%" << color::reset;
    else
        std::cout << label << "[" << std::string(filled, '#')
                  << std::string(width - filled, '-') << "] "
                  << std::fixed << std::setprecision(1) << pct << "%";
}

void end_progress() { std::cout << std::endl; }

// ========== Spinner ==========
class Spinner {
    int frames_shown = 0;
    const char* seq[4] = {"⠋","⠙","⠹","⠸"};
public:
    void tick() {
        if (use_color) std::cout << color::cyan << "\r" << seq[frames_shown % 4] << " " << color::reset << std::flush;
        else std::cout << "\r. " << std::flush;
        frames_shown++;
    }
    void done() { std::cout << "\r  " << "\r" << std::flush; }
};

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

bool is_safe_net_token(const std::string& value) {
    if (value.empty()) return false;
    for (unsigned char ch : value) {
        if (!(std::isalnum(ch) || ch == '.' || ch == ':' || ch == '-' || ch == '_')) return false;
    }
    return true;
}

// ========== Executar comando e capturar saída ==========
std::string exec_cmd(const std::string& cmd) {
    std::array<char, 4096> buf;
    std::string result;
    auto pipe = popen(cmd.c_str(), "r");
    if (!pipe) return "";
    while (fgets(buf.data(), buf.size(), pipe)) result += buf.data();
    pclose(pipe);
    while (!result.empty() && (result.back() == '\n' || result.back() == '\r')) result.pop_back();
    return result;
}

// ========== Port Scanner ==========
enum class PortState { OPEN, CLOSED, FILTERED };

struct ScanResult {
    int port;
    std::string service;
    PortState state;
    double latency_ms;
};

bool scan_tcp_port(const std::string& host, int port, int timeout_ms) {
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) return false;

    struct timeval tv;
    tv.tv_sec  = timeout_ms / 1000;
    tv.tv_usec = (timeout_ms % 1000) * 1000;
    setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));
    setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO, &tv, sizeof(tv));

    struct sockaddr_in addr{};
    addr.sin_family = AF_INET;
    addr.sin_port   = htons(port);

    if (inet_pton(AF_INET, host.c_str(), &addr.sin_addr) != 1) {
        struct addrinfo hints{};
        hints.ai_family = AF_INET;
        hints.ai_socktype = SOCK_STREAM;
        struct addrinfo* res = nullptr;
        if (getaddrinfo(host.c_str(), nullptr, &hints, &res) != 0 || !res) {
            close(sock);
            if (res) freeaddrinfo(res);
            return false;
        }
        auto* resolved = reinterpret_cast<struct sockaddr_in*>(res->ai_addr);
        addr.sin_addr = resolved->sin_addr;
        freeaddrinfo(res);
    }

    // Set non-blocking
    int flags = fcntl(sock, F_GETFL, 0);
    fcntl(sock, F_SETFL, flags | O_NONBLOCK);

    auto t0 = std::chrono::high_resolution_clock::now();
    int res = connect(sock, (struct sockaddr*)&addr, sizeof(addr));

    if (res < 0 && errno == EINPROGRESS) {
        fd_set wfds;
        FD_ZERO(&wfds);
        FD_SET(sock, &wfds);
        tv.tv_sec  = timeout_ms / 1000;
        tv.tv_usec = (timeout_ms % 1000) * 1000;
        res = select(sock + 1, nullptr, &wfds, nullptr, &tv);
        if (res > 0) {
            int soerr = 0; socklen_t sl = sizeof(soerr);
            getsockopt(sock, SOL_SOCKET, SO_ERROR, &soerr, &sl);
            res = soerr == 0 ? 0 : -1;
        }
    }

    auto t1 = std::chrono::high_resolution_clock::now();
    double ms = std::chrono::duration<double, std::milli>(t1 - t0).count();
    close(sock);

    return res == 0;
}

std::string get_service_name(int port) {
    static std::map<int, std::string> common = {
        {21,"ftp"},{22,"ssh"},{23,"telnet"},{25,"smtp"},{53,"dns"},
        {80,"http"},{110,"pop3"},{143,"imap"},{443,"https"},{993,"imaps"},
        {995,"pop3s"},{3306,"mysql"},{5432,"postgresql"},{6379,"redis"},
        {8080,"http-proxy"},{8443,"https-alt"},{27017,"mongodb"}
    };
    auto it = common.find(port);
    return it != common.end() ? it->second : "unknown";
}

void cmd_scan(const CliParser& cli) {
    std::string host   = cli.has("host") ? cli.get("host") : (cli.positional.size() > 0 ? cli.positional[0] : "127.0.0.1");
    int start_port     = cli.get_int("start", 1);
    int end_port       = cli.get_int("end", 1024);
    int timeout        = cli.get_int("timeout", 1000);
    int threads        = cli.get_int("threads", 64);
    bool common_only  = cli.has("common");

    if (!is_safe_net_token(host)) {
        std::cerr << "Erro: host inválido.\n";
        return;
    }
    if (start_port < 1 || start_port > 65535 || end_port < 1 || end_port > 65535 || start_port > end_port) {
        std::cerr << "Erro: intervalo de portas inválido (1-65535).\n";
        return;
    }
    if (timeout < 1) timeout = 1000;
    if (threads < 1) threads = 1;

    if (common_only) {
        std::vector<int> ports = {21,22,23,25,53,80,110,143,443,993,995,3306,5432,6379,8080,8443,27017};
        start_port = 1; end_port = 65535;
        // will filter later
    }

    if (use_color) std::cout << color::bold << color::cyan;
    std::cout << "Port Scanner - " << host << " (" << start_port << "-" << end_port << ")";
    if (use_color) std::cout << color::reset;
    std::cout << "\n\n";

    std::vector<int> ports_to_scan;
    if (common_only) {
        ports_to_scan = {21,22,23,25,53,80,110,143,443,993,995,3306,5432,6379,8080,8443,27017};
    } else {
        for (int p = start_port; p <= end_port; ++p) ports_to_scan.push_back(p);
    }

    int total = ports_to_scan.size();
    std::atomic<int> scanned{0};
    std::atomic<int> open_count{0};
    std::mutex results_mutex;
    std::vector<ScanResult> open_ports;

    std::vector<std::future<void>> futures;
    const int worker_count = std::min(threads, std::max(1, total));
    std::atomic<int> next_index{0};

    for (int t = 0; t < worker_count; ++t) {
        futures.push_back(std::async(std::launch::async, [&]() {
            while (true) {
                int i = next_index.fetch_add(1);
                if (i >= total) break;

                int port = ports_to_scan[i];
                bool open = scan_tcp_port(host, port, timeout);
                scanned++;
                if (open) {
                    std::lock_guard<std::mutex> lk(results_mutex);
                    open_ports.push_back({port, get_service_name(port), PortState::OPEN, 0.0});
                    open_count++;
                }
            }
        }));
    }

    // Progress display
    auto display = std::async(std::launch::async, [&]() {
        while (scanned < total) {
            float pct = (float)scanned / total * 100.0f;
            std::cout << "\r";
            progress_bar(pct, 40, " Scan ");
            if (use_color) std::cout << color::dim;
            std::cout << "  " << scanned << "/" << total << " (" << open_count << " open)";
            if (use_color) std::cout << color::reset;
            std::cout << std::flush;
            std::this_thread::sleep_for(std::chrono::milliseconds(150));
        }
        std::cout << "\r";
        progress_bar(100.0f, 40, " Scan ");
        if (use_color) std::cout << color::dim;
        std::cout << "  " << total << "/" << total << " (" << open_count << " open)";
        if (use_color) std::cout << color::reset;
        end_progress();
    });

    for (auto& f : futures) f.get();
    scanned = total; // ensure display exits
    display.get();

    std::sort(open_ports.begin(), open_ports.end(), [](auto& a, auto& b) { return a.port < b.port; });

    std::cout << "\n";
    if (use_color) std::cout << color::bold << color::cyan;
    std::cout << "Portas Abertas:";
    if (use_color) std::cout << color::reset;
    std::cout << "\n\n";

    if (use_color) std::cout << color::bold;
    std::cout << std::left
              << std::setw(10) << "PORTA"
              << std::setw(15) << "SERVIÇO"
              << "ESTADO";
    if (use_color) std::cout << color::reset;
    std::cout << "\n" << std::string(45, '-') << "\n";

    for (auto& r : open_ports) {
        if (use_color) std::cout << color::green << color::bold;
        std::cout << std::left
                  << std::setw(10) << r.port
                  << std::setw(15) << r.service;
        if (use_color) std::cout << color::green;
        std::cout << "OPEN";
        if (use_color) std::cout << color::reset;
        std::cout << "\n";
    }

    if (open_ports.empty()) {
        if (use_color) std::cout << color::yellow;
        std::cout << "  Nenhuma porta aberta encontrada.\n";
        if (use_color) std::cout << color::reset;
    }

    std::cout << "\n";
    if (use_color) std::cout << color::dim;
    std::cout << "  Total: " << total << " escaneadas | " << open_count << " abertas | Timeout: " << timeout << "ms";
    if (use_color) std::cout << color::reset;
    std::cout << "\n";
}

// ========== Ping Múltiplo ==========
void cmd_ping(const CliParser& cli) {
    int count = cli.get_int("count", 4);
    int timeout_sec = cli.get_int("timeout", 5);
    bool parallel = !cli.has("serial");

    if (count < 1) count = 1;
    if (timeout_sec < 1) timeout_sec = 1;

    if (cli.positional.empty() && !cli.has("hosts")) {
        std::cerr << "Erro: informe hosts. Ex: wxt-cpp-005-network-tools ping 8.8.8.8 1.1.1.1\n";
        return;
    }

    std::vector<std::string> hosts = cli.positional;
    if (cli.has("hosts")) {
        std::istringstream iss(cli.get("hosts"));
        std::string h;
        while (std::getline(iss, h, ',')) {
            while (!h.empty() && h.front() == ' ') h.erase(h.begin());
            while (!h.empty() && h.back() == ' ')  h.pop_back();
            if (!h.empty()) hosts.push_back(h);
        }
    }

    if (use_color) std::cout << color::bold << color::cyan;
    std::cout << "Ping Múltiplo (" << count << " pacotes, timeout " << timeout_sec << "s)";
    if (use_color) std::cout << color::reset;
    std::cout << "\n\n";

    struct PingResult {
        std::string host;
        bool success;
        double avg_ms;
        double min_ms;
        double max_ms;
        int sent;
        int recv;
        float loss_pct;
    };

    std::mutex mtx;
    std::vector<PingResult> results;

    auto ping_one = [&](const std::string& host) -> PingResult {
        PingResult r{}; r.host = host; r.sent = count;
        if (!is_safe_net_token(host)) return r;
        std::string cmd = "ping -c " + std::to_string(count)
                         + " -W " + std::to_string(timeout_sec)
                         + " " + host + " 2>&1";
        std::string out = exec_cmd(cmd);

        // Parse rtt
        auto rtt_pos = out.find("rtt min/avg/max/mdev = ");
        if (rtt_pos != std::string::npos) {
            auto sub = out.substr(rtt_pos + 24);
            std::istringstream iss(sub);
            std::string val; double v[4]; int i = 0;
            while (std::getline(iss, val, '/') && i < 4) {
                try { v[i] = std::stod(val); } catch (...) { v[i] = 0; }
                i++;
            }
            r.min_ms = v[0]; r.avg_ms = v[1]; r.max_ms = v[2];
        }

        // Parse packet loss
        auto loss_pos = out.find(" received, ");
        if (loss_pos != std::string::npos) {
            auto sub = out.substr(loss_pos + 11);
            auto pct_pos = sub.find("% packet loss");
            if (pct_pos != std::string::npos) {
                try { r.loss_pct = std::stof(sub.substr(0, pct_pos)); } catch (...) {}
            }
        }

        // Parse received
        auto recv_pos = out.find(" packets transmitted, ");
        if (recv_pos != std::string::npos) {
            auto sub = out.substr(recv_pos + 22);
            try { r.recv = std::stoi(sub); } catch (...) {}
        }

        r.success = r.recv > 0;
        return r;
    };

    if (parallel) {
        std::vector<std::future<PingResult>> futs;
        for (auto& h : hosts) futs.push_back(std::async(std::launch::async, ping_one, h));

        Spinner sp;
        int done = 0;
        while (done < (int)futs.size()) {
            done = 0;
            for (auto& f : futs) {
                if (f.wait_for(std::chrono::seconds(0)) == std::future_status::ready) done++;
            }
            sp.tick();
            std::this_thread::sleep_for(std::chrono::milliseconds(100));
        }
        sp.done();

        for (auto& f : futs) results.push_back(f.get());
    } else {
        for (auto& h : hosts) results.push_back(ping_one(h));
    }

    // Table
    if (use_color) std::cout << color::bold;
    std::cout << std::left
              << std::setw(22) << "HOST"
              << std::setw(10) << "STATUS"
              << std::setw(10) << "AVG(ms)"
              << std::setw(10) << "MIN(ms)"
              << std::setw(10) << "MAX(ms)"
              << std::setw(8)  << "PERDA"
              << "RECV";
    if (use_color) std::cout << color::reset;
    std::cout << "\n" << std::string(80, '-') << "\n";

    for (auto& r : results) {
        if (use_color) {
            if (r.success && r.loss_pct == 0) std::cout << color::green;
            else if (r.success) std::cout << color::yellow;
            else std::cout << color::red;
        }
        std::cout << std::left << std::fixed << std::setprecision(2)
                  << std::setw(22) << r.host
                  << std::setw(10) << (r.success ? "UP" : "DOWN")
                  << std::setw(10) << r.avg_ms
                  << std::setw(10) << r.min_ms
                  << std::setw(10) << r.max_ms
                  << std::setw(8)  << r.loss_pct
                  << r.recv << "/" << r.sent;
        if (use_color) std::cout << color::reset;
        std::cout << "\n";
    }
}

// ========== DNS Lookup ==========
void cmd_dns(const CliParser& cli) {
    if (cli.positional.empty()) {
        std::cerr << "Erro: informe um domínio. Ex: wxt-cpp-005-network-tools dns google.com\n";
        return;
    }

    std::string domain = cli.positional[0];
    std::string dns_server = cli.get("server", "");
    bool verbose = cli.has("verbose") || cli.has("v");

    if (!is_safe_net_token(domain) || (!dns_server.empty() && !is_safe_net_token(dns_server))) {
        std::cerr << "Erro: domínio ou servidor DNS inválido.\n";
        return;
    }

    if (use_color) std::cout << color::bold << color::cyan;
    std::cout << "DNS Lookup: " << domain;
    if (!dns_server.empty()) std::cout << " (servidor: " << dns_server << ")";
    if (use_color) std::cout << color::reset;
    std::cout << "\n\n";

    std::string ns_cmd = "nslookup " + domain;
    if (!dns_server.empty()) ns_cmd += " " + dns_server;
    ns_cmd += " 2>&1";
    std::string out = exec_cmd(ns_cmd);

    // Parse A records
    std::vector<std::string> a_records;
    std::istringstream iss(out);
    std::string line;
    bool in_answer = false;
    while (std::getline(iss, line)) {
        if (line.find("Name:") != std::string::npos) in_answer = true;
        if (in_answer && line.find("Address:") != std::string::npos) {
            auto pos = line.find(":");
            if (pos != std::string::npos) {
                std::string addr = line.substr(pos + 2);
                while (!addr.empty() && addr.front() == ' ') addr.erase(addr.begin());
                if (!addr.empty()) a_records.push_back(addr);
            }
        }
        // Also handle "Non-authoritative answer" section
        if (line.find("Addresses:") != std::string::npos) {
            auto pos = line.find(":");
            if (pos != std::string::npos) {
                std::string rest = line.substr(pos + 1);
                std::istringstream iss2(rest);
                std::string addr;
                while (iss2 >> addr) {
                    if (addr.find("#") != std::string::npos) continue;
                    a_records.push_back(addr);
                }
            }
        }
    }

    // Also try 'dig' if available for richer output
    std::string dig_cmd = "dig +short " + domain + " A 2>/dev/null";
    if (!dns_server.empty()) dig_cmd = "dig +short " + domain + " A @" + dns_server + " 2>/dev/null";
    std::string dig_out = exec_cmd(dig_cmd);
    if (!dig_out.empty()) {
        std::istringstream dis(dig_out);
        std::string a;
        while (std::getline(dis, a)) {
            if (!a.empty() && std::find(a_records.begin(), a_records.end(), a) == a_records.end())
                a_records.push_back(a);
        }
    }

    // CNAME
    std::string cname_cmd = "dig +short " + domain + " CNAME 2>/dev/null";
    std::string cname = exec_cmd(cname_cmd);

    // MX
    std::string mx_cmd = "dig +short " + domain + " MX 2>/dev/null";
    std::string mx_out = exec_cmd(mx_cmd);

    // NS
    std::string ns_cmd2 = "dig +short " + domain + " NS 2>/dev/null";
    std::string ns_out = exec_cmd(ns_cmd2);

    // TXT
    std::string txt_cmd = "dig +short " + domain + " TXT 2>/dev/null";
    std::string txt_out = exec_cmd(txt_cmd);

    // Display
    auto print_section = [&](const std::string& title, const std::string& content, const char* clr) {
        if (content.empty()) return;
        if (use_color) std::cout << color::bold << clr;
        std::cout << "  " << title << ":";
        if (use_color) std::cout << color::reset;
        std::cout << "\n";
        std::istringstream iss(content);
        std::string l;
        while (std::getline(iss, l)) {
            if (!l.empty()) {
                if (use_color) std::cout << clr;
                std::cout << "    " << l;
                if (use_color) std::cout << color::reset;
                std::cout << "\n";
            }
        }
        std::cout << "\n";
    };

    if (!a_records.empty()) {
        if (use_color) std::cout << color::bold << color::green;
        std::cout << "  Registros A (IPv4):";
        if (use_color) std::cout << color::reset;
        std::cout << "\n";
        for (auto& a : a_records) {
            if (use_color) std::cout << color::green;
            std::cout << "    " << a;
            if (use_color) std::cout << color::reset;
            std::cout << "\n";
        }
        std::cout << "\n";
    }

    print_section("CNAME", cname, color::cyan);
    print_section("MX (Mail Exchange)", mx_out, color::magenta);
    print_section("NS (Name Servers)", ns_out, color::yellow);
    print_section("TXT Records", txt_out, color::white);

    if (verbose) {
        if (use_color) std::cout << color::dim;
        std::cout << "\n--- Saída completa do nslookup ---\n";
        if (use_color) std::cout << color::reset;
        std::cout << out << "\n";
    }

    if (a_records.empty() && cname.empty() && mx_out.empty() && ns_out.empty()) {
        if (use_color) std::cout << color::red;
        std::cout << "  Nenhum registro encontrado para " << domain << "\n";
        if (use_color) std::cout << color::reset;
    }
}

// ========== Network Interfaces ==========
void cmd_ifaces(const CliParser& cli) {
    if (use_color) std::cout << color::bold << color::cyan;
    std::cout << "Interfaces de Rede";
    if (use_color) std::cout << color::reset;
    std::cout << "\n\n";

    std::string out = exec_cmd("ip -brief addr show 2>&1");
    std::istringstream iss(out);
    std::string line;

    if (use_color) std::cout << color::bold;
    std::cout << std::left
              << std::setw(16) << "INTERFACE"
              << std::setw(12) << "STATUS"
              << "ENDEREÇOS";
    if (use_color) std::cout << color::reset;
    std::cout << "\n" << std::string(70, '-') << "\n";

    while (std::getline(iss, line)) {
        std::istringstream ls(line);
        std::string iface, status, addr4, addr6;
        ls >> iface >> status;
        std::string rest;
        std::getline(ls, rest);

        while (!rest.empty() && rest.front() == ' ') rest.erase(rest.begin());

        if (use_color) {
            if (status.find("UP") != std::string::npos) std::cout << color::green;
            else std::cout << color::red;
        }
        std::cout << std::left << std::setw(16) << iface
                  << std::setw(12) << status;
        if (use_color) std::cout << color::cyan;
        std::cout << rest;
        if (use_color) std::cout << color::reset;
        std::cout << "\n";
    }
    std::cout << "\n";
}

// ========== Ajuda ==========
void print_help() {
    if (use_color) std::cout << color::bold << color::cyan;
    std::cout << "POLYDEV | WX-TOOLS — wxt-cpp-005-network-tools v1.0\n";
    if (use_color) std::cout << color::reset;
    std::cout << "\nUso: wxt-cpp-005-network-tools <comando> [opções]\n\n";
    std::cout << "Comandos:\n";
    std::cout << "  scan    Escaneia portas em um host\n";
    std::cout << "  ping    Ping múltiplo em paralelo\n";
    std::cout << "  dns     DNS lookup completo (A, CNAME, MX, NS, TXT)\n";
    std::cout << "  ifaces  Lista interfaces de rede\n\n";
    std::cout << "Opções globais:\n";
    std::cout << "  --no-color    Desabilita cores no terminal\n";
    std::cout << "  -h, --help    Exibe esta ajuda\n\n";
    std::cout << "Comando 'scan':\n";
    std::cout << "  --host HOST     Host alvo (padrão: 127.0.0.1)\n";
    std::cout << "  --start PORT    Porta inicial (padrão: 1)\n";
    std::cout << "  --end PORT      Porta final (padrão: 1024)\n";
    std::cout << "  --timeout MS    Timeout em ms (padrão: 1000)\n";
    std::cout << "  --threads N     Threads paralelas (padrão: 64)\n";
    std::cout << "  --common        Escaneia apenas portas comuns\n\n";
    std::cout << "Comando 'ping':\n";
    std::cout << "  --count N       Pacotes por host (padrão: 4)\n";
    std::cout << "  --timeout SECS  Timeout por pacote (padrão: 5)\n";
    std::cout << "  --serial        Executa pings sequencialmente\n\n";
    std::cout << "Comando 'dns':\n";
    std::cout << "  --server DNS    Servidor DNS para consulta\n";
    std::cout << "  --verbose, -v   Exibe saída completa do nslookup\n\n";
    std::cout << "Comando 'ifaces':\n";
    std::cout << "  (sem opções adicionais)\n";
}

// ========== Main ==========
int main(int argc, char* argv[]) {
    signal(SIGPIPE, SIG_IGN); // ignore broken pipe on socket ops

    CliParser cli; cli.parse(argc, argv);

    if (cli.help_requested || cli.subcommand.empty()) {
        print_help();
        return 0;
    }

    if      (cli.subcommand == "scan")   cmd_scan(cli);
    else if (cli.subcommand == "ping")   cmd_ping(cli);
    else if (cli.subcommand == "dns")    cmd_dns(cli);
    else if (cli.subcommand == "ifaces")  cmd_ifaces(cli);
    else {
        std::cerr << "Comando desconhecido: " << cli.subcommand << "\n";
        print_help();
        return 1;
    }
    return 0;
}
