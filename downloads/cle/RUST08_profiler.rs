/// RUST08 - Profiler de Performance
/// ===================================
/// Mede tempo de execução e contagem de chamadas.
/// Thread-safe. Suporta uso como bloco de medição
/// ou wrapper de função.

use std::collections::HashMap;
use std::sync::{Arc, Mutex};
use std::time::Instant;

#[derive(Debug, Clone)]
pub struct ProfileResult {
    pub name: String,
    pub total_elapsed_ms: f64,
    pub avg_elapsed_ms: f64,
    pub min_elapsed_ms: f64,
    pub max_elapsed_ms: f64,
    pub call_count: u64,
}

pub struct Profiler {
    results: Arc<Mutex<HashMap<String, ProfileData>>>,
}

struct ProfileData {
    total_ms: f64,
    min_ms: f64,
    max_ms: f64,
    count: u64,
}

/// Guard que mede o tempo até ser descartado (RAII).
pub struct ProfileGuard<'a> {
    name: String,
    start: Instant,
    profiler: &'a Profiler,
}

impl<'a> Drop for ProfileGuard<'a> {
    fn drop(&mut self) {
        let elapsed = self.start.elapsed().as_secs_f64() * 1000.0;
        self.profiler.record(&self.name, elapsed);
    }
}

impl Profiler {
    pub fn new() -> Self {
        Self {
            results: Arc::new(Mutex::new(HashMap::new())),
        }
    }

    /// Inicia uma medição. O tempo é registrado quando o guard é descartado.
    ///
    /// Use com blocos de escopo para medir automaticamente:
    /// ```
    /// let _guard = profiler.measure("minha_operacao");
    /// // ... código a medir ...
    /// // guard é descartado aqui, tempo registrado
    /// ```
    pub fn measure(&self, name: &str) -> ProfileGuard<'_> {
        ProfileGuard {
            name: name.to_string(),
            start: Instant::now(),
            profiler: self,
        }
    }

    /// Mede o tempo de execução de uma closure.
    pub fn track<T, F: FnOnce() -> T>(&self, name: &str, f: F) -> T {
        let _guard = self.measure(name);
        f()
    }

    fn record(&self, name: &str, elapsed_ms: f64) {
        let mut results = self.results.lock().unwrap();
        let entry = results.entry(name.to_string()).or_insert(ProfileData {
            total_ms: 0.0,
            min_ms: f64::MAX,
            max_ms: 0.0,
            count: 0,
        });
        entry.total_ms += elapsed_ms;
        entry.min_ms = entry.min_ms.min(elapsed_ms);
        entry.max_ms = entry.max_ms.max(elapsed_ms);
        entry.count += 1;
    }

    /// Gera relatório ordenado por tempo total.
    pub fn report(&self) -> Vec<ProfileResult> {
        let results = self.results.lock().unwrap();
        let mut report: Vec<ProfileResult> = results
            .iter()
            .map(|(name, data)| ProfileResult {
                name: name.clone(),
                total_elapsed_ms: data.total_ms,
                avg_elapsed_ms: data.total_ms / data.count as f64,
                min_elapsed_ms: data.min_ms,
                max_elapsed_ms: data.max_ms,
                call_count: data.count,
            })
            .collect();
        report.sort_by(|a, b| b.total_elapsed_ms.partial_cmp(&a.total_elapsed_ms).unwrap());
        report
    }

    /// Imprime relatório formatado.
    pub fn print_report(&self) {
        println!("\n{:=<80}", "");
        println!(
            "{:<25} {:>10} {:>10} {:>10} {:>10} {:>8}",
            "Nome", "Total(ms)", "Avg(ms)", "Min(ms)", "Max(ms)", "Calls"
        );
        println!("{:=<80}", "");
        for r in self.report() {
            println!(
                "{:<25} {:>10.2} {:>10.2} {:>10.2} {:>10.2} {:>8}",
                r.name, r.total_elapsed_ms, r.avg_elapsed_ms,
                r.min_elapsed_ms, r.max_elapsed_ms, r.call_count
            );
        }
        println!("{:=<80}\n", "");
    }

    /// Limpa todas as medições.
    pub fn reset(&self) {
        self.results.lock().unwrap().clear();
    }
}

// ===================== EXEMPLO DE USO =====================
//
// fn main() {
//     let profiler = Profiler::new();
//
//     // Com guard (RAII)
//     for _ in 0..10 {
//         let _guard = profiler.measure("ordenar_vetor");
//         let mut v: Vec<i32> = (0..100_000).rev().collect();
//         v.sort();
//     }
//
//     // Com closure
//     let resultado = profiler.track("calcular_soma", || {
//         (0..1_000_000i64).sum::<i64>()
//     });
//     println!("Soma: {}", resultado);
//
//     profiler.print_report();
//     // >>> ================================================================================
//     // >>> Nome                      Total(ms)    Avg(ms)    Min(ms)    Max(ms)    Calls
//     // >>> ================================================================================
//     // >>> ordenar_vetor                 85.23       8.52       7.91       9.34       10
//     // >>> calcular_soma                  1.45       1.45       1.45       1.45        1
//     // >>> ================================================================================
// }
