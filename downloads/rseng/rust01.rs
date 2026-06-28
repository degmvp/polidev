#!/bin/bash
# ==========================================================
# POLYDEV | Rust Engineering
# RUST01 — Ownership: quem realmente é dono da memória?
# ==========================================================
#
# TECNOLOGIA:
# Rust (rustc)
#
# LINGUAGEM:
# Rust / Bash
#
# OBJETIVO:
# Demonstrar o conceito central do Rust: Ownership. Quando
# uma variável é atribuída a outra, o "dono" é transferido
# (Move). O compilador invalida a variável original para
# evitar Double Free, sem precisar de Garbage Collector.
#
# ATENÇÃO:
# Tipos primitivos (int, bool, float) copiam o valor (Copy).
# Tipos alocados na Heap (String, Vec) transferem a posse (Move).
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_rs && cd polydev_rs

cat > ownership.rs << 'EOF'
fn main() {
    // TIPO PRIMITIVO (Copiado na Stack)
    let x = 5;
    let y = x; // x ainda é válido aqui
    println!("Primitivo: x = {}, y = {}", x, y);

    // TIPO HEAP (String é alocada na Heap)
    let s1 = String::from("POLYDEV");
    let s2 = s1; // s1 perde a posse (Ownership) para s2. s1 é invalidado!
    
    // println!("{}", s1); // Se descomentar esta linha, o CÓDIGO NÃO COMPILA.
    
    // O compilador Rust impede o uso de memória inválida em tempo de compilação.
    println!("Heap: s2 = {}", s2);
    
    // Se precisarmos de ambos, usamos o método .clone() (Cópia profunda na Heap)
    let s3 = String::from("RUST");
    let s4 = s3.clone();
    println!("Clone: s3 = {}, s4 = {}", s3, s4);
}
EOF

rustc ownership.rs -o ownership_bin
./ownership_bin

rm -f *.rs *_bin && cd .. && rmdir polydev_rs