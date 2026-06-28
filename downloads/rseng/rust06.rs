#!/bin/bash
# ==========================================================
# POLYDEV | Rust Engineering
# RUST06 — Pattern Matching profissional.
# ==========================================================
#
# TECNOLOGIA:
# Rust (rustc)
#
# LINGUAGEM:
# Rust / Bash
#
# OBJETIVO:
# Demonstrar o uso avançado do `match` com desestruturação
# profunda, guards (condições extras) e binds (@) para
# substituir árvores complexas de if/else if.
#
# ATENÇÃO:
# O compilador exige que o match seja exaustivo (trate todos
# os casos possíveis). Isso impede bugs de lógica em tempo
# de compilação.
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_rs && cd polydev_rs

cat > pattern.rs << 'EOF'
enum EventoRede {
    Conexao { ip: String, porta: u16 },
    Dados(Vec<u8>),
    Erro { codigo: i32, msg: String },
    Desconectado,
}

fn processar_evento(evento: EventoRede) {
    match evento {
        // Desestruturação e guarda (if)
        EventoRede::Conexao { ip, porta } if porta == 443 => {
            println!("[SEGURANÇA] Conexão segura de {}", ip);
        }
        EventoRede::Conexao { ip, porta } => {
            println!("[ALERTA] Conexão insegura na porta {} de {}", porta, ip);
        }
        // Bind (@): Captura o valor e ao mesmo tempo testa um padrão
        EventoRede::Erro { codigo: codigo_erro @ 404..=499, msg } => {
            println!("[CLIENTE] Erro {} - {}", codigo_erro, msg);
        }
        EventoRede::Erro { codigo: 500..=599, .. } => {
            println!("[SERVIDOR] Erro Interno!");
        }
        // Ignora dados complexos com ..
        EventoRede::Dados(_) => println!("Pacote de dados recebido."),
        
        EventoRede::Desconectado => println!("Sessão encerrada."),
    }
}

fn main() {
    processar_evento(EventoRede::Conexao { ip: "192.168.1.1".to_string(), porta: 80 });
    processar_evento(EventoRede::Erro { codigo: 404, msg: "Not Found".to_string() });
    processar_evento(EventoRede::Erro { codigo: 500, msg: "Internal".to_string() });
}
EOF

rustc pattern.rs -o pattern_bin
./pattern_bin

rm -f *.rs *_bin && cd .. && rmdir polydev_rs