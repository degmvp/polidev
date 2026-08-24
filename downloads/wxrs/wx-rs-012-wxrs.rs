// wx-rs-012-wxrs.rs
// ════════════════════════════════════════════════════════
// Título: Codificação/decodificação Base64
// Para que serve: Encoda e decodifica dados em Base64 (padrão e URL-safe),
// usado para transmissão segura de binários em texto (tokens, anexos, APIs).
// Dependências (Cargo.toml): base64 = "0.22"
// ════════════════════════════════════════════════════════

use base64::engine::general_purpose::{STANDARD, URL_SAFE_NO_PAD};
use base64::Engine;

/// Encodes bytes as standard Base64 (with padding).
pub fn encode_standard(data: &[u8]) -> String {
    STANDARD.encode(data)
}

/// Decodes standard Base64 text back into bytes.
pub fn decode_standard(input: &str) -> Result<Vec<u8>, base64::DecodeError> {
    STANDARD.decode(input)
}

/// Encodes bytes as URL-safe Base64 without padding (safe for query strings).
pub fn encode_url_safe(data: &[u8]) -> String {
    URL_SAFE_NO_PAD.encode(data)
}

/// Decodes URL-safe Base64 (padding optional).
pub fn decode_url_safe(input: &str) -> Result<Vec<u8>, base64::DecodeError> {
    URL_SAFE_NO_PAD.decode(input)
}

// ── Exemplo de uso ──
fn main() {
    let payload = b"dados binarios \x00\x01\xff\xfe";

    let enc = encode_standard(payload);
    println!("standard: {enc}");
    println!("volta   : {:?}", decode_standard(&enc));

    let url_enc = encode_url_safe(payload);
    println!("url-safe: {url_enc}");
    println!("volta   : {:?}", decode_url_safe(&url_enc));
}