/// Validação leve de formato email (local@dominio.ext)
pub fn validar_email(email: &str) -> bool {
    let partes: Vec<&str> = email.split('@').collect();

    if partes.len() != 2 {
        return false;
    }

    let [local, dominio] = partes[..] else {
        return false;
    };

    !local.is_empty()
        && !dominio.is_empty()
        && dominio.contains('.')
}

fn main() {
    let emails = [
        "user@email.com",
        "admin@polydev.org",
        "teste@",
        "@dominio.com",
        "semarroba.com",
        "rust@lang",
    ];

    for email in emails {
        println!("{:<25} => {}", email, validar_email(email));
    }
}