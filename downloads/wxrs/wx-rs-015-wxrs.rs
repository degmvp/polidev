// wx-rs-015-wxrs.rs
// ════════════════════════════════════════════════════════
// Título: Compressão/decompressão Gzip
// Para que serve: Comprime e descomprime bytes com Gzip (níveis ajustáveis),
// ideal para payloads de rede, backup e redução de armazenamento.
// Dependências (Cargo.toml): flate2 = "1"
// ════════════════════════════════════════════════════════

use flate2::read::GzDecoder;
use flate2::write::GzEncoder;
use flate2::Compression;
use std::io::{Read, Write};

/// Compresses `data` with Gzip at the given compression level.
pub fn gzip_compress(data: &[u8], level: Compression) -> std::io::Result<Vec<u8>> {
    let mut encoder = GzEncoder::new(Vec::new(), level);
    encoder.write_all(data)?;
    encoder.finish()
}

/// Decompresses Gzip-compressed bytes.
pub fn gzip_decompress(data: &[u8]) -> std::io::Result<Vec<u8>> {
    let mut decoder = GzDecoder::new(data);
    let mut out = Vec::new();
    decoder.read_to_end(&mut out)?;
    Ok(out)
}

// ── Exemplo de uso ──
fn main() {
    let original: Vec<u8> = "texto repetido repetido repetido ".repeat(100).into_bytes();
    println!("original  : {} bytes", original.len());

    let compressed = gzip_compress(&original, Compression::default()).unwrap();
    println!("compactado: {} bytes", compressed.len());

    let restored = gzip_decompress(&compressed).unwrap();
    println!(
        "restaurado: {} bytes (igual = {})",
        restored.len(),
        restored == original
    );
}