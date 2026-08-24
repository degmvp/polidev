// wx-rs-013-wxrs.rs
// ════════════════════════════════════════════════════════
// Título: Utilitários de data/hora RFC 3339
// Para que serve: Parsing e formatação de datas ISO 8601 / RFC 3339 com fuso
// horário, além de cálculos comuns (idade, diferenças, epoch). Base para APIs
// e logs padronizados.
// Dependências (Cargo.toml): chrono = { version = "0.4", features = ["serde"] }
// ════════════════════════════════════════════════════════

use chrono::{DateTime, Duration, NaiveDate, Utc};

/// Parses an RFC 3339 / ISO 8601 string into UTC.
pub fn parse_rfc3339(input: &str) -> Option<DateTime<Utc>> {
    DateTime::parse_from_rfc3339(input)
        .ok()
        .map(|dt| dt.with_timezone(&Utc))
}

/// Formats a UTC `DateTime` as an RFC 3339 string.
pub fn to_rfc3339(dt: &DateTime<Utc>) -> String {
    dt.to_rfc3339()
}

/// Age in full years given a birth date (YYYY-MM-DD) and a reference date.
pub fn age_at(birth: &str, at: NaiveDate) -> Option<u32> {
    let birth = NaiveDate::parse_from_str(birth, "%Y-%m-%d").ok()?;
    let mut years = at.year() - birth.year();
    if at.ordinal() < birth.ordinal() {
        years -= 1;
    }
    (years >= 0).then_some(years as u32)
}

/// Returns the Unix timestamp (seconds) for a UTC datetime.
pub fn unix_seconds(dt: &DateTime<Utc>) -> i64 {
    dt.timestamp()
}

/// Adds a given number of days to a UTC datetime.
pub fn add_days(dt: &DateTime<Utc>, days: i64) -> DateTime<Utc> {
    *dt + Duration::days(days)
}

// ── Exemplo de uso ──
fn main() {
    let agora = Utc::now();
    println!("agora rfc3339: {}", to_rfc3339(&agora));
    println!("epoch s      : {}", unix_seconds(&agora));
    println!("+7 dias      : {}", to_rfc3339(&add_days(&agora, 7)));

    if let Some(idade) = age_at("1990-05-20", Utc::now().date_naive()) {
        println!("idade        : {idade} anos");
    }
}