/// Converte temperatura de Celsius para Fahrenheit
pub fn celsius_para_fahrenheit(c: f64) -> f64 {
    c * 9.0 / 5.0 + 32.0
}

fn main() {
    let celsius = 30.0;

    let fahrenheit = celsius_para_fahrenheit(celsius);

    println!("{}°C equivalem a {}°F", celsius, fahrenheit);
}