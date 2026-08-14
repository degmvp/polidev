/// RUST06 - Event Emitter (Sistema de Eventos)
/// ===============================================
/// Sistema pub/sub thread-safe para desacoplamento
/// de componentes. Suporta múltiplos listeners por evento.

use std::collections::HashMap;
use std::sync::{Arc, Mutex};

type Handler<T> = Box<dyn Fn(&T) + Send + Sync>;

pub struct EventEmitter<T: 'static> {
    listeners: Arc<Mutex<HashMap<String, Vec<HandlerEntry<T>>>>>,
    event_count: Arc<Mutex<HashMap<String, u64>>>,
}

struct HandlerEntry<T: 'static> {
    id: u64,
    handler: Handler<T>,
    once: bool,
    priority: i32,
}

impl<T: 'static> EventEmitter<T> {
    pub fn new() -> Self {
        Self {
            listeners: Arc::new(Mutex::new(HashMap::new())),
            event_count: Arc::new(Mutex::new(HashMap::new())),
        }
    }

    /// Registra um listener para um evento.
    /// Retorna o ID do listener para remoção posterior.
    pub fn on<F>(&self, event: &str, handler: F) -> u64
    where
        F: Fn(&T) + Send + Sync + 'static,
    {
        self.on_with_priority(event, handler, 0, false)
    }

    /// Registra um listener que executa apenas uma vez.
    pub fn once<F>(&self, event: &str, handler: F) -> u64
    where
        F: Fn(&T) + Send + Sync + 'static,
    {
        self.on_with_priority(event, handler, 0, true)
    }

    /// Registra um listener com prioridade.
    pub fn on_with_priority<F>(
        &self, event: &str, handler: F, priority: i32, once: bool,
    ) -> u64
    where
        F: Fn(&T) + Send + Sync + 'static,
    {
        let mut listeners = self.listeners.lock().unwrap();
        let entries = listeners.entry(event.to_string()).or_insert_with(Vec::new);

        let id = entries.len() as u64 + 1;
        entries.push(HandlerEntry {
            id,
            handler: Box::new(handler),
            once,
            priority,
        });
        entries.sort_by(|a, b| b.priority.cmp(&a.priority));
        id
    }

    /// Remove um listener pelo ID.
    pub fn off(&self, event: &str, handler_id: u64) {
        let mut listeners = self.listeners.lock().unwrap();
        if let Some(entries) = listeners.get_mut(event) {
            entries.retain(|e| e.id != handler_id);
        }
    }

    /// Remove todos os listeners de um evento.
    pub fn off_all(&self, event: &str) {
        self.listeners.lock().unwrap().remove(event);
    }

    /// Emite um evento, chamando todos os listeners registrados.
    /// Retorna o número de listeners executados.
    pub fn emit(&self, event: &str, data: &T) -> usize {
        // Atualizar contagem
        {
            let mut counts = self.event_count.lock().unwrap();
            *counts.entry(event.to_string()).or_insert(0) += 1;
        }

        let mut to_remove: Vec<u64> = Vec::new();
        let mut executed = 0;

        {
            let listeners = self.listeners.lock().unwrap();
            if let Some(entries) = listeners.get(event) {
                for entry in entries {
                    (entry.handler)(data);
                    executed += 1;
                    if entry.once {
                        to_remove.push(entry.id);
                    }
                }
            }
        }

        // Remover one-shot listeners
        if !to_remove.is_empty() {
            let mut listeners = self.listeners.lock().unwrap();
            if let Some(entries) = listeners.get_mut(event) {
                entries.retain(|e| !to_remove.contains(&e.id));
            }
        }

        executed
    }

    /// Número de listeners para um evento.
    pub fn listener_count(&self, event: &str) -> usize {
        self.listeners
            .lock()
            .unwrap()
            .get(event)
            .map_or(0, |e| e.len())
    }

    /// Contagem total de emissões por evento.
    pub fn emission_counts(&self) -> HashMap<String, u64> {
        self.event_count.lock().unwrap().clone()
    }
}

// ===================== EXEMPLO DE USO =====================
//
// fn main() {
//     let emitter = EventEmitter::<String>::new();
//
//     emitter.on("usuario:criado", |nome| {
//         println!("Email enviado para: {}", nome);
//     });
//
//     emitter.on("usuario:criado", |nome| {
//         println!("Analytics: novo usuário {}", nome);
//     });
//
//     emitter.once("usuario:criado", |nome| {
//         println!("Primeiro usuário registrado: {}", nome);
//     });
//
//     let count = emitter.emit("usuario:criado", &"Maria".to_string());
//     println!("Listeners executados: {}", count);
//     // >>> Email enviado para: Maria
//     // >>> Analytics: novo usuário Maria
//     // >>> Primeiro usuário registrado: Maria
//     // >>> Listeners executados: 3
//
//     // Segunda emissão: o "once" já foi removido
//     let count = emitter.emit("usuario:criado", &"João".to_string());
//     println!("Listeners executados: {}", count); // >>> 2
// }
