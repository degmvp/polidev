// wx-rs-016-wxrs.rs
// ════════════════════════════════════════════════════════
// Título: Parser de arquivos de configuração INI
// Para que serve: Lê arquivos de configuração no formato INI (seções e
// chave=valor, com comentários) sem dependências externas.
// Dependências (Cargo.toml): nenhuma (apenas std)
// ════════════════════════════════════════════════════════

use std::collections::HashMap;
use std::fs;
use std::path::Path;

#[derive(Debug, Default)]
pub struct IniFile {
    global: HashMap<String, String>,
    sections: HashMap<String, HashMap<String, String>>,
}

impl IniFile {
    /// Parses INI text. Lines starting with `;` or `#` are comments.
    pub fn parse(text: &str) -> Self {
        let mut ini = IniFile::default();
        let mut current_section: Option<String> = None;

        for raw_line in text.lines() {
            let line = raw_line.trim();
            if line.is_empty() || line.starts_with(';') || line.starts_with('#') {
                continue;
            }
            if line.starts_with('[') && line.ends_with(']') {
                current_section = Some(line[1..line.len() - 1].trim().to_string());
                ini.sections.entry(current_section.clone().unwrap()).or_default();
                continue;
            }
            if let Some((key, value)) = line.split_once('=') {
                let key = key.trim();
                let value = value.trim().trim_matches('"').to_string();
                match &current_section {
                    Some(sec) => {
                        ini.sections
                            .entry(sec.clone())
                            .or_default()
                            .insert(key.to_string(), value);
                    }
                    None => {
                        ini.global.insert(key.to_string(), value);
                    }
                }
            }
        }
        ini
    }

    /// Reads a value: pass `Some("secao")` for a section key or `None` for global.
    pub fn get(&self, section: Option<&str>, key: &str) -> Option<&str> {
        match section {
            Some(sec) => self
                .sections
                .get(sec)
                .and_then(|m| m.get(key))
                .map(|s| s.as_str()),
            None => self.global.get(key).map(|s| s.as_str()),
        }
    }

    /// Iterates over the section names.
    pub fn sections(&self) -> impl Iterator<Item = &String> {
        self.sections.keys()
    }
}

/// Loads and parses an INI file from disk.
pub fn from_file(path: &Path) -> std::io::Result<IniFile> {
    let text = fs::read_to_string(path)?;
    Ok(IniFile::parse(&text))
}

// ── Exemplo de uso ──
fn main() {
    let ini_text = r#"
; arquivo de exemplo
host = localhost
port = 8080

[database]
name = "app_db"
user = admin
"#;
    let ini = IniFile::parse(ini_text);
    println!("host global: {:?}", ini.get(None, "host"));
    println!("port global: {:?}", ini.get(None, "port"));
    println!("db name    : {:?}", ini.get(Some("database"), "name"));
    println!("seções     : {:?}", ini.sections().collect::<Vec<_>>());
}