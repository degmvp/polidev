/// Ordena um vetor in-place
/// (usa o algoritmo interno do Rust)
pub fn ordenar_vetor(v: &mut Vec<i32>) {
    v.sort();
}

fn main() {
    let mut numeros = vec![9, 4, 1, 7, 3, 8, 2, 6, 5];

    println!("Antes : {:?}", numeros);

    ordenar_vetor(&mut numeros);

    println!("Depois: {:?}", numeros);
}