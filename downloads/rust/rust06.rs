/// Inverte uma string preservando caracteres Unicode
pub fn inverter_string(s: &str) -> String {
    s.chars().rev().collect()
}

fn main() {
    let texto1 = "POLYDEV";
    let texto2 = "Olá Mundo";
    let texto3 = "Rust 🚀";

    println!("Original : {}", texto1);
    println!("Invertida: {}", inverter_string(texto1));

    println!();

    println!("Original : {}", texto2);
    println!("Invertida: {}", inverter_string(texto2));

    println!();

    println!("Original : {}", texto3);
    println!("Invertida: {}", inverter_string(texto3));
}