/// Verifica se a string é palíndromo (ignora espaços e maiúsculas)
pub fn eh_palindromo(s: &str) -> bool {
    let limpa: String = s.chars()
        .filter(|c| c.is_alphanumeric())
        .map(|c| c.to_lowercase().next().unwrap())
        .collect();
    limpa == limpa.chars().rev().collect::<String>()
}