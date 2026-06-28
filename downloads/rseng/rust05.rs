#!/bin/bash
# ==========================================================
# POLYDEV | Rust Engineering
# RUST05 — Enums que mudam a forma de modelar sistemas.
# ==========================================================
#
# TECNOLOGIA:
# Rust (rustc)
#
# LINGUAGEM:
# Rust / Bash
#
# OBJETIVO:
# Demonstrar Enums Algébricos. No Rust, Enums podem carregar
# dados internos de tipos diferentes. Isso elimina a
# necessidade de Exceptions nulas ou heranças complexas.
#
# ATENÇÃO:
# Enums no Rust são "Sum Types" (Tipos Soma). Um valor pode
# ser UMA variante E SOMENTE UMA por vez.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_rs && cd polydev_rs

cat > enums.rs << 'EOF'
// Enum que modela o estado de uma conexão
enum StatusConexao {
    Conectado { ip: String, porta: u16 }, // Carrega dados nomeados
    Desconectado(String),                 // Carrega apenas uma String
    TentandoReconectar(u8),               // Carrega apenas um número
}

// Enum clássico de option embutido na linguagem (Option<T>)
fn dividir(a: f64, b: f64) -> Option<f64> {
    if b == 0.0 {
        None // Não existe exceção no Rust puro. Retorna um "Vazio" tipado.
    } else {
        Some(a / b)
    }
}

fn main() {
    let estado1 = StatusConexao::Conectado { ip: String::from("192.168.1.10"), porta: 443 };
    let estado2 = StatusConexao::Desconectado(String::from("Cabo desconectado"));
    let estado3 = StatusConexao::TentandoReconectar(3);

    // Desestruturação baseada no estado
    if let StatusConexao::Conectado { ip, porta } = estado1 {
        println!("Conectado em {}:{}", ip, porta);
    }

    // Tratamento elegante de erros sem Try/Catch
    match dividir(10.0, 2.0) {
        Some(resultado) => println!("Resultado da divisão: {}", resultado),
        None => println!("Erro matemático: Divisão por zero."),
    }
}
EOF

rustc enums.rs -o enums_bin
./enums_bin

rm -f *.rs *_bin && cd .. && rmdir polydev_rs