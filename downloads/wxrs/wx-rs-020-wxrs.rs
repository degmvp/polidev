// wx-rs-020-wxrs.rs
// ════════════════════════════════════════════════════════
// Título: Executor de tarefas com retry/backoff genérico
// Para que serve: Reutilizável e genérico: executa qualquer closure assíncrona
// com retry, backoff exponencial e critério customizado de "deve repetir".
// Dependências (Cargo.toml): tokio = { version = "1", features = ["time", "macros", "rt-multi-thread"] }
// ════════════════════════════════════════════════════════

use std::future::Future;
use std::sync::atomic::{AtomicU32, Ordering};
use std::sync::Arc;
use std::time::Duration;
use tokio::time::sleep;

/// Runs `f` up to `max_attempts` times, retrying when `should_retry` returns
/// true for the error, with exponential backoff starting at `base_delay_ms`.
pub async fn retry_with_backoff<F, Fut, T, E>(
    mut f: F,
    should_retry: impl Fn(&E) -> bool,
    max_attempts: u32,
    base_delay_ms: u64,
) -> Result<T, E>
where
    F: FnMut() -> Fut,
    Fut: Future<Output = Result<T, E>>,
{
    let mut attempt = 0u32;
    loop {
        attempt += 1;
        match f().await {
            Ok(value) => return Ok(value),
            Err(err) => {
                if attempt >= max_attempts || !should_retry(&err) {
                    return Err(err);
                }
                let delay = base_delay_ms * 2u64.saturating_pow(attempt - 1);
                sleep(Duration::from_millis(delay)).await;
            }
        }
    }
}

// ── Exemplo de uso ──
#[derive(Debug)]
enum MyError {
    Transient(String),
    Fatal(String),
}

#[tokio::main]
async fn main() {
    let calls = Arc::new(AtomicU32::new(0));

    let resultado = retry_with_backoff(
        {
            let calls = Arc::clone(&calls);
            move || {
                let calls = Arc::clone(&calls);
                async move {
                    let n = calls.fetch_add(1, Ordering::SeqCst) + 1;
                    if n < 3 {
                        Err(MyError::Transient(format!("temporário #{n}")))
                    } else {
                        Ok::<_, MyError>(format!("sucesso na tentativa {n}"))
                    }
                }
            }
        },
        |e: &MyError| matches!(e, MyError::Transient(_)),
        5,
        100,
    )
    .await;

    println!("resultado: {resultado:?} (chamadas = {})", calls.load(Ordering::SeqCst));

    // Erro "fatal" não é repetido: retorna imediatamente.
    let fatal = retry_with_backoff(
        || async { Err::<(), _>(MyError::Fatal("não repetir".into())) },
        |e: &MyError| matches!(e, MyError::Transient(_)),
        5,
        100,
    )
    .await;
    println!("erro fatal retornado na hora: {fatal:?}");
}