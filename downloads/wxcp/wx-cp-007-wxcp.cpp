// ════════════════════════════════════════════════════════════════════════════
// wx-cp-007-wxcp.cpp — Estrutura de Dados: LRU Cache
// ────────────────────────────────────────────────────────────────────────────
// DESCRIÇÃO (para que serve):
//   Cache Least-Recently-Used genérico com acesso O(1): combina hash map
//   (índice) com lista duplamente encadeada (ordem de uso). Essencial em
//   sistemas com memória limitada: banco de dados, cache de consultas,
//   sessões, thumbnails.
//
// EXEMPLO:
//   capacidade 2:
//     put(1,A) put(2,B) get(1)=A put(3,C) -> evita 2
//     get(2) -> nullopt (ausente) | get(1) -> A
// ════════════════════════════════════════════════════════════════════════════

#include <unordered_map>
#include <list>
#include <optional>
#include <iostream>

template <typename Key, typename Value>
class LRUCache {
    using ListIt = typename std::list<std::pair<Key, Value>>::iterator;
    std::size_t capacity_;
    std::list<std::pair<Key, Value>> items_;
    std::unordered_map<Key, ListIt> index_;
public:
    explicit LRUCache(std::size_t capacity) : capacity_(capacity) {}

    std::optional<Value> get(const Key& key) {
        auto it = index_.find(key);
        if (it == index_.end()) return std::nullopt;
        items_.splice(items_.begin(), items_, it->second);   // marca como recente
        return it->second->second;
    }

    void put(const Key& key, const Value& value) {
        auto it = index_.find(key);
        if (it != index_.end()) {
            it->second->second = value;
            items_.splice(items_.begin(), items_, it->second);
            return;
        }
        if (items_.size() == capacity_) {                    // evita o mais antigo
            index_.erase(items_.back().first);
            items_.pop_back();
        }
        items_.emplace_front(key, value);
        index_[key] = items_.begin();
    }
};

int main() {
    LRUCache<int, std::string> cache(2);
    cache.put(1, "A"); cache.put(2, "B");
    std::cout << cache.get(1).value_or("ausente") << '\n';   // A
    cache.put(3, "C");                                       // evita a chave 2
    std::cout << cache.get(2).has_value() << '\n';           // 0
    std::cout << cache.get(1).value_or("ausente") << '\n';   // A
}