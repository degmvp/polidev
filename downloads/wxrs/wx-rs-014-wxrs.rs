// wx-rs-014-wxrs.rs
// ════════════════════════════════════════════════════════
// Título: Rate limiter token bucket
// Para que serve: Limita a taxa de operações por segundo (token bucket) com
// rajada máxima, protegendo APIs externas e recursos compartilhados.
// Dependências (Cargo.toml): tokio = { version = "1", features = ["time", "macros", "rt-multi-thread"] }
// ════════════════════════════════════════════════════════

use std::sync::Mutex;
use std::time::{Duration, Instant};
use tokio::time::sleep;

struct BucketState {
    tokens: f64,
    last_refill: Instant,
}

/// Token bucket rate limiter (thread-safe via `Mutex`).
pub struct TokenBucket {
    capacity: f64,     // burst máximo
    refill_rate: f64,  // tokens por segundo
    state: Mutex<BucketState>,
}

impl TokenBucket {
    pub fn new(capacity: f64, tokens_per_second: f64) -> Self {
        Self {
            capacity,
            refill_rate: tokens_per_second,
            state: Mutex::new(BucketState {
                tokens: capacity,
                last_refill: Instant::now(),
            }),
        }
    }

    fn refill(&self, st: &mut BucketState) {
        let elapsed = st.last_refill.elapsed().as_secs_f64();
        st.last_refill = Instant::now();
        st.tokens = (st.tokens + elapsed * self.refill_rate).min(self.capacity);
    }

    /// Attempts to consume `n` tokens without blocking.
    pub fn try_take(&self, n: f64) -> bool {
        let mut st = self.state.lock().unwrap();
        self.refill(&mut st);
        if st.tokens >= n {
            st.tokens -= n;
            true
        } else {
            false
        }
    }

    /// Blocks (asynchronously) until `n` tokens are available.
    pub async fn take(&self, n: f64) {
        loop {
            let delay_ms = {
                let mut st = self.state.lock().unwrap();
                self.refill(&mut st);
                if st.tokens >= n {
                    st.tokens -= n;
                    return;
                }
                // ms until enough tokens accumulate
                let missing = n - st.tokens;
                ((missing / self.refill_rate) * 1000.0).ceil() as u64
            };
            sleep(Duration::from_millis(delay_ms)).await;
        }
    }
}

// ── Exemplo de uso ──
#[tokio::main]
async fn main() {
    let limiter = std::sync::Arc::new(TokenBucket::new(5.0, 2.0)); // burst 5, 2/s

    for i in 0..8 {
        limiter.take(1.0).await;
        println!("requisição {i} liberada");
    }
    println!("try_take após burst gasto: {}", limiter.try_take(1.0)); // false
}