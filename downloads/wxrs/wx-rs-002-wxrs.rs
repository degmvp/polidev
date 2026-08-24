// wx-rs-002-wxrs.rs
// ════════════════════════════════════════════════════════
// Título: Formatador (pretty-printer) de JSON
// Para que serve: Valida e reformata strings JSON com indentação configurável,
// útil para logs, debugging e normalização de payloads em APIs.
// Dependências (Cargo.toml): serde = { version = "1", features = ["derive"] },
//                             serde_json = "1"
// ════════════════════════════════════════════════════════

use serde_json::Value;

/// Re-indents a single line produced by `to_string_pretty` (2-space base)
/// to the requested number of spaces per level.
fn reindent_line(line: &str, indent: usize) -> String {
    let trimmed = line.trim_start();
    let level = (line.len() - trimmed.len()) / 2;
    format!("{}{}", " ".repeat(level * indent), trimmed)
}

/// Validates `input` and returns it pretty-printed with `indent` spaces per level.
pub fn pretty_json(input: &str, indent: usize) -> Result<String, serde_json::Error> {
    let value: Value = serde_json::from_str(input)?;
    if indent == 2 {
        return serde_json::to_string_pretty(&value);
    }
    Ok(serde_json::to_string_pretty(&value)?
        .lines()
        .map(|line| reindent_line(line, indent))
        .collect::<Vec<_>>()
        .join("\n"))
}

/// Minifies a JSON string (removes all insignificant whitespace).
pub fn minify_json(input: &str) -> Result<String, serde_json::Error> {
    let value: Value = serde_json::from_str(input)?;
    serde_json::to_string(&value)
}

// ── Exemplo de uso ──
fn main() {
    let compact = r#"{"nome":"Ana","ativo":true,"tags":["a","b"]}"#;
    match pretty_json(compact, 4) {
        Ok(pretty) => println!("{pretty}"),
        Err(e) => eprintln!("JSON inválido: {e}"),
    }
    println!("minificado: {}", minify_json(compact).unwrap());
}