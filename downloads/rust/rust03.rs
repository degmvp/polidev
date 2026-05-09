use std::{fs, io};

/// Escreve texto em um arquivo (sobrescreve se existir)
pub fn escrever_txt(caminho: &str, conteudo: &str) -> Result<(), io::Error> {
    fs::write(caminho, conteudo)
}

fn main() -> Result<(), io::Error> {

    let texto = "\
POLYDEV
Leia • Entenda • Execute seu código

Rust é rápido, seguro e moderno.
";

    // Escreve arquivo
    escrever_txt("polydev.txt", texto)?;

    println!("Arquivo gravado com sucesso!");

    // Lê novamente para conferir
    let conteudo = fs::read_to_string("polydev.txt")?;

    println!("\n=== CONTEÚDO DO ARQUIVO ===");
    println!("{}", conteudo);

    Ok(())
}
