use std::env;

/// Lê valor de uma variável de ambiente
/// (retorna None se não existir)
pub fn ler_var_ambiente(chave: &str) -> Option<String> {
    env::var(chave).ok()
}

fn main() {
    let chave = "USER";

    match ler_var_ambiente(chave) {
        Some(valor) => {
            println!("{} = {}", chave, valor);
        }
        None => {
            println!("Variável '{}' não encontrada.", chave);
        }
    }
}