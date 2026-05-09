pub fn eh_palindromo(s: &str) -> bool {
    let limpa: String = s.chars()
        .filter(|c| c.is_alphanumeric())
        .map(|c| c.to_lowercase().next().unwrap())
        .collect();

    limpa == limpa.chars().rev().collect::<String>()
}

fn main() {
    let testes = vec![
        "Radar",
        "Socorram me subi no onibus em Marrocos",
        "Rust",
        "Ame a ema",
        "12321",
        "OpenAI"
    ];

    for texto in testes {
        if eh_palindromo(texto) {
            println!("\"{}\" => É palíndromo", texto);
        } else {
            println!("\"{}\" => NÃO é palíndromo", texto);
        }
    }
}