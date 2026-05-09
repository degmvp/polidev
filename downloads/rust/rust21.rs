/// Retorna referência ao maior elemento (requer PartialOrd)
pub fn maximo_slice<T: PartialOrd>(slice: &[T]) -> Option<&T> {
    slice.iter()
         .max_by(|a, b| a.partial_cmp(b)
         .unwrap_or(std::cmp::Ordering::Equal))
}


fn main() {
    let palavras = [
        String::from("banana"),
        String::from("uva"),
        String::from("abacaxi"),
    ];

    if let Some(max) = maximo_slice(&palavras) {
        println!("Maior lexicograficamente: {}", max);
    }
}