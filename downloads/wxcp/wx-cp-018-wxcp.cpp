// ════════════════════════════════════════════════════════════════════════════
// wx-cp-018-wxcp.cpp — Pool de Threads Genérico
// ────────────────────────────────────────────────────────────────────────────
// DESCRIÇÃO (para que serve):
//   Reutiliza um número fixo de threads para executar tarefas enviadas via
//   fila, com suporte a retorno de valores por std::future. Evita o custo de
//   criar threads por tarefa. Base para servidores, processamento paralelo e
//   E/S concorrente.
//
// EXEMPLO:
//   envia 8 tarefas de soma -> Soma: 36
// ════════════════════════════════════════════════════════════════════════════

#include <thread>
#include <vector>
#include <queue>
#include <functional>
#include <future>
#include <mutex>
#include <condition_variable>
#include <memory>
#include <iostream>

class ThreadPool {
public:
    explicit ThreadPool(size_t threads) {
        for (size_t i = 0; i < threads; ++i)
            workers_.emplace_back([this] { workerLoop(); });
    }
    ~ThreadPool() {
        { std::lock_guard<std::mutex> lk(mu_); stop_ = true; }
        cv_.notify_all();
        for (auto& w : workers_) w.join();
    }
    ThreadPool(const ThreadPool&) = delete;
    ThreadPool& operator=(const ThreadPool&) = delete;

    template <typename F>
    auto enqueue(F&& f) -> std::future<decltype(f())> {
        using R = decltype(f());
        auto task = std::make_shared<std::packaged_task<R()>>(std::forward<F>(f));
        std::future<R> result = task->get_future();
        {
            std::lock_guard<std::mutex> lk(mu_);
            tasks_.emplace([task] { (*task)(); });
        }
        cv_.notify_one();
        return result;
    }

private:
    void workerLoop() {
        for (;;) {
            std::function<void()> task;
            {
                std::unique_lock<std::mutex> lk(mu_);
                cv_.wait(lk, [this] { return stop_ || !tasks_.empty(); });
                if (stop_ && tasks_.empty()) return;
                task = std::move(tasks_.front());
                tasks_.pop();
            }
            task();
        }
    }
    std::vector<std::thread> workers_;
    std::queue<std::function<void()>> tasks_;
    std::mutex mu_;
    std::condition_variable cv_;
    bool stop_ = false;
};

int main() {
    ThreadPool pool(4);
    std::vector<std::future<int>> results;
    for (int i = 1; i <= 8; ++i)
        results.push_back(pool.enqueue([i] { return i; }));
    int sum = 0;
    for (auto& f : results) sum += f.get();
    std::cout << "Soma: " << sum << '\n';   // Soma: 36
}