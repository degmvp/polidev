// wx-rs-004-wxrs.rs
// ════════════════════════════════════════════════════════
// Título: Hash e verificação de senha com Argon2
// Para que serve: Hashing seguro de senhas com Argon2id (vencedor do PHC),
// com salt aleatório, e verificação de senha contra o hash armazenado.
// Dependências (Cargo.toml): argon2 = "0.5"
// ════════════════════════════════════════════════════════

use argon2::password_hash::{rand_core::OsRng, SaltString};
use argon2::{Argon2, PasswordHash, PasswordHasher, PasswordVerifier};

/// Hashes a password using Argon2id with a freshly generated random salt.
pub fn hash_password(password: &str) -> Result<String, argon2::password_hash::Error> {
    let salt = SaltString::generate(&mut OsRng);
    let hash = Argon2::default().hash_password(password.as_bytes(), &salt)?;
    Ok(hash.to_string())
}

/// Verifies a plaintext password against a stored PHC-encoded hash.
pub fn verify_password(
    password: &str,
    stored_hash: &str,
) -> Result<bool, argon2::password_hash::Error> {
    let parsed = PasswordHash::new(stored_hash)?;
    Ok(Argon2::default()
        .verify_password(password.as_bytes(), &parsed)
        .is_ok())
}

// ── Exemplo de uso ──
fn main() {
    let senha = "minha-senha-forte!";

    let hash = hash_password(senha).expect("falha ao gerar hash");
    println!("hash: {hash}");

    println!("senha correta -> {}", verify_password(senha, &hash).unwrap());
    println!("senha errada  -> {}", verify_password("outra", &hash).unwrap());
}