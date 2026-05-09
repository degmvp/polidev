/// Retorna referência ao maior elemento (requer PartialOrd)
pub fn maximo_slice<T: PartialOrd>(slice: &[T]) -> Option<&T> {
    slice.iter().max_by(|a, b| a.partial_cmp(b).unwrap_or(std::cmp::Ordering::Equal))
}

fn main() {
    let nums = [10, 45, 3, 99, 27];

    if let Some(max) = maximo_slice(&nums) {
        println!("Maior número: {}", max);
    }
}