// wx-rs-006-wxrs.rs
// ════════════════════════════════════════════════════════
// Título: Cliente HTTP GET com retry, timeout e backoff exponencial
// Para que serve: Realiza requisições GET resilientes, repetindo em falhas de
// rede e erros 5xx/429 com backoff exponencial e jitter, respeitando timeout.
// Dependências (Cargo.toml): reqwest = { version = "0.12", features = ["json"] },
//                             tokio = { version = "1", features = ["time", "macros", "rt-multi-thread"] },
//                             rand = "0.8"
// ════════════════════════════════════════════════════════

use rand::Rng;
use reqwest::Client;
use std::time::Duration;
use tokio::time::sleep;

const DEFAULT_TIMEOUT_SECS: u64 = 10;

/// GET com retry. Retenta em erro de rede e em 429/5xx até `max_attempts`.
pub async fn get_with_retry(
    client: &Client,
    url: &str,
    max_attempts: u32,
    base_delay_ms: u64,
) -> Result<String, String> {
    let mut attempt = 0u32;
    loop {
        attempt += 1;
        match client.get(url).send().await {
            Ok(resp) => {
                let status = resp.status();
                if status.is_success() {
                    return resp
                        .text()
                        .await
                        .map_err(|e| format!("leitura do corpo: {e}"));
                }
                let retryable = status.as_u16() == 429 || status.is_server_error();
                if !retryable || attempt >= max_attempts {
                    return Err(format!("HTTP {} ao acessar {url}", status.as_u16()));
                }
            }
            Err(e) => {
                if attempt >= max_attempts {
                    return Err(format!("falha após {max_attempts} tentativas: {e}"));
                }
            }
        }
        let delay_ms = base_delay_ms * 2u64.saturating_pow(attempt - 1);
        // Jitter de 50% a 100% do delay para evitar efeito de "thundering herd".
        let jittered = delay_ms / 2 + rand::thread_rng().gen_range(0..=delay_ms / 2);
        sleep(Duration::from_millis(jittered)).await;
    }
}

/// Cria um `Client` com timeout global de `secs` segundos.
pub fn build_client(timeout_secs: u64) -> Result<Client, reqwest::Error> {
    Client::builder()
        .timeout(Duration::from_secs(timeout_secs))
        .build()
}

// ── Exemplo de uso ──
#[tokio::main]
async fn main() {
    let client = build_client(DEFAULT_TIMEOUT_SECS).expect("falha ao criar client");
    match get_with_retry(&client, "https://httpbin.org/get", 3, 200).await {
        Ok(body) => println!("Resposta: {body}"),
        Err(e) => eprintln!("Erro: {e}"),
    }
}