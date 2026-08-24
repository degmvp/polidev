// wx-rs-019-wxrs.rs
// ════════════════════════════════════════════════════════
// Título: Wrapper de cliente REST com autenticação Bearer
// Para que serve: Cliente REST reutilizável com base URL, token Bearer e
// serialização JSON automática para GET/POST/DELETE. Base para integrações
// com APIs de terceiros.
// Dependências (Cargo.toml): reqwest = { version = "0.12", features = ["json"] },
//                             serde = { version = "1", features = ["derive"] },
//                             serde_json = "1",
//                             tokio = { version = "1", features = ["macros", "rt-multi-thread"] }
// ════════════════════════════════════════════════════════

use reqwest::{Client, Method};
use serde::de::DeserializeOwned;
use serde::Serialize;

/// Lightweight REST client with optional Bearer token auth.
#[derive(Clone)]
pub struct RestClient {
    client: Client,
    base_url: String,
    token: Option<String>,
}

impl RestClient {
    pub fn new(base_url: impl Into<String>) -> Self {
        Self {
            client: Client::new(),
            base_url: base_url.into().trim_end_matches('/').to_string(),
            token: None,
        }
    }

    pub fn with_token(mut self, token: impl Into<String>) -> Self {
        self.token = Some(token.into());
        self
    }

    fn url(&self, path: &str) -> String {
        format!("{}/{}", self.base_url, path.trim_start_matches('/'))
    }

    fn apply_auth(&self, req: reqwest::RequestBuilder) -> reqwest::RequestBuilder {
        match &self.token {
            Some(t) => req.bearer_auth(t),
            None => req,
        }
    }

    pub async fn get_json<T: DeserializeOwned>(&self, path: &str) -> Result<T, reqwest::Error> {
        let req = self.client.request(Method::GET, self.url(path));
        self.apply_auth(req).send().await?.error_for_status()?.json::<T>().await
    }

    pub async fn post_json<T: DeserializeOwned, B: Serialize>(
        &self,
        path: &str,
        body: &B,
    ) -> Result<T, reqwest::Error> {
        let req = self.client.request(Method::POST, self.url(path)).json(body);
        self.apply_auth(req).send().await?.error_for_status()?.json::<T>().await
    }

    pub async fn delete(&self, path: &str) -> Result<(), reqwest::Error> {
        let req = self.client.request(Method::DELETE, self.url(path));
        self.apply_auth(req).send().await?.error_for_status()?;
        Ok(())
    }
}

// ── Exemplo de uso ──
#[derive(serde::Serialize, serde::Deserialize)]
struct Usuario {
    id: u64,
    nome: String,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let api = RestClient::new("https://api.exemplo.com").with_token("SEU_TOKEN_AQUI");

    // GET com parsing JSON:
    let u: Usuario = api.get_json("usuarios/42").await?;
    println!("usuário: {} (id {})", u.nome, u.id);

    // POST com corpo JSON:
    let criado: Usuario = api
        .post_json("usuarios", &Usuario { id: 0, nome: "Ana".into() })
        .await?;
    println!("criado: {}", criado.nome);

    // DELETE:
    api.delete("usuarios/42").await?;
    Ok(())
}