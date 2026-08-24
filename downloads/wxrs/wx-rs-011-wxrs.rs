// wx-rs-011-wxrs.rs
// ════════════════════════════════════════════════════════
// Título: Conversor CSV → JSON
// Para que serve: Converte conteúdo CSV (com cabeçalho) em um array de objetos
// JSON, tratando aspas e vírgulas internas. Útil para APIs e ETL.
// Dependências (Cargo.toml): serde = { version = "1", features = ["derive"] },
//                             serde_json = "1"
// ════════════════════════════════════════════════════════

use serde_json::{json, Map, Value};

/// Tokenizes a CSV line (simplified: no embedded newlines).
fn split_line(line: &str) -> Vec<String> {
    let mut fields = Vec::new();
    let mut field = String::new();
    let mut in_quotes = false;
    let mut chars = line.chars().peekable();
    while let Some(c) = chars.next() {
        match c {
            '"' if in_quotes => {
                if chars.peek() == Some(&'"') {
                    chars.next();
                    field.push('"');
                } else {
                    in_quotes = false;
                }
            }
            '"' => in_quotes = true,
            ',' if !in_quotes => fields.push(std::mem::take(&mut field)),
            _ => field.push(c),
        }
    }
    fields.push(field);
    fields
}

/// Converts CSV text with a header row into a JSON array of objects.
pub fn csv_to_json(csv: &str) -> Result<Vec<Value>, String> {
    let text = csv.strip_prefix('\u{feff}').unwrap_or(csv);
    let mut lines = text.lines().filter(|l| !l.trim().is_empty());
    let header = lines
        .next()
        .ok_or_else(|| "CSV vazio: sem linha de cabeçalho".to_string())?;
    let header: Vec<String> = split_line(header);

    let mut rows = Vec::new();
    for line in lines {
        let fields = split_line(line);
        let mut obj = Map::new();
        for (i, name) in header.iter().enumerate() {
            let value = fields.get(i).map(|s| s.as_str()).unwrap_or("");
            // Tenta interpretar números e booleanos de forma automática.
            obj.insert(name.clone(), infer_value(value));
        }
        rows.push(Value::Object(obj));
    }
    Ok(rows)
}

/// Infers number/boolean/string from a raw CSV field.
fn infer_value(raw: &str) -> Value {
    if let Ok(n) = raw.parse::<i64>() {
        return json!(n);
    }
    if let Ok(f) = raw.parse::<f64>() {
        return json!(f);
    }
    match raw {
        "true" => json!(true),
        "false" => json!(false),
        _ => json!(raw),
    }
}

// ── Exemplo de uso ──
fn main() {
    let csv = "nome,idade,ativo\n\"Silva, João\",30,true\nAna,25,false";
    match csv_to_json(csv) {
        Ok(rows) => println!("{}", serde_json::to_string_pretty(&rows).unwrap()),
        Err(e) => eprintln!("Erro: {e}"),
    }
}