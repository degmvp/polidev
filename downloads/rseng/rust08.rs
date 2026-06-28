#!/bin/bash
# ==========================================================
# POLYDEV | Rust Engineering
# RUST08 — Zero-Cost Abstractions.
# ==========================================================
#
# TECNOLOGIA:
# Rust (rustc)
#
# LINGUAGEM:
# Rust / Bash
#
# OBJETIVO:
# Provar que escrever código de alto nível (Iteradores)
# no Rust gera o EXATO mesmo assembly que escrever loops
# manuais de baixo nível. Você não paga custo de performance
# por usar abstrações.
#
# ATENÇÃO:
# Ao contrário do Java (que boxing/unboxing objetos no Iterator),
# o Rust monomorfiza e inlined o código do Iterator em tempo
# de compilação, transformando-o em um simples loop while otimizado.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_rs && cd polydev_rs

cat > zerocost.rs << 'EOF'
fn main() {
    let dados = vec![1, 2, 3, 4, 5];

    // ABSTRAÇÃO DE ALTO NÍVEL (Idiomatic Rust)
    // Parece que cria objetos intermediários na memória, mas NÃO cria.
    let soma_alto_nivel: i32 = dados.iter()
        .filter(|x| *x % 2 == 0) // Filtra pares
        .map(|x| x * 10)         // Multiplica por 10
        .sum();                   // Soma tudo

    // BAIXO NÍVEL (Estilo C imperativo)
    let mut soma_baixo_nivel = 0;
    for i in 0..dados.len() {
        if dados[i] % 2 == 0 {
            soma_baixo_nivel += dados[i] * 10;
        }
    }

    println!("Resultado Alto Nível (Abstração): {}", soma_alto_nivel);
    println!("Resultado Baixo Nível (Manual):    {}", soma_baixo_nivel);
    
    // Para o compilador Rust, ambos os blocos acima geram o mesmo assembly.
    // A abstração teve custo ZERO de execução.
}
EOF

rustc zerocost.rs -o zerocost_bin
./zerocost_bin

rm -f *.rs *_bin && cd .. && rmdir polydev_rs