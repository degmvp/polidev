use std::{fs, io};

/// Lê um arquivo CSV separado por vírgula e retorna linhas como vetores
pub fn ler_csv_simples(caminho: &str) -> Result<Vec<Vec<String>>, io::Error> {
    let conteudo = fs::read_to_string(caminho)?;

    Ok(
        conteudo
            .lines()
            .map(|linha| {
                linha
                    .split(',')
                    .map(|s| s.trim().to_string())
                    .collect()
            })
            .collect()
    )
}

fn main() -> Result<(), io::Error> {

    // Exemplo de CSV
    let exemplo = "\
nome,idade,cidade
Ana,25,São Paulo
Carlos,30,Rio de Janeiro
Maria,28,Belo Horizonte";

    // Cria arquivo CSV
    fs::write("dados.csv", exemplo)?;

    // Lê CSV
    let dados = ler_csv_simples("dados.csv")?;

    println!("=== CONTEÚDO CSV ===");

    for (i, linha) in dados.iter().enumerate() {
        println!("Linha {}:", i + 1);

        for coluna in linha {
            print!("[{}] ", coluna);
        }

        println!();
    }

    Ok(())
}