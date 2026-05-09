/// Retorna um novo vetor apenas com números pares
pub fn filtrar_pares(nums: &[i32]) -> Vec<i32> {
    nums.iter()
        .copied()
        .filter(|n| n % 2 == 0)
        .collect()
}

fn main() {
    let numeros = vec![1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

    let pares = filtrar_pares(&numeros);

    println!("Números originais : {:?}", numeros);
    println!("Números pares     : {:?}", pares);
}