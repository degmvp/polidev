/// RUST07 - Circuit Breaker (Disjuntor de Circuito)
/// ====================================================
/// Proteção contra falhas em cascata. Quando um serviço
/// falha repetidamente, o circuito "abre" e rejeita
/// chamadas, dando tempo para recuperação.

use std::sync::Mutex;
use std::time::{Duration, Instant};
use std::fmt;

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum CircuitState {
    Closed,
    Open,
    HalfOpen,
}

impl fmt::Display for CircuitState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            CircuitState::Closed => write!(f, "closed"),
            CircuitState::Open => write!(f, "open"),
            CircuitState::HalfOpen => write!(f, "half_open"),
        }
    }
}

#[derive(Debug)]
pub struct CircuitBreakerError {
    pub state: CircuitState,
    pub message: String,
}

impl fmt::Display for CircuitBreakerError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "CircuitBreaker [{}]: {}", self.state, self.message)
    }
}

pub struct CircuitBreaker {
    inner: Mutex<CircuitBreakerInner>,
}

struct CircuitBreakerInner {
    state: CircuitState,
    failure_threshold: u32,
    success_threshold: u32,
    recovery_timeout: Duration,
    failure_count: u32,
    success_count: u32,
    last_failure: Option<Instant>,
    total_calls: u64,
    total_failures: u64,
    total_rejected: u64,
}

impl CircuitBreaker {
    /// Cria um novo circuit breaker.
    ///
    /// # Argumentos
    /// * `failure_threshold` - Falhas consecutivas para abrir o circuito.
    /// * `recovery_timeout_secs` - Segundos antes de testar recuperação.
    /// * `success_threshold` - Sucessos necessários em half-open para fechar.
    pub fn new(failure_threshold: u32, recovery_timeout_secs: u64, success_threshold: u32) -> Self {
        Self {
            inner: Mutex::new(CircuitBreakerInner {
                state: CircuitState::Closed,
                failure_threshold,
                success_threshold,
                recovery_timeout: Duration::from_secs(recovery_timeout_secs),
                failure_count: 0,
                success_count: 0,
                last_failure: None,
                total_calls: 0,
                total_failures: 0,
                total_rejected: 0,
            }),
        }
    }

    /// Executa uma operação protegida pelo circuit breaker.
    pub fn call<T, E, F>(&self, operation: F) -> Result<T, CircuitBreakerError>
    where
        E: fmt::Display,
        F: FnOnce() -> Result<T, E>,
    {
        // Verificar estado
        {
            let mut inner = self.inner.lock().unwrap();

            if inner.state == CircuitState::Open {
                if let Some(last) = inner.last_failure {
                    if last.elapsed() >= inner.recovery_timeout {
                        inner.state = CircuitState::HalfOpen;
                        inner.success_count = 0;
                    } else {
                        inner.total_rejected += 1;
                        return Err(CircuitBreakerError {
                            state: CircuitState::Open,
                            message: format!(
                                "Circuito aberto. Aguarde {:.0}s.",
                                (inner.recovery_timeout - last.elapsed()).as_secs_f64()
                            ),
                        });
                    }
                }
            }
        }

        // Executar operação
        match operation() {
            Ok(value) => {
                let mut inner = self.inner.lock().unwrap();
                inner.total_calls += 1;
                if inner.state == CircuitState::HalfOpen {
                    inner.success_count += 1;
                    if inner.success_count >= inner.success_threshold {
                        inner.state = CircuitState::Closed;
                        inner.failure_count = 0;
                    }
                } else {
                    inner.failure_count = 0;
                }
                Ok(value)
            }
            Err(e) => {
                let mut inner = self.inner.lock().unwrap();
                inner.total_calls += 1;
                inner.total_failures += 1;
                inner.failure_count += 1;
                inner.last_failure = Some(Instant::now());

                if inner.state == CircuitState::HalfOpen {
                    inner.state = CircuitState::Open;
                } else if inner.failure_count >= inner.failure_threshold {
                    inner.state = CircuitState::Open;
                }

                Err(CircuitBreakerError {
                    state: inner.state,
                    message: e.to_string(),
                })
            }
        }
    }

    /// Estado atual do circuito.
    pub fn state(&self) -> CircuitState {
        self.inner.lock().unwrap().state
    }

    /// Reseta para o estado fechado.
    pub fn reset(&self) {
        let mut inner = self.inner.lock().unwrap();
        inner.state = CircuitState::Closed;
        inner.failure_count = 0;
        inner.success_count = 0;
    }

    /// Estatísticas.
    pub fn stats(&self) -> (CircuitState, u64, u64, u64) {
        let inner = self.inner.lock().unwrap();
        (inner.state, inner.total_calls, inner.total_failures, inner.total_rejected)
    }
}

// ===================== EXEMPLO DE USO =====================
//
// fn main() {
//     let cb = CircuitBreaker::new(3, 10, 2);
//
//     // Simular falhas
//     for i in 0..5 {
//         let result = cb.call(|| -> Result<&str, &str> {
//             Err("Servidor offline")
//         });
//         match result {
//             Ok(v) => println!("Sucesso: {}", v),
//             Err(e) => println!("Tentativa {}: {}", i, e),
//         }
//     }
//
//     println!("Estado: {}", cb.state());
//     let (state, calls, failures, rejected) = cb.stats();
//     println!("Calls: {}, Failures: {}, Rejected: {}", calls, failures, rejected);
// }
