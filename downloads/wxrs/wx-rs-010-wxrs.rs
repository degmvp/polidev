// wx-rs-010-wxrs.rs
// ════════════════════════════════════════════════════════
// Título: Varredura recursiva de diretórios com metadados
// Para que serve: Percorre uma árvore de diretórios coletando caminho, tamanho
// e tipo de cada entrada, com limite de profundidade. Base para indexadores,
// backup e relatórios de uso de disco.
// Dependências (Cargo.toml): walkdir = "2"
// ════════════════════════════════════════════════════════

use std::path::Path;
use walkdir::WalkDir;

#[derive(Debug, Clone)]
pub struct FileMeta {
    pub path: String,
    pub size: u64,
    pub is_dir: bool,
    pub depth: usize,
}

/// Recursively scans `root` up to `max_depth` collecting file metadata.
pub fn scan_directory(root: &Path, max_depth: usize) -> Vec<FileMeta> {
    WalkDir::new(root)
        .max_depth(max_depth)
        .follow_links(false)
        .sort_by_file_name()
        .into_iter()
        .filter_map(|entry| entry.ok())
        .map(|entry| {
            let is_dir = entry.file_type().is_dir();
            let size = if is_dir {
                0
            } else {
                entry.metadata().map(|m| m.len()).unwrap_or(0)
            };
            FileMeta {
                path: entry.path().display().to_string(),
                size,
                is_dir,
                depth: entry.depth(),
            }
        })
        .collect()
}

/// Total size (in bytes) of all files under `root`.
pub fn total_size(root: &Path) -> u64 {
    scan_directory(root, usize::MAX)
        .iter()
        .filter(|m| !m.is_dir)
        .map(|m| m.size)
        .sum()
}

// ── Exemplo de uso ──
fn main() {
    let root = Path::new(".");
    for meta in scan_directory(root, 2).iter().take(10) {
        let kind = if meta.is_dir { "dir " } else { "file" };
        println!("[{kind}] {} bytes - {}", meta.size, meta.path);
    }
    println!("tamanho total: {} bytes", total_size(root));
}