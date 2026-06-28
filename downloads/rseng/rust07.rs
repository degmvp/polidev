#!/bin/bash
# ==========================================================
# POLYDEV | Rust Engineering
# RUST07 — Result<T,E>: o fim das exceções tradicionais.
# ==========================================================
#
# TECNOLOGIA:
# Rust (rustc)
#
# LINGUAGEM:
# Rust / Bash
#
# OBJETIVO:
# Substituir o Try/Catch por Tipos. O Result<T, E> força o
# programador a lidar com o erro no momento da chamada da
# função. O operador `?` propaga o erro de forma limpa.
#
# ATENÇÃO:
# Como DBA, você sabe que exceções não tratadas derrubam
# bancos. No Rust, erros são valores (Tipos), e o compilador
# grita se você tentar ignorar um Result.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_rs && cd polydev_rs

cat > result.rs << 'EOF'
use std::fs;
use std::io;

// Retorna um Result. Ok(String) em caso de sucesso, Err(io::Error) em falha.
fn ler_config(caminho: &str) -> Result<String, io::Error> {
    // O operador `?` é a mágica: Se for Err, ele retorna o Err da função imediatamente.
    // Se for Ok, ele desempacota o valor interno. Substitui vários if/else.
    let conteudo = fs::read_to_string(caminho)?;
    Ok(conteudo)
}

fn main() {
    let arquivo = "config_polydev.txt";
    
    // O match obrigatório trata a felicidade e o fracasso
    match ler_config(arquivo) {
        Ok(config) => println!("Configuração lida:\n{}", config),
        Err(erro) => eprintln!("[FALHA CRÍTICA] Não foi possível ler '{}'. Detalhes: {}", arquivo, erro),
    }
}
EOF

rustc result.rs -o result_bin
./result_bin

rm -f *.rs *_bin && cd .. && rmdir polydev_rs