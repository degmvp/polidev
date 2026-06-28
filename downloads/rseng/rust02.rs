#!/bin/bash
# ==========================================================
# POLYDEV | Rust Engineering
# RUST02 — Borrow Checker: o compilador virou seu arquiteto.
# ==========================================================
#
# TECNOLOGIA:
# Rust (rustc)
#
# LINGUAGEM:
# Rust / Bash
#
# OBJETIVO:
# Mostrar como emprestar (Borrow) uma variável sem assumir
# seu Ownership, usando referências (&). O Borrow Checker
# garante: ou N referências imutáveis, ou EXATAMENTE 1 mutável.
#
# ATENÇÃO:
# Nunca crie uma referência mutável enquanto houver uma
# referência imutável ativa no mesmo escopo. O compilador barra.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_rs && cd polydev_rs

cat > borrow.rs << 'EOF'
fn calcular_tamanho(texto: &String) -> usize {
    // &String é um empréstimo (Borrow). A função não se torna dona.
    texto.len()
}

fn adicionar_mundo(texto: &mut String) {
    // &mut String é um empréstimo mutável. Permite alterar o dado original.
    texto.push_str(", Mundo!");
}

fn main() {
    let mut frase = String::from("POLYDEV");

    // EMPRÉSTIMO IMUTÁVEL
    let tamanho = calcular_tamanho(&frase);
    println!("Tamanho: {}", tamanho);

    // EMPRÉSTIMO MUTÁVEL
    adicionar_mundo(&mut frase);
    println!("Após mutação: {}", frase);

    // ERRO DE ARQUITETURA DO COMPILADOR:
    // let r1 = &frase;
    // let r2 = &mut frase; // ERRO! Não pode ter mutável e imutável ao mesmo tempo.
    // println!("{}, {}", r1, r2);
}
EOF

rustc borrow.rs -o borrow_bin
./borrow_bin

rm -f *.rs *_bin && cd .. && rmdir polydev_rs