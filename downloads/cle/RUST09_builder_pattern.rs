/// RUST09 - Builder Pattern Genérico com Validação
/// ==================================================
/// Implementação robusta do padrão Builder com validação
/// em tempo de compilação e runtime. Ideal para construir
/// structs complexas com muitos campos opcionais.

use std::fmt;

#[derive(Debug)]
pub struct BuildError {
    pub field: String,
    pub message: String,
}

impl fmt::Display for BuildError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "BuildError [{}]: {}", self.field, self.message)
    }
}

/// Macro para gerar builders automaticamente.
/// Uso: define struct + builder com validação.
#[macro_export]
macro_rules! buildable {
    (
        $(#[$meta:meta])*
        pub struct $name:ident {
            // Campos obrigatórios
            required {
                $( $(#[$req_meta:meta])* $req_field:ident : $req_type:ty ),* $(,)?
            }
            // Campos opcionais com defaults
            optional {
                $( $(#[$opt_meta:meta])* $opt_field:ident : $opt_type:ty = $default:expr ),* $(,)?
            }
        }
    ) => {
        $(#[$meta])*
        #[derive(Debug, Clone)]
        pub struct $name {
            $( $(#[$req_meta])* pub $req_field: $req_type, )*
            $( $(#[$opt_meta])* pub $opt_field: $opt_type, )*
        }

        paste::paste! {
            pub struct [< $name Builder >] {
                $( $req_field: Option<$req_type>, )*
                $( $opt_field: $opt_type, )*
                validators: Vec<Box<dyn Fn(&$name) -> Result<(), BuildError>>>,
            }

            impl [< $name Builder >] {
                pub fn new() -> Self {
                    Self {
                        $( $req_field: None, )*
                        $( $opt_field: $default, )*
                        validators: Vec::new(),
                    }
                }

                $(
                    pub fn $req_field(mut self, value: $req_type) -> Self {
                        self.$req_field = Some(value);
                        self
                    }
                )*

                $(
                    pub fn $opt_field(mut self, value: $opt_type) -> Self {
                        self.$opt_field = value;
                        self
                    }
                )*

                pub fn validate<F>(mut self, validator: F) -> Self
                where
                    F: Fn(&$name) -> Result<(), BuildError> + 'static,
                {
                    self.validators.push(Box::new(validator));
                    self
                }

                pub fn build(self) -> Result<$name, Vec<BuildError>> {
                    let mut errors = Vec::new();

                    $(
                        if self.$req_field.is_none() {
                            errors.push(BuildError {
                                field: stringify!($req_field).to_string(),
                                message: "Campo obrigatório não definido".to_string(),
                            });
                        }
                    )*

                    if !errors.is_empty() {
                        return Err(errors);
                    }

                    let instance = $name {
                        $( $req_field: self.$req_field.unwrap(), )*
                        $( $opt_field: self.$opt_field, )*
                    };

                    for validator in &self.validators {
                        if let Err(e) = validator(&instance) {
                            errors.push(e);
                        }
                    }

                    if errors.is_empty() {
                        Ok(instance)
                    } else {
                        Err(errors)
                    }
                }
            }
        }
    };
}

// ======= Versão sem macro (uso direto) =======

#[derive(Debug, Clone)]
pub struct ServerConfig {
    pub host: String,
    pub port: u16,
    pub max_connections: u32,
    pub timeout_secs: u64,
    pub tls_enabled: bool,
    pub log_level: String,
}

pub struct ServerConfigBuilder {
    host: Option<String>,
    port: Option<u16>,
    max_connections: u32,
    timeout_secs: u64,
    tls_enabled: bool,
    log_level: String,
}

impl ServerConfigBuilder {
    pub fn new() -> Self {
        Self {
            host: None,
            port: None,
            max_connections: 100,
            timeout_secs: 30,
            tls_enabled: false,
            log_level: "info".to_string(),
        }
    }

    pub fn host(mut self, host: &str) -> Self { self.host = Some(host.to_string()); self }
    pub fn port(mut self, port: u16) -> Self { self.port = Some(port); self }
    pub fn max_connections(mut self, n: u32) -> Self { self.max_connections = n; self }
    pub fn timeout_secs(mut self, t: u64) -> Self { self.timeout_secs = t; self }
    pub fn tls(mut self, enabled: bool) -> Self { self.tls_enabled = enabled; self }
    pub fn log_level(mut self, level: &str) -> Self { self.log_level = level.to_string(); self }

    pub fn build(self) -> Result<ServerConfig, Vec<BuildError>> {
        let mut errors = Vec::new();

        if self.host.is_none() {
            errors.push(BuildError { field: "host".into(), message: "Host é obrigatório".into() });
        }
        if self.port.is_none() {
            errors.push(BuildError { field: "port".into(), message: "Port é obrigatório".into() });
        }
        if let Some(ref host) = self.host {
            if host.is_empty() {
                errors.push(BuildError { field: "host".into(), message: "Host não pode ser vazio".into() });
            }
        }
        if let Some(port) = self.port {
            if port == 0 {
                errors.push(BuildError { field: "port".into(), message: "Port deve ser > 0".into() });
            }
        }

        if !errors.is_empty() {
            return Err(errors);
        }

        Ok(ServerConfig {
            host: self.host.unwrap(),
            port: self.port.unwrap(),
            max_connections: self.max_connections,
            timeout_secs: self.timeout_secs,
            tls_enabled: self.tls_enabled,
            log_level: self.log_level,
        })
    }
}

// ===================== EXEMPLO DE USO =====================
//
// fn main() {
//     let config = ServerConfigBuilder::new()
//         .host("0.0.0.0")
//         .port(8080)
//         .max_connections(500)
//         .timeout_secs(60)
//         .tls(true)
//         .log_level("debug")
//         .build();
//
//     match config {
//         Ok(cfg) => println!("Servidor configurado: {:?}", cfg),
//         Err(erros) => {
//             for e in erros {
//                 println!("Erro: {}", e);
//             }
//         }
//     }
//     // >>> Servidor configurado: ServerConfig { host: "0.0.0.0", port: 8080, ... }
// }
