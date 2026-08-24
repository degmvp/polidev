// wx-rs-005-wxrs.rs
// ════════════════════════════════════════════════════════
// Título: Gerador de tokens/IDs criptograficamente seguros
// Para que serve: Gera tokens aleatórios (hex ou alfanumérico) para tokens de
// sessão, chaves de API e IDs não sequenciais, usando CSPRNG do rand.
// Dependências (Cargo.toml): rand = "0.8"
// ════════════════════════════════════════════════════════

use rand::distributions::{Alphanumeric, DistString};
use rand::{thread_rng, Rng};

/// Generates a random hex token with `bytes` bytes of entropy (2x chars).
pub fn random_hex(bytes: usize) -> String {
    let mut rng = thread_rng();
    let raw: Vec<u8> = (0..bytes).map(|_| rng.gen()).collect();
    raw.iter().map(|b| format!("{b:02x}")).collect()
}

/// Generates an URL-safe alphanumeric token of `len` characters.
pub fn random_token(len: usize) -> String {
    Alphanumeric.sample_string(&mut thread_rng(), len)
}

/// Generates a proper UUID v4 from secure randomness.
pub fn random_uuid() -> String {
    let mut rng = thread_rng();
    let mut b: [u8; 16] = rng.gen();
    b[6] = (b[6] & 0x0f) | 0x40; // version 4
    b[8] = (b[8] & 0x3f) | 0x80; // variant 10xx
    format!(
        "{:02x}{:02x}{:02x}{:02x}-{:02x}{:02x}-{:02x}{:02x}-{:02x}{:02x}-{:02x}{:02x}{:02x}{:02x}{:02x}{:02x}",
        b[0], b[1], b[2], b[3], b[4], b[5], b[6], b[7], b[8], b[9], b[10], b[11], b[12], b[13], b[14], b[15]
    )
}

// ── Exemplo de uso ──
fn main() {
    println!("token hex      : {}", random_hex(16));
    println!("token alnum    : {}", random_token(32));
    println!("uuid v4        : {}", random_uuid());
}