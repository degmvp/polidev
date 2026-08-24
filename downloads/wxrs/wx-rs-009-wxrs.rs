// wx-rs-009-wxrs.rs
// ════════════════════════════════════════════════════════
// Título: Similaridade fuzzy (distância de Levenshtein)
// Para que serve: Calcula a distância de edição entre strings e oferece busca
// fuzzy em listas, útil para autocomplete, correção de digitação e deduplicação.
// Dependências (Cargo.toml): nenhuma (apenas std)
// ════════════════════════════════════════════════════════

/// Returns the Levenshtein edit distance between `a` and `b`
/// (insertions, deletions and substitutions cost 1 each).
pub fn levenshtein(a: &str, b: &str) -> usize {
    let a: Vec<char> = a.chars().collect();
    let b: Vec<char> = b.chars().collect();
    let (n, m) = (a.len(), b.len());
    if n == 0 {
        return m;
    }
    if m == 0 {
        return n;
    }
    let mut prev: Vec<usize> = (0..=m).collect();
    let mut curr = vec![0usize; m + 1];

    for i in 1..=n {
        curr[0] = i;
        for j in 1..=m {
            let cost = if a[i - 1] == b[j - 1] { 0 } else { 1 };
            curr[j] = (prev[j] + 1)           // deleção
                .min(curr[j - 1] + 1)         // inserção
                .min(prev[j - 1] + cost);     // substituição
        }
        std::mem::swap(&mut prev, &mut curr);
    }
    prev[m]
}

/// Returns the best fuzzy matches in `candidates` within `max_distance`.
pub fn fuzzy_find<'a>(
    query: &str,
    candidates: &'a [&str],
    max_distance: usize,
) -> Vec<(&'a str, usize)> {
    let query = query.to_lowercase();
    let mut hits: Vec<(&str, usize)> = candidates
        .iter()
        .filter_map(|c| {
            let d = levenshtein(&query, &c.to_lowercase());
            (d <= max_distance).then_some((*c, d))
        })
        .collect();
    hits.sort_by_key(|(_, d)| *d);
    hits
}

// ── Exemplo de uso ──
fn main() {
    println!("kitten <-> sitting = {}", levenshtein("kitten", "sitting")); // 3

    let nomes = ["Ana Paula", "Paula", "Paulo", "Mariana", "Mari"];
    for (nome, dist) in fuzzy_find("paulo", &nomes, 2) {
        println!("{nome}: distância {dist}");
    }
}