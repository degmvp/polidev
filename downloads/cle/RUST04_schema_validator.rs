/// RUST04 - Validador de Esquema (Schema Validator)
/// ===================================================
/// Valida estruturas de dados contra regras definidas.
/// Sem dependências externas. Útil para validar configs,
/// payloads de API e formulários.

use std::collections::HashMap;

#[derive(Debug, Clone)]
pub struct ValidationError {
    pub field: String,
    pub message: String,
}

impl std::fmt::Display for ValidationError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "[{}] {}", self.field, self.message)
    }
}

#[derive(Clone)]
pub enum FieldType {
    Str,
    Int,
    Float,
    Bool,
}

#[derive(Clone)]
pub struct FieldRule {
    pub field_type: FieldType,
    pub required: bool,
    pub min_length: Option<usize>,
    pub max_length: Option<usize>,
    pub min_value: Option<f64>,
    pub max_value: Option<f64>,
    pub choices: Option<Vec<String>>,
    pub pattern: Option<String>,
}

impl Default for FieldRule {
    fn default() -> Self {
        Self {
            field_type: FieldType::Str,
            required: true,
            min_length: None,
            max_length: None,
            min_value: None,
            max_value: None,
            choices: None,
            pattern: None,
        }
    }
}

impl FieldRule {
    pub fn string() -> Self {
        Self { field_type: FieldType::Str, ..Default::default() }
    }
    pub fn integer() -> Self {
        Self { field_type: FieldType::Int, ..Default::default() }
    }
    pub fn float() -> Self {
        Self { field_type: FieldType::Float, ..Default::default() }
    }
    pub fn boolean() -> Self {
        Self { field_type: FieldType::Bool, ..Default::default() }
    }
    pub fn optional(mut self) -> Self { self.required = false; self }
    pub fn min_len(mut self, n: usize) -> Self { self.min_length = Some(n); self }
    pub fn max_len(mut self, n: usize) -> Self { self.max_length = Some(n); self }
    pub fn min_val(mut self, n: f64) -> Self { self.min_value = Some(n); self }
    pub fn max_val(mut self, n: f64) -> Self { self.max_value = Some(n); self }
    pub fn choices_list(mut self, c: Vec<&str>) -> Self {
        self.choices = Some(c.into_iter().map(String::from).collect());
        self
    }
}

pub struct SchemaValidator {
    rules: HashMap<String, FieldRule>,
}

impl SchemaValidator {
    pub fn new() -> Self {
        Self { rules: HashMap::new() }
    }

    /// Adiciona uma regra de campo ao esquema.
    pub fn field(mut self, name: &str, rule: FieldRule) -> Self {
        self.rules.insert(name.to_string(), rule);
        self
    }

    /// Valida um HashMap de dados contra o esquema.
    pub fn validate(&self, data: &HashMap<String, String>) -> Result<(), Vec<ValidationError>> {
        let mut errors = Vec::new();

        for (field_name, rule) in &self.rules {
            match data.get(field_name) {
                None if rule.required => {
                    errors.push(ValidationError {
                        field: field_name.clone(),
                        message: "Campo obrigatório ausente".to_string(),
                    });
                }
                None => continue,
                Some(value) => {
                    // Validar tipo
                    match rule.field_type {
                        FieldType::Int => {
                            if value.parse::<i64>().is_err() {
                                errors.push(ValidationError {
                                    field: field_name.clone(),
                                    message: "Esperado um número inteiro".to_string(),
                                });
                                continue;
                            }
                        }
                        FieldType::Float => {
                            if value.parse::<f64>().is_err() {
                                errors.push(ValidationError {
                                    field: field_name.clone(),
                                    message: "Esperado um número decimal".to_string(),
                                });
                                continue;
                            }
                        }
                        FieldType::Bool => {
                            if !["true", "false", "1", "0"].contains(&value.as_str()) {
                                errors.push(ValidationError {
                                    field: field_name.clone(),
                                    message: "Esperado true/false".to_string(),
                                });
                                continue;
                            }
                        }
                        FieldType::Str => {}
                    }

                    // Comprimento
                    if let Some(min) = rule.min_length {
                        if value.len() < min {
                            errors.push(ValidationError {
                                field: field_name.clone(),
                                message: format!("Comprimento mínimo: {}", min),
                            });
                        }
                    }
                    if let Some(max) = rule.max_length {
                        if value.len() > max {
                            errors.push(ValidationError {
                                field: field_name.clone(),
                                message: format!("Comprimento máximo: {}", max),
                            });
                        }
                    }

                    // Valores numéricos
                    if let Some(min) = rule.min_value {
                        if let Ok(n) = value.parse::<f64>() {
                            if n < min {
                                errors.push(ValidationError {
                                    field: field_name.clone(),
                                    message: format!("Valor mínimo: {}", min),
                                });
                            }
                        }
                    }
                    if let Some(max) = rule.max_value {
                        if let Ok(n) = value.parse::<f64>() {
                            if n > max {
                                errors.push(ValidationError {
                                    field: field_name.clone(),
                                    message: format!("Valor máximo: {}", max),
                                });
                            }
                        }
                    }

                    // Choices
                    if let Some(ref choices) = rule.choices {
                        if !choices.contains(value) {
                            errors.push(ValidationError {
                                field: field_name.clone(),
                                message: format!("Deve ser um de: {:?}", choices),
                            });
                        }
                    }
                }
            }
        }

        if errors.is_empty() { Ok(()) } else { Err(errors) }
    }
}

// ===================== EXEMPLO DE USO =====================
//
// fn main() {
//     let validator = SchemaValidator::new()
//         .field("nome", FieldRule::string().min_len(2).max_len(100))
//         .field("idade", FieldRule::integer().min_val(0.0).max_val(150.0))
//         .field("role", FieldRule::string().choices_list(vec!["admin", "user"]))
//         .field("bio", FieldRule::string().optional());
//
//     let mut dados = HashMap::new();
//     dados.insert("nome".into(), "Maria Silva".into());
//     dados.insert("idade".into(), "28".into());
//     dados.insert("role".into(), "admin".into());
//
//     match validator.validate(&dados) {
//         Ok(()) => println!("Dados válidos!"),
//         Err(erros) => {
//             for e in erros {
//                 println!("Erro: {}", e);
//             }
//         }
//     }
// }
