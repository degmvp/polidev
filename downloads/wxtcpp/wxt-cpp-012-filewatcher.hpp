// ============================================================================
//  FileWatcher — monitor multiplataforma de alterações em arquivos (C++17)
//  Windows 10/11 (ReadDirectoryChangesW) | Linux (inotify, Ubuntu 24.04 OK)
//  Header-only. Sem dependências externas.
//
//  Uso:
//    fw::FileWatcher w;
//    w.start("C:/dados", [](const std::vector<fw::Event>& evs) { ... });
//    // ...
//    w.stop();
//
//  Obs.: o callback roda numa thread própria — não chame stop() de dentro dele.
// ============================================================================
#pragma once

#include <algorithm>
#include <atomic>
#include <chrono>
#include <condition_variable>
#include <cstdint>
#include <cwctype>
#include <deque>
#include <filesystem>
#include <functional>
#include <map>
#include <mutex>
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
  #include <cerrno>
  #include <ctime>
  #include <poll.h>
  #include <sys/eventfd.h>
  #include <sys/inotify.h>
  #include <unistd.h>
#endif

namespace fw {
namespace fs = std::filesystem;

// ------------------------------------------------------------------ eventos
enum class EventType { Created, Modified, Deleted, Renamed };

inline const char* to_string(EventType t) {
    switch (t) {
        case EventType::Created:  return "CREATED";
        case EventType::Modified: return "MODIFIED";
        case EventType::Deleted:  return "DELETED";
        case EventType::Renamed:  return "RENAMED";
    }
    return "?";
}

struct Event {
    EventType type    = EventType::Modified;
    fs::path  path;     // caminho do item (o NOVO caminho, em renomeações)
    fs::path  oldPath;  // preenchido apenas em Renamed (caminho anterior)
};

struct Options {
    bool        recursive  = true;   // Windows: nativo | Linux: watches por pasta
    int         debounceMs = 250;    // agrupa eventos (<=0 -> ~10 ms, quase imediato)
    // filtro por caminho completo; retornar false descarta o evento
    std::function<bool(const fs::path&)>    filter;
    std::function<void(const std::string&)> onError;   // avisos/erros não fatais
    std::function<void()>                   onReady;   // watches registrados
};

// ------------------------------------------------------------ UTF-8 helpers
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
inline std::string pathToUtf8(const fs::path& p) { return wideToUtf8(p.wstring()); }
#else
inline std::string pathToUtf8(const fs::path& p) { return p.string(); }
#endif

// ---------------------------------------------------------------- detalhes
namespace detail {

using Emit = std::function<void(Event)>;

// fila thread-safe entre a thread de leitura e a de emissão
class EventQueue {
public:
    void push(Event&& e) {
        { std::lock_guard<std::mutex> lk(m_); q_.emplace_back(std::move(e)); }
        cv_.notify_one();
    }
    void wake() { cv_.notify_all(); }
    void wait(int ms, const std::atomic<bool>& stop) {
        std::unique_lock<std::mutex> lk(m_);
        cv_.wait_for(lk, std::chrono::milliseconds(ms),
                     [&] { return stop.load() || !q_.empty(); });
    }
    void drain(std::vector<Event>& out) {
        std::lock_guard<std::mutex> lk(m_);
        out.insert(out.end(), std::make_move_iterator(q_.begin()),
                               std::make_move_iterator(q_.end()));
        q_.clear();
    }

    bool empty() {
        std::lock_guard<std::mutex> lk(m_);
        return q_.empty();
    }
private:
    std::mutex              m_;
    std::condition_variable cv_;
    std::deque<Event>       q_;
};

// chave de agrupamento (Windows: case-insensitive, como o FS)
inline std::string mergeKey(const fs::path& p) {
#ifdef _WIN32
    std::wstring w = p.wstring();
    for (wchar_t& c : w) c = (wchar_t)std::towlower((wint_t)c);
    return wideToUtf8(w);
#else
    return p.string();
#endif
}

// mescla eventos do mesmo caminho dentro da janela de debounce:
//   Created+Modified*      -> Created
//   Modified*              -> Modified
//   Created+Deleted        -> (nada: nasceu e morreu na janela)
//   Modified+Deleted       -> Deleted
//   Deleted+Created        -> Created (recriado)
//   Renamed                -> entregue como veio (backend já pareou)
inline void mergeBatch(std::vector<Event>& batch,
                       const std::function<bool(const fs::path&)>& filter,
                       std::vector<Event>& out)
{
    struct St { fs::path rep; bool created = false, modified = false, deleted = false; };
    std::map<std::string, St> states;
    std::vector<Event> renames;

    for (Event& e : batch) {
        if (e.type == EventType::Renamed) {
            states.erase(mergeKey(e.oldPath));
            states.erase(mergeKey(e.path));
            renames.push_back(std::move(e));
            continue;
        }
        St& s = states[mergeKey(e.path)];
        s.rep = e.path;
        switch (e.type) {
            case EventType::Created:  s.created  = true; s.deleted = false; break;
            case EventType::Modified: s.modified = true;                    break;
            case EventType::Deleted:  s.deleted  = true; s.created = false; break;
            default: break;
        }
    }
    out.reserve(out.size() + states.size() + renames.size());
    for (const auto& kv : states) {
        const St& s = kv.second;
        if      (s.deleted)  { if (!s.created) out.push_back({EventType::Deleted, s.rep, {}}); }
        else if (s.created)    out.push_back({EventType::Created,  s.rep, {}});
        else                   out.push_back({EventType::Modified, s.rep, {}});
    }
    for (Event& e : renames) out.push_back(std::move(e));

    if (filter) {
        out.erase(std::remove_if(out.begin(), out.end(),
                 [&](const Event& e) { return !filter(e.path); }), out.end());
    }
}

#ifdef _WIN32
// =========================================================== Windows ======
class Backend {
public:
    Backend(const fs::path& root, const Options& opt)
        : rootW_(root.wstring()), recursive_(opt.recursive),
          filter_(opt.filter), onError_(opt.onError), onReady_(opt.onReady) {}

    ~Backend() {
        if (hDir_ && hDir_ != INVALID_HANDLE_VALUE) ::CloseHandle(hDir_);
        if (ovl_.hEvent)                            ::CloseHandle(ovl_.hEvent);
        if (hStop_)                                 ::CloseHandle(hStop_);
    }

    void interrupt() {
        if (hStop_) ::SetEvent(hStop_);
        if (hDir_ && hDir_ != INVALID_HANDLE_VALUE) ::CancelIoEx(hDir_, nullptr);
    }

    void loop(std::atomic<bool>& stopFlag, const Emit& emit) {
        hDir_ = ::CreateFileW(rootW_.c_str(), FILE_LIST_DIRECTORY,
                              FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE,
                              nullptr, OPEN_EXISTING,
                              FILE_FLAG_BACKUP_SEMANTICS | FILE_FLAG_OVERLAPPED, nullptr);
        if (hDir_ == INVALID_HANDLE_VALUE) {
            fail("nao foi possivel abrir o diretorio (Win32 erro " +
                 std::to_string(::GetLastError()) + ")");
            return;
        }
        ovl_.hEvent = ::CreateEventW(nullptr, TRUE, FALSE, nullptr);
        hStop_      = ::CreateEventW(nullptr, TRUE, FALSE, nullptr);
        if (!ovl_.hEvent || !hStop_) { fail("falha ao criar eventos Win32"); return; }
        if (onReady_) onReady_();

        // 64 KiB: máximo suportado por compartilhamentos de rede (SMB)
        alignas(DWORD) unsigned char buf[64 * 1024];
        std::wstring pendingRename;

        while (!stopFlag.load()) {
            ::ResetEvent(ovl_.hEvent);
            const DWORD flt = FILE_NOTIFY_CHANGE_FILE_NAME | FILE_NOTIFY_CHANGE_DIR_NAME |
                              FILE_NOTIFY_CHANGE_LAST_WRITE | FILE_NOTIFY_CHANGE_SIZE |
                              FILE_NOTIFY_CHANGE_CREATION;
            if (!::ReadDirectoryChangesW(hDir_, buf, sizeof(buf),
                                         recursive_ ? TRUE : FALSE,
                                         flt, nullptr, &ovl_, nullptr)) {
                const DWORD e = ::GetLastError();
                if (e != ERROR_IO_PENDING) { fail("ReadDirectoryChangesW falhou (erro " + std::to_string(e) + ")"); break; }
            }

            HANDLE hs[2] = { ovl_.hEvent, hStop_ };
            const DWORD w = ::WaitForMultipleObjects(2, hs, FALSE, INFINITE);
            if (w != WAIT_OBJECT_0) {                    // parada (ou espera falhou)
                ::CancelIoEx(hDir_, &ovl_);              // conclui o I/O pendente…
                DWORD tb = 0;
                ::GetOverlappedResult(hDir_, &ovl_, &tb, TRUE); // …ANTES de sair
                break;
            }

            DWORD n = 0;
            if (!::GetOverlappedResult(hDir_, &ovl_, &n, FALSE)) {
                if (::GetLastError() == ERROR_OPERATION_ABORTED) break;
                fail("GetOverlappedResult falhou"); break;
            }
            if (n == 0) {   // estourou o buffer do kernel: eventos perdidos
                fail("buffer interno cheio; eventos podem ter sido perdidos (considere re-sincronizar)");
                continue;
            }

            auto* info = reinterpret_cast<FILE_NOTIFY_INFORMATION*>(buf);
            for (;;) {
                const std::wstring name(info->FileName, info->FileNameLength / sizeof(WCHAR));
                const fs::path p = name.empty() ? fs::path(rootW_) : (fs::path(rootW_) / name);
                const bool pass = !filter_ || filter_(p);

                switch (info->Action) {
                    case FILE_ACTION_ADDED:
                        if (pass) emit(Event{EventType::Created, p, {}});
                        break;
                    case FILE_ACTION_REMOVED:
                        if (pass) emit(Event{EventType::Deleted, p, {}});
                        break;
                    case FILE_ACTION_MODIFIED:
                        if (pass) emit(Event{EventType::Modified, p, {}});
                        break;
                    case FILE_ACTION_RENAMED_OLD_NAME:
                        pendingRename = pass ? p.wstring() : std::wstring();
                        break;
                    case FILE_ACTION_RENAMED_NEW_NAME:
                        if (!pendingRename.empty()) {
                            if (pass) emit(Event{EventType::Renamed, p, fs::path(pendingRename)});
                            else      emit(Event{EventType::Deleted, fs::path(pendingRename), {}});
                            pendingRename.clear();
                        } else if (pass) {
                            emit(Event{EventType::Created, p, {}});   // movido de fora
                        }
                        break;
                    default: break;
                }
                if (info->NextEntryOffset == 0) break;
                info = reinterpret_cast<FILE_NOTIFY_INFORMATION*>(
                    reinterpret_cast<unsigned char*>(info) + info->NextEntryOffset);
            }
            if (!pendingRename.empty()) {                   // OLD sem NEW: saiu da árvore
                emit(Event{EventType::Deleted, fs::path(pendingRename), {}});
                pendingRename.clear();
            }
        }
        // handles fechados no destrutor (interrupt() pode rodar depois do loop)
    }

private:
    void fail(const std::string& m) { if (onError_) onError_(m); }

    std::wstring rootW_;
    bool         recursive_;
    std::function<bool(const fs::path&)>    filter_;
    std::function<void(const std::string&)> onError_;
    std::function<void()>                   onReady_;
    HANDLE     hDir_ = INVALID_HANDLE_VALUE;
    OVERLAPPED ovl_{};
    HANDLE     hStop_ = nullptr;
};

#else
// ============================================================= Linux ======
class Backend {
public:
    Backend(const fs::path& root, const Options& opt)
        : root_(root), recursive_(opt.recursive),
          filter_(opt.filter), onError_(opt.onError), onReady_(opt.onReady) {}

    ~Backend() {
        if (inFd_   >= 0) ::close(inFd_);
        if (stopFd_ >= 0) ::close(stopFd_);
    }

    void interrupt() {
        if (stopFd_ >= 0) {
            const uint64_t one = 1;
            const ssize_t written = ::write(stopFd_, &one, sizeof one);
            if (written < 0 && errno != EAGAIN && errno != EINTR)
                fail("falha ao sinalizar parada via eventfd");
        }
    }

    void loop(std::atomic<bool>& stopFlag, const Emit& emit) {
        inFd_   = ::inotify_init1(IN_CLOEXEC);
        stopFd_ = ::eventfd(0, EFD_CLOEXEC | EFD_NONBLOCK);
        if (inFd_ < 0 || stopFd_ < 0) { fail("falha ao inicializar inotify/eventfd"); return; }

        const int watched = recursive_ ? addTree(root_) : addWatch(root_);
        if (watched == 0) { fail("nenhum diretorio pode ser observado"); return; }
        if (onReady_) onReady_();

        alignas(8) char buf[64 * 1024];

        while (!stopFlag.load()) {
            ::pollfd pfd[2] = { { inFd_, POLLIN, 0 }, { stopFd_, POLLIN, 0 } };
            if (::poll(pfd, 2, -1) < 0) {
                if (errno == EINTR) continue;            // ex.: Ctrl+C -> main chama stop()
                fail("poll() falhou"); break;
            }
            if (pfd[1].revents & POLLIN) break;          // pedido de parada

            expireOldRenames(emit);

            const ssize_t n = ::read(inFd_, buf, sizeof(buf));
            if (n <= 0) {
                if (n < 0 && (errno == EAGAIN || errno == EINTR)) continue;
                fail("read(inotify) falhou"); break;
            }

            const char* p = buf;
            const char* const end = buf + n;
            while (p + sizeof(inotify_event) <= end) {
                auto* ev = reinterpret_cast<const inotify_event*>(p);
                handleEvent(*ev, emit);
                p += sizeof(inotify_event) + (size_t)ev->len;
            }
        }
        // fds fechados no destrutor
    }

private:
    static constexpr uint32_t kMask = IN_CREATE | IN_DELETE | IN_MODIFY |
        IN_CLOSE_WRITE | IN_MOVED_FROM | IN_MOVED_TO | IN_DELETE_SELF;
    static constexpr std::time_t kCookieTtl = 5;         // segundos

    void fail(const std::string& m) { if (onError_) onError_(m); }

    int addWatch(const fs::path& dir) {
        const int wd = ::inotify_add_watch(inFd_, dir.c_str(), kMask);
        if (wd < 0) {
            if (errno == ENOSPC)
                fail("limite de watches do inotify atingido — aumente /proc/sys/fs/inotify/max_user_watches");
            return 0;
        }
        wdToPath_[wd] = dir;
        return 1;
    }

    int addTree(const fs::path& dir) {
        int count = addWatch(dir);
        std::error_code ec;
        fs::recursive_directory_iterator it(dir, fs::directory_options::skip_permission_denied, ec), end;
        if (ec) return count;
        for (; it != end; it.increment(ec)) {
            if (ec) { ec.clear(); continue; }
            std::error_code e2;
            if (it->is_symlink(e2) || e2) continue;      // evita loops
            if (it->is_directory(e2) && !e2) count += addWatch(it->path());
        }
        return count;
    }

    void expireOldRenames(const Emit& emit) {
        const std::time_t now = ::time(nullptr);
        for (auto it = cookieFrom_.begin(); it != cookieFrom_.end();) {
            if (now - it->second.second > kCookieTtl) {  // MOVED_FROM sem par: saiu da árvore
                emit(Event{EventType::Deleted, it->second.first, {}});
                it = cookieFrom_.erase(it);
            } else ++it;
        }
    }

    void remapDir(const fs::path& oldDir, const fs::path& newDir) {
        const std::string o = oldDir.string(), nn = newDir.string();
        std::map<int, fs::path> upd;
        for (const auto& kv : wdToPath_) {
            const std::string p = kv.second.string();
            if      (p == o)                 upd[kv.first] = newDir;
            else if (p.rfind(o + "/", 0) == 0) upd[kv.first] = fs::path(nn + "/" + p.substr(o.size() + 1));
            else                              upd[kv.first] = kv.second;
        }
        wdToPath_.swap(upd);
    }

    void handleEvent(const inotify_event& ev, const Emit& emit) {
        if (ev.mask & IN_Q_OVERFLOW) { fail("fila do kernel cheia (IN_Q_OVERFLOW): eventos perdidos"); return; }
        if (ev.mask & (IN_IGNORED | IN_DELETE_SELF)) { wdToPath_.erase(ev.wd); return; }

        const auto dirIt = wdToPath_.find(ev.wd);
        if (dirIt == wdToPath_.end()) return;
        const fs::path dir = dirIt->second;

        const std::string name = ev.len ? std::string(ev.name) : std::string();
        const fs::path full = name.empty() ? dir : (dir / name);
        const bool isDir = (ev.mask & IN_ISDIR) != 0;
        const bool pass  = !filter_ || filter_(full);

        if (ev.mask & IN_CREATE) {
            if (isDir && recursive_) addTree(full);      // nova pasta: observa o subtree
            if (pass) emit(Event{EventType::Created, full, {}});
        }
        else if (ev.mask & IN_DELETE) {
            if (pass) emit(Event{EventType::Deleted, full, {}});
        }
        else if (ev.mask & (IN_MODIFY | IN_CLOSE_WRITE)) {   // CLOSE_WRITE = gravação concluída
            if (pass) emit(Event{EventType::Modified, full, {}});
        }
        else if (ev.mask & IN_MOVED_FROM) {
            if (pass) cookieFrom_[ev.cookie] = { full, ::time(nullptr) };
        }
        else if (ev.mask & IN_MOVED_TO) {
            auto it = cookieFrom_.find(ev.cookie);
            if (it != cookieFrom_.end()) {
                const fs::path from = it->second.first;
                cookieFrom_.erase(it);
                if (pass) emit(Event{EventType::Renamed, full, from});
                else      emit(Event{EventType::Deleted, from, {}});
                if (isDir && recursive_) remapDir(from, full);
            } else {
                if (isDir && recursive_) addTree(full);  // movido de fora da árvore
                if (pass) emit(Event{EventType::Created, full, {}});
            }
        }
    }

    fs::path root_;
    bool     recursive_;
    std::function<bool(const fs::path&)>    filter_;
    std::function<void(const std::string&)> onError_;
    std::function<void()>                   onReady_;
    int inFd_ = -1, stopFd_ = -1;
    std::map<int, fs::path> wdToPath_;                              // wd -> pasta
    std::map<uint32_t, std::pair<fs::path, std::time_t>> cookieFrom_; // renames pendentes
};
#endif
} // namespace detail

// ============================================================== API =======
class FileWatcher {
public:
    using Callback = std::function<void(const std::vector<Event>&)>;

    FileWatcher() = default;
    ~FileWatcher() { stop(); }
    FileWatcher(const FileWatcher&)            = delete;
    FileWatcher& operator=(const FileWatcher&) = delete;

    void start(const fs::path& root, Callback cb, const Options& opt = {}) {
        std::lock_guard<std::mutex> lk(mtx_);
        if (running_.load()) throw std::logic_error("FileWatcher: ja em execucao");
        if (!cb)             throw std::logic_error("FileWatcher: callback nulo");

        cb_       = std::move(cb);
        filter_   = opt.filter;
        windowMs_ = opt.debounceMs;
        running_.store(true);
        stopFlag_.store(false);

        backend_ = std::make_unique<detail::Backend>(root, opt);
        emitter_ = std::thread([this] { emitLoop(); });
        reader_  = std::thread([this] {
            backend_->loop(stopFlag_, [this](Event e) { queue_.push(std::move(e)); });
        });
    }

    void stop() {
        std::unique_lock<std::mutex> lk(mtx_, std::try_to_lock);
        if (!lk.owns_lock() || !running_.load()) return;
        stopFlag_.store(true);
        if (backend_) backend_->interrupt();
        queue_.wake();
        if (reader_.joinable())   reader_.join();
        if (emitter_.joinable())  emitter_.join();
        backend_.reset();
        cb_ = nullptr; filter_ = nullptr;
        running_.store(false);
    }

    bool isRunning() const { return running_.load(std::memory_order_relaxed); }

private:
    void emitLoop() {
        std::vector<Event> batch, out;
        const int wait = windowMs_ > 0 ? windowMs_ : 10;
        for (;;) {
            queue_.wait(wait, stopFlag_);
            if (stopFlag_.load() && queue_.empty()) break;   // sai após drenar tudo
            batch.clear(); out.clear();
            queue_.drain(batch);
            if (batch.empty()) continue;
            detail::mergeBatch(batch, filter_, out);
            if (cb_ && !out.empty()) cb_(out);               // flush final também no stop()
        }
    }

    detail::EventQueue                   queue_;
    std::unique_ptr<detail::Backend>     backend_;
    std::thread                          reader_, emitter_;
    Callback                             cb_;
    std::function<bool(const fs::path&)> filter_;
    int                                  windowMs_ = 250;
    std::atomic<bool>                    stopFlag_{false};
    std::atomic<bool>                    running_{false};
    std::mutex                           mtx_;
};

} // namespace fw