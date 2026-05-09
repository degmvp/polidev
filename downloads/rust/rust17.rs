/// Hash simples e rápido para strings
/// (não criptográfico)
pub fn hash_djb2(s: &str) -> u64 {
    s.bytes()
        .fold(5381, |hash, byte| {
            (hash.wrapping_mul(33))
                .wrapping_add(byte as u64)
        })
}

fn main() {
    let texto = "POLYDEV";

    let hash = hash_djb2(texto);

    println!("Texto : {}", texto);
    println!("Hash  : {}", hash);
}