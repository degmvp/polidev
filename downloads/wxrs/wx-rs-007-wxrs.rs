// wx-rs-007-wxrs.rs
// ════════════════════════════════════════════════════════
// Título: Parser de logs com regex e extração estruturada
// Para que serve: Extrai campos (timestamp, nível, mensagem) de linhas de log
// e agrega estatísticas, útil para análise e monitoramento de aplicações.
// Dependências (Cargo.toml): regex = "1"
// ════════════════════════════════════════════════════════

use regex::Regex;
use std::collections::HashMap;

#[derive(Debug, Clone, PartialEq)]
pub struct LogEntry {
    pub timestamp: Option<String>,
    pub level: Option<String>,
    pub message: String,
}

/// Padrão comum: "2026-08-24T10:15:30Z INFO mensagem".
static LOG_RE: &str = r"(?P<ts>\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})?)?\s*(?P<level>DEBUG|INFO|WARN|ERROR|FATAL)?\s*(?P<msg>.*)";

/// Parses a single log line into a structured `LogEntry`.
pub fn parse_log_line(line: &str) -> LogEntry {
    let re = Regex::new(LOG_RE).expect("regex válida");
    let caps = re.captures(line).expect("sempre captura");
    LogEntry {
        timestamp: caps.name("ts").map(|m| m.as_str().to_string()),
        level: caps.name("level").map(|m| m.as_str().to_string()),
        message: caps
            .name("msg")
            .map(|m| m.as_str().trim().to_string())
            .unwrap_or_default(),
    }
}

/// Counts log levels across many lines.
pub fn count_levels(lines: &[String]) -> HashMap<String, usize> {
    let mut counts = HashMap::new();
    for line in lines {
        if let Some(level) = parse_log_line(line).level {
            *counts.entry(level).or_insert(0) += 1;
        }
    }
    counts
}

// ── Exemplo de uso ──
fn main() {
    let logs = vec![
        "2026-08-24T10:15:30Z INFO servidor iniciado".to_string(),
        "2026-08-24T10:15:31Z ERROR falha ao conectar no banco".to_string(),
        "2026-08-24T10:15:32Z WARN tentando novamente".to_string(),
    ];
    for line in &logs {
        println!("{:?}", parse_log_line(line));
    }
    println!("contagens: {:?}", count_levels(&logs));
}