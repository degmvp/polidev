/// RUST02 - Cache LRU com TTL (Time-To-Live)
/// =============================================
/// Cache em memória thread-safe com limite de tamanho
/// e expiração automática por tempo.

use std::collections::HashMap;
use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};

#[derive(Clone)]
struct CacheEntry<V> {
    value: V,
    inserted_at: Instant,
}

pub struct TtlCache<K, V> {
    store: Arc<Mutex<HashMap<K, CacheEntry<V>>>>,
    max_size: usize,
    ttl: Duration,
    hits: Arc<Mutex<u64>>,
    misses: Arc<Mutex<u64>>,
}

impl<K, V> TtlCache<K, V>
where
    K: std::hash::Hash + Eq + Clone,
    V: Clone,
{
    /// Cria um novo cache com tamanho máximo e TTL.
    pub fn new(max_size: usize, ttl_seconds: u64) -> Self {
        Self {
            store: Arc::new(Mutex::new(HashMap::new())),
            max_size,
            ttl: Duration::from_secs(ttl_seconds),
            hits: Arc::new(Mutex::new(0)),
            misses: Arc::new(Mutex::new(0)),
        }
    }

    /// Insere um valor no cache.
    pub fn put(&self, key: K, value: V) {
        let mut store = self.store.lock().unwrap();
        if store.len() >= self.max_size && !store.contains_key(&key) {
            // Remove a entrada mais antiga
            if let Some(oldest_key) = store
                .iter()
                .min_by_key(|(_, entry)| entry.inserted_at)
                .map(|(k, _)| k.clone())
            {
                store.remove(&oldest_key);
            }
        }
        store.insert(
            key,
            CacheEntry {
                value,
                inserted_at: Instant::now(),
            },
        );
    }

    /// Busca um valor no cache. Retorna None se ausente ou expirado.
    pub fn get(&self, key: &K) -> Option<V> {
        let mut store = self.store.lock().unwrap();
        if let Some(entry) = store.get(key) {
            if entry.inserted_at.elapsed() < self.ttl {
                *self.hits.lock().unwrap() += 1;
                return Some(entry.value.clone());
            } else {
                store.remove(key);
            }
        }
        *self.misses.lock().unwrap() += 1;
        None
    }

    /// Remove uma entrada específica.
    pub fn invalidate(&self, key: &K) {
        self.store.lock().unwrap().remove(key);
    }

    /// Limpa todo o cache.
    pub fn clear(&self) {
        self.store.lock().unwrap().clear();
    }

    /// Remove todas as entradas expiradas.
    pub fn evict_expired(&self) -> usize {
        let mut store = self.store.lock().unwrap();
        let before = store.len();
        store.retain(|_, entry| entry.inserted_at.elapsed() < self.ttl);
        before - store.len()
    }

    /// Retorna taxa de acerto do cache.
    pub fn hit_rate(&self) -> f64 {
        let hits = *self.hits.lock().unwrap();
        let misses = *self.misses.lock().unwrap();
        let total = hits + misses;
        if total == 0 { 0.0 } else { hits as f64 / total as f64 }
    }

    /// Tamanho atual do cache.
    pub fn len(&self) -> usize {
        self.store.lock().unwrap().len()
    }
}

// ===================== EXEMPLO DE USO =====================
//
// fn main() {
//     let cache = TtlCache::new(100, 60); // max 100 entradas, TTL 60s
//
//     cache.put("user:42", "Maria Silva");
//     cache.put("user:99", "João Santos");
//
//     match cache.get(&"user:42") {
//         Some(nome) => println!("Cache hit: {}", nome),
//         None => println!("Cache miss"),
//     }
//
//     println!("Hit rate: {:.1}%", cache.hit_rate() * 100.0);
//     println!("Tamanho: {}", cache.len());
// }
