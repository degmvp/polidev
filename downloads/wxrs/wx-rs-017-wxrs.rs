// wx-rs-017-wxrs.rs
// ════════════════════════════════════════════════════════
// Título: Mapeamento paralelo de tarefas pesadas (rayon)
// Para que serve: Processa uma coleção em paralelo aproveitando todos os
// núcleos, útil para transformação de dados, hashing em massa e ETL pesado.
// Dependências (Cargo.toml): rayon = "1"
// ════════════════════════════════════════════════════════

use rayon::prelude::*;

/// Applies `f` to every item of `items` in parallel, preserving order.
pub fn parallel_map<T: Send + Sync, U: Send>(items: Vec<T>, f: impl Fn(&T) -> U + Sync) -> Vec<U> {
    items.par_iter().map(|item| f(item)).collect()
}

/// Checks whether `n` is prime (heavy per-item work, good for parallel demo).
fn is_prime(n: u64) -> bool {
    if n < 2 {
        return false;
    }
    if n % 2 == 0 {
        return n == 2;
    }
    let mut d = 3;
    while d * d <= n {
        if n % d == 0 {
            return false;
        }
        d += 2;
    }
    true
}

/// Counts primes up to `max` using parallel iteration.
pub fn count_primes_parallel(max: u64) -> usize {
    (2..=max).into_par_iter().filter(|n| is_prime(*n)).count()
}

// ── Exemplo de uso ──
fn main() {
    let nums: Vec<u64> = (1..=100_000).collect();

    // Mapeamento paralelo genérico: cada item vira o dobro.
    let doubled = parallel_map(nums.clone(), |n| n * 2);
    println!("primeiro item dobrado: {}", doubled[0]);

    // Trabalho pesado paralelo.
    let primes = count_primes_parallel(1_000_000);
    println!("primos até 1.000.000: {primes}");
}