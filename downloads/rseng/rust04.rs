#!/bin/bash
# ==========================================================
# POLYDEV | Rust Engineering
# RUST04 — Traits: polimorfismo moderno.
# ==========================================================
#
# TECNOLOGIA:
# Rust (rustc)
#
# LINGUAGEM:
# Rust / Bash
#
# OBJETIVO:
# Implementar Traits (Interfaces) para definir comportamentos
# compartilhados entre tipos diferentes, permitindo
# polimorfismo estático (sem custo em tempo de execução).
#
# ATENÇÃO:
# No Rust, você implementa a Trait PARA o tipo (impl Trait for Tipo),
# diferente de outras linguagens onde o tipo herda da interface.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_rs && cd polydev_rs

cat > traits.rs << 'EOF'
// Define o contrato (Trait)
trait Auditoria {
    fn log_seguranca(&self);
    
    // Trait pode ter implementação padrão
    fn gerar_alerta(&self) {
        println!("[ALERTA PADRÃO] Ação registrada no sistema.");
    }
}

struct Usuario { nome: String, nivel: u8 }
struct Sistema { id: String }

// Implementa a Trait para Usuario
impl Auditoria for Usuario {
    fn log_seguranca(&self) {
        println!("[USUÁRIO] Acesso do usuario {} (Nivel {})", self.nome, self.nivel);
    }
}

// Implementa a Trait para Sistema
impl Auditoria for Sistema {
    fn log_seguranca(&self) {
        println!("[SISTEMA] Modulo {} inicializado.", self.id);
    }
}

// Função polimórfica: aceita qualquer coisa que implemente a Trait Auditoria
fn executar_auditoria(entidade: &impl Auditoria) {
    entidade.log_seguranca();
    entidade.gerar_alerta(); // Usa a implementação padrão
}

fn main() {
    let admin = Usuario { nome: String::from("Polydev"), nivel: 99 };
    let kernel = Sistema { id: String::from("CORE-v1") };

    executar_auditoria(&admin);
    executar_auditoria(&kernel);
}
EOF

rustc traits.rs -o traits_bin
./traits_bin

rm -f *.rs *_bin && cd .. && rmdir polydev_rs