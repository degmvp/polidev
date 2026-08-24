// wx-rs-003-wxrs.rs
// ════════════════════════════════════════════════════════
// Título: Hash SHA-256 de arquivo via streaming
// Para que serve: Calcula o SHA-256 de arquivos grandes sem carregá-los na
// memória, lendo em blocos. Útil para verificação de integridade e deduplicação.
// Dependências (Cargo.toml): sha2 = "0.10"
// ════════════════════════════════════════════════════════

use sha2::{Digest, Sha256};
use std::fs::File;
use std::io::{BufReader, Read};
use std::path::Path;

const CHUNK_SIZE: usize = 64 * 1024;

/// Formats bytes as a lowercase hexadecimal string.
pub fn hex(bytes: &[u8]) -> String {
    bytes.iter().map(|b| format!("{b:02x}")).collect()
}

/// Computes the SHA-256 of a file by streaming it in fixed-size chunks.
pub fn sha256_file(path: &Path) -> Result<String, std::io::Error> {
    let file = File::open(path)?;
    let mut reader = BufReader::with_capacity(CHUNK_SIZE, file);
    let mut hasher = Sha256::new();
    let mut buffer = [0u8; CHUNK_SIZE];

    loop {
        let n = reader.read(&mut buffer)?;
        if n == 0 {
            break;
        }
        hasher.update(&buffer[..n]);
    }
    Ok(hex(&hasher.finalize()))
}

/// Computes the SHA-256 of an in-memory byte slice.
pub fn sha256_bytes(data: &[u8]) -> String {
    let mut hasher = Sha256::new();
    hasher.update(data);
    hex(&hasher.finalize())
}

// ── Exemplo de uso ──
fn main() {
    let content = b"conteudo sensivel para integridade";
    println!("sha256(bytes) = {}", sha256_bytes(content));

    // Uso com arquivo:
    // match sha256_file(std::path::Path::new("backup.tar.gz")) {
    //     Ok(digest) => println!("sha256(file)   = {digest}"),
    //     Err(e) => eprintln!("Erro ao ler o arquivo: {e}"),
    // }
}