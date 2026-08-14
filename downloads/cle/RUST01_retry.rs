/// RUST01 - Retry com Backoff Exponencial
/// ========================================
/// Reexecuta uma função automaticamente em caso de falha,
/// com intervalo crescente entre tentativas.
/// Ideal para chamadas a APIs externas e operações de rede.

use std::thread;
use std::time::Duration;
use std::fmt;

#[derive(Debug)]
pub struct RetryError {
    pub attempts: u32,
    pub last_error: String,
}

impl fmt::Display for RetryError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "Falhou após {} tentativas. Último erro: {}",
            self.attempts, self.last_error
        )
    }
}

pub struct RetryConfig {
    pub max_attempts: u32,
    pub initial_delay_ms: u64,
    pub backoff_factor: f64,
}

impl Default for RetryConfig {
    fn default() -> Self {
        Self {
            max_attempts: 3,
            initial_delay_ms: 1000,
            backoff_factor: 2.0,
        }
    }
}

/// Executa `operation` com retry e backoff exponencial.
///
/// # Argumentos
/// * `config` - Configuração de retry (tentativas, delay, fator).
/// * `operation` - Closure que retorna `Result<T, E>`.
///
/// # Retorno
/// `Ok(T)` se bem-sucedido, `Err(RetryError)` se todas as tentativas falharem.
pub fn retry_with_backoff<T, E, F>(config: &RetryConfig, mut operation: F) -> Result<T, RetryError>
where
    E: fmt::Display,
    F: FnMut() -> Result<T, E>,
{
    let mut delay = config.initial_delay_ms;
    let mut last_error = String::new();

    for attempt in 1..=config.max_attempts {
        match operation() {
            Ok(value) => return Ok(value),
            Err(e) => {
                last_error = e.to_string();
                eprintln!(
                    "[retry] Tentativa {}/{} falhou: {}",
                    attempt, config.max_attempts, last_error
                );
                if attempt < config.max_attempts {
                    thread::sleep(Duration::from_millis(delay));
                    delay = (delay as f64 * config.backoff_factor) as u64;
                }
            }
        }
    }

    Err(RetryError {
        attempts: config.max_attempts,
        last_error,
    })
}

// ===================== EXEMPLO DE USO =====================
//
// fn main() {
//     let config = RetryConfig {
//         max_attempts: 5,
//         initial_delay_ms: 500,
//         backoff_factor: 2.0,
//     };
//
//     let mut counter = 0;
//     let result = retry_with_backoff(&config, || {
//         counter += 1;
//         if counter < 3 {
//             Err("Servidor indisponível")
//         } else {
//             Ok("Dados recebidos com sucesso!")
//         }
//     });
//
//     match result {
//         Ok(data) => println!("Sucesso: {}", data),
//         Err(e) => println!("Erro: {}", e),
//     }
// }
