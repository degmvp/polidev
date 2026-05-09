use std::collections::HashMap;

/// Conta quantas vezes cada palavra aparece no texto
pub fn contar_palavras(texto: &str) -> HashMap<String, usize> {
    let mut mapa = HashMap::new();

    for palavra in texto.split_whitespace() {
        *mapa.entry(palavra.to_lowercase()).or_insert(0) += 1;
    }

    mapa
}

fn main() {
    let frase = "Rust é rápido Rust é seguro Rust é moderno";

    let resultado = contar_palavras(frase);

    println!("Contagem de palavras:\n");

    for (palavra, quantidade) in &resultado {
        println!("{} => {}", palavra, quantidade);
    }
}