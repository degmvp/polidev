/// RUST10 - Thread Pool com Canal de Tarefas
/// =============================================
/// Pool de threads reutilizáveis para execução paralela
/// de tarefas. Implementação pura, sem dependências externas.
/// Ideal para processamento em background e paralelismo.

use std::sync::{mpsc, Arc, Mutex};
use std::thread;
use std::fmt;

type Job = Box<dyn FnOnce() + Send + 'static>;

#[derive(Debug)]
pub struct ThreadPoolError {
    pub message: String,
}

impl fmt::Display for ThreadPoolError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "ThreadPoolError: {}", self.message)
    }
}

pub struct ThreadPool {
    workers: Vec<Worker>,
    sender: Option<mpsc::Sender<Job>>,
    size: usize,
}

struct Worker {
    id: usize,
    thread: Option<thread::JoinHandle<()>>,
}

impl Worker {
    fn new(id: usize, receiver: Arc<Mutex<mpsc::Receiver<Job>>>) -> Self {
        let thread = thread::spawn(move || loop {
            let job = receiver.lock().unwrap().recv();
            match job {
                Ok(job) => {
                    eprintln!("[pool] Worker {} executando tarefa", id);
                    job();
                }
                Err(_) => {
                    eprintln!("[pool] Worker {} encerrando", id);
                    break;
                }
            }
        });

        Worker {
            id,
            thread: Some(thread),
        }
    }
}

impl ThreadPool {
    /// Cria um novo pool de threads.
    ///
    /// # Argumentos
    /// * `size` - Número de threads no pool (deve ser > 0).
    ///
    /// # Erros
    /// Retorna erro se `size` for 0.
    pub fn new(size: usize) -> Result<Self, ThreadPoolError> {
        if size == 0 {
            return Err(ThreadPoolError {
                message: "Pool deve ter pelo menos 1 thread".to_string(),
            });
        }

        let (sender, receiver) = mpsc::channel();
        let receiver = Arc::new(Mutex::new(receiver));

        let mut workers = Vec::with_capacity(size);
        for id in 0..size {
            workers.push(Worker::new(id, Arc::clone(&receiver)));
        }

        Ok(ThreadPool {
            workers,
            sender: Some(sender),
            size,
        })
    }

    /// Envia uma tarefa para execução no pool.
    ///
    /// # Argumentos
    /// * `f` - Closure a ser executada por um worker.
    pub fn execute<F>(&self, f: F) -> Result<(), ThreadPoolError>
    where
        F: FnOnce() + Send + 'static,
    {
        self.sender
            .as_ref()
            .ok_or_else(|| ThreadPoolError {
                message: "Pool já foi encerrado".to_string(),
            })?
            .send(Box::new(f))
            .map_err(|_| ThreadPoolError {
                message: "Falha ao enviar tarefa".to_string(),
            })
    }

    /// Retorna o número de workers no pool.
    pub fn size(&self) -> usize {
        self.size
    }
}

impl Drop for ThreadPool {
    fn drop(&mut self) {
        // Fechar o canal para sinalizar aos workers
        drop(self.sender.take());

        for worker in &mut self.workers {
            if let Some(thread) = worker.thread.take() {
                thread.join().unwrap();
            }
        }
    }
}

/// Pool com resultados coletáveis via canal.
pub struct ResultPool<T: Send + 'static> {
    pool: ThreadPool,
    result_sender: mpsc::Sender<T>,
    result_receiver: mpsc::Receiver<T>,
}

impl<T: Send + 'static> ResultPool<T> {
    pub fn new(size: usize) -> Result<Self, ThreadPoolError> {
        let pool = ThreadPool::new(size)?;
        let (tx, rx) = mpsc::channel();
        Ok(Self {
            pool,
            result_sender: tx,
            result_receiver: rx,
        })
    }

    /// Envia uma tarefa que produz um resultado coletável.
    pub fn execute<F>(&self, f: F) -> Result<(), ThreadPoolError>
    where
        F: FnOnce() -> T + Send + 'static,
    {
        let sender = self.result_sender.clone();
        self.pool.execute(move || {
            let result = f();
            let _ = sender.send(result);
        })
    }

    /// Coleta todos os resultados disponíveis (não bloqueia).
    pub fn collect(&self) -> Vec<T> {
        let mut results = Vec::new();
        while let Ok(result) = self.result_receiver.try_recv() {
            results.push(result);
        }
        results
    }

    /// Aguarda e coleta exatamente `n` resultados.
    pub fn collect_n(&self, n: usize) -> Vec<T> {
        let mut results = Vec::with_capacity(n);
        for _ in 0..n {
            if let Ok(result) = self.result_receiver.recv() {
                results.push(result);
            }
        }
        results
    }
}

// ===================== EXEMPLO DE USO =====================
//
// fn main() {
//     // Pool básico
//     let pool = ThreadPool::new(4).unwrap();
//
//     for i in 0..8 {
//         pool.execute(move || {
//             println!("Tarefa {} executando na thread {:?}", i, thread::current().id());
//             thread::sleep(std::time::Duration::from_millis(100));
//         }).unwrap();
//     }
//
//     // Pool com resultados
//     let result_pool: ResultPool<i64> = ResultPool::new(4).unwrap();
//
//     for i in 0..10 {
//         result_pool.execute(move || {
//             // Simular trabalho pesado
//             (0..100_000i64).sum::<i64>() + i
//         }).unwrap();
//     }
//
//     let resultados = result_pool.collect_n(10);
//     println!("Resultados: {:?}", resultados);
//     // >>> Resultados: [4999950000, 4999950001, 4999950002, ...]
// }
