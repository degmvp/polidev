/// Retorna true se o número for primo
pub fn eh_primo(n: u64) -> bool {
    if n < 2 {
        return false;
    }

    if n == 2 || n == 3 {
        return true;
    }

    if n % 2 == 0 || n % 3 == 0 {
        return false;
    }

    let mut i = 5;

    while i * i <= n {
        if n % i == 0 || n % (i + 2) == 0 {
            return false;
        }

        i += 6;
    }

    true
}

fn main() {

    let numeros = [1, 2, 3, 4, 5, 7, 9, 11, 15, 17, 19, 20, 23, 29];

    println!("=== TESTE DE NÚMEROS PRIMOS ===");

    for n in numeros {

        if eh_primo(n) {
            println!("{} => É primo", n);
        } else {
            println!("{} => NÃO é primo", n);
        }
    }
}