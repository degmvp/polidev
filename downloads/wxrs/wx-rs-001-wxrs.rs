// wx-rs-001-wxrs.rs
// ════════════════════════════════════════════════════════
// Título: Leitor de CSV robusto
// Para que serve: Faz o parsing de conteúdo CSV em linhas de campos, lidando
// com campos entre aspas, vírgulas internas, aspas escapadas ("") e BOM UTF-8.
// Ideal para ingestão de dados em pipelines profissionais.
// Dependências (Cargo.toml): nenhuma (apenas std)
// ════════════════════════════════════════════════════════

use std::fs;
use std::path::Path;

/// Remove the UTF-8 BOM from the start of the input if present.
fn strip_bom(input: &str) -> &str {
    input.strip_prefix('\u{feff}').unwrap_or(input)
}

/// Parses a CSV text into rows of fields.
///
/// Handles quoted fields, embedded commas, escaped quotes (`""`), and newlines
/// inside quoted fields.
pub fn parse_csv(input: &str) -> Vec<Vec<String>> {
    let text = strip_bom(input);
    let mut rows: Vec<Vec<String>> = Vec::new();
    let mut row: Vec<String> = Vec::new();
    let mut field = String::new();
    let mut in_quotes = false;

    let mut chars = text.chars().peekable();
    while let Some(c) = chars.next() {
        match c {
            '"' if in_quotes => {
                // Escaped quote inside a quoted field ("").
                if chars.peek() == Some(&'"') {
                    chars.next();
                    field.push('"');
                } else {
                    in_quotes = false;
                }
            }
            '"' => in_quotes = true,
            ',' if !in_quotes => row.push(std::mem::take(&mut field)),
            '\r' if !in_quotes => {} // swallow \r from CRLF line endings
            '\n' if !in_quotes => {
                row.push(std::mem::take(&mut field));
                rows.push(std::mem::take(&mut row));
            }
            _ => field.push(c),
        }
    }
    // Flush the last row when the input has no trailing newline.
    if !field.is_empty() || !row.is_empty() {
        row.push(field);
        rows.push(row);
    }
    rows
}

/// Reads a CSV file from disk and parses it.
pub fn parse_csv_file(path: &Path) -> Result<Vec<Vec<String>>, std::io::Error> {
    let content = fs::read_to_string(path)?;
    Ok(parse_csv(&content))
}

// ── Exemplo de uso ──
fn main() {
    let csv = "\u{feff}nome,idade,nota\n\"Silva, João\",30,9.5\n\"Souza\"\" Jr.\",25,8.0";
    for (i, row) in parse_csv(csv).iter().enumerate() {
        println!("Linha {i}: {row:?}");
    }
}