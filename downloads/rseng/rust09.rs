#!/bin/bash
# ==========================================================
# POLYDEV | Rust Engineering
# RUST09 — Unsafe Rust: quando realmente é necessário.
# ==========================================================
#
# TECNOLOGIA:
# Rust (rustc)
#
# LINGUAGEM:
# Rust / Bash
#
# OBJETIVO:
# Demonstrar como desativar as verificações de segurança do
# Borrow Checker usando o bloco `unsafe`. Usado apenas para
# FFI (chamar código C), manipulação de hardware crítico
# ou micro-otimizações extremas.
#
# ATENÇÃO:
# Usar `unsafe` não desliga o gerenciamento de memória. Ele
# apenas diz ao compilador: "Eu garanto que isso é seguro".
# Se você mentir, o programa sofrerá Segmentation Fault.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_rs && cd polydev_rs

cat > unsafe_rust.rs << 'EOF'
fn main() {
    let mut numero = 42;

    // Criando um ponteiro bruto (Raw Pointer). Isso é permitido em Safe Rust.
    let ponteiro_constante: *const i32 = &numero;
    let ponteiro_mutavel: *mut i32 = &mut numero;

    // Desreferenciar um ponteiro bruto SÓ é permitido dentro de um bloco unsafe
    unsafe {
        println!("Lendo ponteiro bruto: {}", *ponteiro_constante);
        
        *ponteiro_mutavel = 100; // Alterando a memória diretamente
        
        println!("Após mutação insegura: {}", *ponteiro_mutavel);
    }

    // Fora do bloco unsafe, a variável normal reflete a mudança feita no nível da memória
    println!("Valor original da variável: {}", numero);
}
EOF

rustc unsafe_rust.rs -o unsafe_bin
./unsafe_bin

rm -f *.rs *_bin && cd .. && rmdir polydev_rs