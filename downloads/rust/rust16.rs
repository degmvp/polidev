use std::time::{SystemTime, UNIX_EPOCH};

/// Retorna segundos desde 01/01/1970
pub fn timestamp_atual() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs()
}

fn main() {
    let ts = timestamp_atual();

    println!("Timestamp atual: {}", ts);
}