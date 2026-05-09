/// Retorna Some(a/b) ou None se b for zero
pub fn divisao_segura(a: f64, b: f64) -> Option<f64> {
    if b == 0.0 {
        None
    } else {
        Some(a / b)
    }
}

fn main() {
    let x = 10.0;
    let y = 2.0;

    match divisao_segura(x, y) {
        Some(resultado) => {
            println!("Resultado: {}", resultado);
        }
        None => {
            println!("Erro: divisão por zero!");
        }
    }

    let a = 8.0;
    let b = 0.0;

    match divisao_segura(a, b) {
        Some(resultado) => {
            println!("Resultado: {}", resultado);
        }
        None => {
            println!("Erro: divisão por zero!");
        }
    }
}