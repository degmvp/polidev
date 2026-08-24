// wx-rs-018-wxrs.rs
// ════════════════════════════════════════════════════════
// Título: Cliente WebSocket com reconexão automática
// Para que serve: Conecta a um servidor WebSocket, envia/recebe mensagens e
// reconecta automaticamente em caso de queda, com backoff. Base para bots,
// streams e painéis em tempo real.
// Dependências (Cargo.toml): tokio = { version = "1", features = ["time", "macros", "rt-multi-thread"] },
//                             tokio-tungstenite = "0.24",
//                             futures-util = "0.3"
// ════════════════════════════════════════════════════════

use futures_util::{SinkExt, StreamExt};
use std::time::Duration;
use tokio::time::sleep;
use tokio_tungstenite::tungstenite::Message;
use tokio_tungstenite::{connect_async, MaybeTlsStream};

type WsStream = tokio_tungstenite::WebSocketStream<MaybeTlsStream<tokio::net::TcpStream>>;

/// Connects to `url` and echoes back every text message received.
/// Reconnects with exponential backoff when the connection drops.
pub async fn echo_loop(url: &str, reconnect_delay_ms: u64) -> Result<(), String> {
    let mut attempt = 0u64;
    loop {
        attempt += 1;
        match connect_async(url).await {
            Ok((ws, _)) => {
                let mut ws: WsStream = ws;
                println!("conectado (tentativa {attempt})");
                if let Err(e) = handle_session(&mut ws).await {
                    println!("sessão encerrada: {e}");
                }
                attempt = 0;
            }
            Err(e) => {
                println!("falha de conexão: {e}");
            }
        }
        // Backoff exponencial entre reconexões (limitado a ~2^6).
        let power = attempt.min(6) as u32 - 1;
        let delay = reconnect_delay_ms * 2u64.saturating_pow(power);
        println!("reconectando em {} ms...", delay);
        sleep(Duration::from_millis(delay)).await;
    }
}

/// Reads messages and echoes them back until the stream closes.
async fn handle_session(ws: &mut WsStream) -> Result<(), String> {
    while let Some(msg) = ws.next().await {
        let msg = msg.map_err(|e| e.to_string())?;
        match msg {
            Message::Text(text) => {
                println!("recebido: {text}");
                ws.send(Message::Text(format!("echo: {text}")))
                    .await
                    .map_err(|e| e.to_string())?;
            }
            Message::Close(_) => return Ok(()),
            _ => {}
        }
    }
    Ok(())
}

// ── Exemplo de uso ──
#[tokio::main]
async fn main() {
    // Em ambiente real, troque pela URL do seu servidor WebSocket.
    echo_loop("wss://echo.websocket.org", 1000).await.unwrap();
}