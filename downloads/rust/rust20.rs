use std::io::{self, Error, ErrorKind};
use std::process::Command;

/// Roda um comando do sistema e retorna
/// a saída padrão ou erro
pub fn executar_comando(
    cmd: &str,
    args: &[&str]
) -> Result<String, io::Error> {

    let output = Command::new(cmd)
        .args(args)
        .output()?;

    if output.status.success() {
        Ok(
            String::from_utf8_lossy(&output.stdout)
                .to_string()
        )
    } else {
        Err(
            Error::new(
                ErrorKind::Other,
                String::from_utf8_lossy(&output.stderr)
                    .to_string()
            )
        )
    }
}

fn main() {

    #[cfg(target_os = "windows")]
    let resultado = executar_comando(
        "cmd",
        &["/C", "dir"]
    );

    #[cfg(not(target_os = "windows"))]
    let resultado = executar_comando(
        "ls",
        &["-la"]
    );

    match resultado {
        Ok(saida) => {
            println!("Saída do comando:\n");
            println!("{}", saida);
        }

        Err(e) => {
            println!("Erro ao executar comando:");
            println!("{}", e);
        }
    }
}