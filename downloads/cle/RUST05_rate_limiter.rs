/// RUST05 - Rate Limiter (Token Bucket)
/// =======================================
/// Controla a frequência de operações usando o algoritmo
/// Token Bucket. Thread-safe com Mutex.

use std::sync::Mutex;
use std::time::{Duration, Instant};

pub struct RateLimiter {
    inner: Mutex<RateLimiterInner>,
}

struct RateLimiterInner {
    rate: f64,
    burst: f64,
    tokens: f64,
    last_refill: Instant,
    total_allowed: u64,
    total_rejected: u64,
}

impl RateLimiter {
    /// Cria um novo rate limiter.
    ///
    /// # Argumentos
    /// * `rate` - Operações permitidas por segundo.
    /// * `burst` - Capacidade máxima do bucket (rajadas).
    pub fn new(rate: f64, burst: u32) -> Self {
        Self {
            inner: Mutex::new(RateLimiterInner {
                rate,
                burst: burst as f64,
                tokens: burst as f64,
                last_refill: Instant::now(),
                total_allowed: 0,
                total_rejected: 0,
            }),
        }
    }

    fn refill(inner: &mut RateLimiterInner) {
        let now = Instant::now();
        let elapsed = now.duration_since(inner.last_refill).as_secs_f64();
        inner.tokens = (inner.tokens + elapsed * inner.rate).min(inner.burst);
        inner.last_refill = now;
    }

    /// Tenta adquirir permissão sem bloquear.
    /// Retorna `true` se permitido, `false` se rejeitado.
    pub fn try_acquire(&self) -> bool {
        let mut inner = self.inner.lock().unwrap();
        Self::refill(&mut inner);
        if inner.tokens >= 1.0 {
            inner.tokens -= 1.0;
            inner.total_allowed += 1;
            true
        } else {
            inner.total_rejected += 1;
            false
        }
    }

    /// Bloqueia até obter permissão.
    pub fn acquire(&self) {
        loop {
            if self.try_acquire() {
                return;
            }
            let wait = {
                let inner = self.inner.lock().unwrap();
                Duration::from_secs_f64((1.0 - inner.tokens) / inner.rate)
            };
            std::thread::sleep(wait);
        }
    }

    /// Bloqueia até obter permissão ou timeout.
    pub fn acquire_timeout(&self, timeout: Duration) -> bool {
        let deadline = Instant::now() + timeout;
        loop {
            if self.try_acquire() {
                return true;
            }
            if Instant::now() >= deadline {
                return false;
            }
            let wait = {
                let inner = self.inner.lock().unwrap();
                let needed = Duration::from_secs_f64((1.0 - inner.tokens) / inner.rate);
                needed.min(deadline - Instant::now())
            };
            std::thread::sleep(wait);
        }
    }

    /// Estatísticas do rate limiter.
    pub fn stats(&self) -> (u64, u64, f64) {
        let inner = self.inner.lock().unwrap();
        (inner.total_allowed, inner.total_rejected, inner.tokens)
    }
}

// ===================== EXEMPLO DE USO =====================
//
// fn main() {
//     let limiter = RateLimiter::new(5.0, 10); // 5 ops/s, burst 10
//
//     for i in 0..20 {
//         if limiter.try_acquire() {
//             println!("Requisição {} permitida", i);
//         } else {
//             println!("Requisição {} rejeitada (rate limit)", i);
//         }
//     }
//
//     let (allowed, rejected, tokens) = limiter.stats();
//     println!("Permitidas: {}, Rejeitadas: {}, Tokens: {:.1}", allowed, rejected, tokens);
// }
