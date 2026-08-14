/// RUST03 - Pipeline de Transformação de Dados
/// ==============================================
/// Encadeia funções de transformação em sequência,
/// criando pipelines funcionais e reutilizáveis.

pub struct Pipeline<T> {
    steps: Vec<(String, Box<dyn Fn(T) -> T>)>,
}

impl<T: 'static> Pipeline<T> {
    /// Cria um novo pipeline vazio.
    pub fn new() -> Self {
        Self { steps: Vec::new() }
    }

    /// Adiciona um passo ao pipeline.
    pub fn pipe<F>(mut self, name: &str, func: F) -> Self
    where
        F: Fn(T) -> T + 'static,
    {
        self.steps.push((name.to_string(), Box::new(func)));
        self
    }

    /// Executa o pipeline sobre os dados de entrada.
    pub fn execute(&self, mut data: T) -> T {
        for (name, func) in &self.steps {
            eprintln!("[pipeline] Executando passo: {}", name);
            data = func(data);
        }
        data
    }

    /// Retorna o número de passos no pipeline.
    pub fn len(&self) -> usize {
        self.steps.len()
    }

    /// Verifica se o pipeline está vazio.
    pub fn is_empty(&self) -> bool {
        self.steps.is_empty()
    }
}

/// Pipeline para Result<T, E> com tratamento de erros.
pub struct FalliblePipeline<T, E> {
    steps: Vec<(String, Box<dyn Fn(T) -> Result<T, E>>)>,
}

impl<T: 'static, E: 'static + std::fmt::Display> FalliblePipeline<T, E> {
    pub fn new() -> Self {
        Self { steps: Vec::new() }
    }

    pub fn pipe<F>(mut self, name: &str, func: F) -> Self
    where
        F: Fn(T) -> Result<T, E> + 'static,
    {
        self.steps.push((name.to_string(), Box::new(func)));
        self
    }

    /// Executa o pipeline, parando no primeiro erro.
    pub fn execute(&self, mut data: T) -> Result<T, String> {
        for (name, func) in &self.steps {
            match func(data) {
                Ok(result) => data = result,
                Err(e) => return Err(format!("Pipeline falhou em '{}': {}", name, e)),
            }
        }
        Ok(data)
    }
}

// ===================== EXEMPLO DE USO =====================
//
// fn main() {
//     // Pipeline simples com strings
//     let pipeline = Pipeline::new()
//         .pipe("trim", |s: String| s.trim().to_string())
//         .pipe("lowercase", |s: String| s.to_lowercase())
//         .pipe("remover_duplos", |s: String| {
//             s.split_whitespace().collect::<Vec<_>>().join(" ")
//         });
//
//     let resultado = pipeline.execute("  Olá   Mundo   RUST  ".to_string());
//     println!("{}", resultado);
//     // >>> "olá mundo rust"
//
//     // Pipeline com tratamento de erros
//     let safe_pipeline = FalliblePipeline::new()
//         .pipe("parse_int", |s: String| {
//             s.trim().parse::<i64>()
//                 .map(|n| n.to_string())
//                 .map_err(|e| e.to_string())
//         })
//         .pipe("dobrar", |s: String| {
//             let n: i64 = s.parse().unwrap();
//             Ok((n * 2).to_string())
//         });
//
//     match safe_pipeline.execute("  42  ".to_string()) {
//         Ok(r) => println!("Resultado: {}", r),  // >>> "84"
//         Err(e) => println!("Erro: {}", e),
//     }
// }
