// wx-rs-008-wxrs.rs
// ════════════════════════════════════════════════════════
// Título: Cache LRU thread-safe
// Para que serve: Cache com política LRU (Least Recently Used) e capacidade
// fixa, protegido por Mutex para uso concorrente. Útil para memoização e
// limites de memória.
// Dependências (Cargo.toml): nenhuma (apenas std)
// ════════════════════════════════════════════════════════

use std::collections::{HashMap, VecDeque};
use std::hash::Hash;
use std::sync::Mutex;

/// LRU cache core (single-threaded). Keys are tracked in a recency queue.
struct LruCache<K, V> {
    map: HashMap<K, V>,
    order: VecDeque<K>,
    capacity: usize,
}

impl<K: Eq + Hash + Clone, V> LruCache<K, V> {
    fn new(capacity: usize) -> Self {
        Self {
            map: HashMap::new(),
            order: VecDeque::new(),
            capacity: capacity.max(1),
        }
    }

    fn get(&mut self, key: &K) -> Option<&V> {
        if !self.map.contains_key(key) {
            return None;
        }
        // Move key to the back (most recently used).
        if let Some(pos) = self.order.iter().position(|k| k == key) {
            let k = self.order.remove(pos).unwrap();
            self.order.push_back(k);
        }
        self.map.get(key)
    }

    fn put(&mut self, key: K, value: V) {
        if self.map.contains_key(&key) {
            self.map.insert(key.clone(), value);
            if let Some(pos) = self.order.iter().position(|k| *k == key) {
                let k = self.order.remove(pos).unwrap();
                self.order.push_back(k);
            }
            return;
        }
        if self.map.len() >= self.capacity {
            if let Some(evicted) = self.order.pop_front() {
                self.map.remove(&evicted);
            }
        }
        self.map.insert(key.clone(), value);
        self.order.push_back(key);
    }
}

/// Thread-safe wrapper around `LruCache` via `Mutex`.
pub struct ThreadSafeLru<K, V> {
    inner: Mutex<LruCache<K, V>>,
}

impl<K: Eq + Hash + Clone, V: Clone> ThreadSafeLru<K, V> {
    pub fn new(capacity: usize) -> Self {
        Self {
            inner: Mutex::new(LruCache::new(capacity)),
        }
    }

    pub fn get(&self, key: &K) -> Option<V> {
        self.inner.lock().unwrap().get(key).cloned()
    }

    pub fn put(&self, key: K, value: V) {
        self.inner.lock().unwrap().put(key, value);
    }
}

// ── Exemplo de uso ──
fn main() {
    let cache = ThreadSafeLru::new(2);
    cache.put("a", 1);
    cache.put("b", 2);
    println!("get a -> {:?}", cache.get(&"a")); // Some(1), 'a' vira MRU
    cache.put("c", 3);                          // 'b' é removido (LRU)
    println!("get b -> {:?}", cache.get(&"b")); // None
    println!("get c -> {:?}", cache.get(&"c")); // Some(3)
}