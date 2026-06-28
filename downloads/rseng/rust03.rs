#!/bin/bash
# ==========================================================
# POLYDEV | Rust Engineering
# RUST03 — Lifetimes sem mistério.
# ==========================================================
#
# TECNOLOGIA:
# Rust (rustc)
#
# LINGUAGEM:
# Rust / Bash
#
# OBJETIVO:
# Desmistificar as Anotações de Tempo de Vida ('a). Elas
# não mudam o tempo de vida dos dados, apenas ajudam o
# compilador a verificar se as referências devolvidas por
# uma função são válidas.
#
# ATENÇÃO:
# A maioria das vezes o compilador infere o Lifetime (ELISION).
# Você só escreve 'a quando o compilador não consegue adivinhar.
// retorno viverá pelo menos
// enquanto a menor das duas ent
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_rs && cd polydev_rs

cat > lifetimes.rs << 'EOF'
// O<'a> informa ao compilador que a referência retornada
// viverá pelo menos enquanto o menor tempo de vida entre
// as duas referências recebidas.

fn maior<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() { x } else { y }
}

fn main() {
    let string1 = String::from("Polydev Longo");
    let resultado;
    
    {
        let string2 = String::from("Curto");
        // string2 morre aqui dentro do bloco. 
        // Se resultado apontasse para string2, o compilador barraria aqui.
        resultado = maior(string1.as_str(), string2.as_str());
    } // Fim do escopo de string2

    // Como o compilador sabe que 'resultado' vive mais que string2,
    // ele garante que 'resultado' só pode estar apontando para string1.
    println!("A maior string é: {}", resultado);
}
EOF

rustc lifetimes.rs -o lifetimes_bin
./lifetimes_bin

rm -f *.rs *_bin && cd .. && rmdir polydev_rs
