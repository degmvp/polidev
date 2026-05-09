/// Calcula o fatorial (iterativo para evitar estouro de pilha)
pub fn fatorial(n: u64) -> u64 {
    (1..=n).product()
}

fn main() {

    let numeros = [0, 1, 2, 3, 5, 10];

    println!("=== CÁLCULO FATORIAL ===");

    for n in numeros {
        println!("{}! = {}", n, fatorial(n));
    }
}