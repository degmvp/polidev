#!/bin/bash
# ==========================================================
# POLYDEV | Rust Engineering
# RUST10 — Construindo software de alta performance.
# ==========================================================
#
# TECNOLOGIA:
# Rust (rustc)
#
# LINGUAGEM:
# Rust / Bash
#
# OBJETIVO:
# Unir todos os conceitos em um exemplo real de Engenharia:
# Concorrência sem Data Races usando Threads e Channels (MPSC).
# O compilador garante que a passagem de mensagens é segura.
#
# ATENÇÃO:
# Em linguagens como C++ ou Java, threads compartilham memória
// e você sofre com Deadlocks e Race Conditions. No Rust, a
// propriedade (Ownership) é transferida pelo Channel (tx -> rx),
// tornando a concorrência "Fearless" (Sem Medo).
#
# Leia • Entenda • Execute seu código
# ==========================================================

mkdir -p polydev_rs && cd polydev_rs

cat > concurrency.rs << 'EOF'
use std::thread;
use std::sync::mpsc; // Multiple Producer, Single Consumer
use std::time::Duration;

fn main() {
    // Cria um canal de comunicação (Transmissor, Receptor)
    let (tx, rx) = mpsc::channel();

    // Clona o transmissor para permitir múltiplas threads enviando dados
    let tx1 = tx.clone();
    let tx2 = tx.clone();

    // THREAD 1: Produtor de Logs Rápidos
    thread::spawn(move || {
        let payloads = vec!["Auth_Login", "Auth_Logout", "Token_Refresh"];
        for log in payloads {
            tx1.send(log.to_string()).unwrap();
            thread::sleep(Duration::from_millis(50));
        }
    });

    // THREAD 2: Produtor de Relatórios Lentos
    thread::spawn(move || {
        let relatorios = vec!["Relatorio_Financeiro", "Relatorio_Vendas"];
        for rel in relatorios {
            tx2.send(rel.to_string()).unwrap();
            thread::sleep(Duration::from_millis(150));
        }
    });

    // THREAD PRINCIPAL: Consumidor (Receptor)
    // Como o tx original e os clones foram movidos (move) para as threads,
    // o loop abaixo saberá EXATAMENTE quando todas as threads morreram,
    // pois o canal será fechado automaticamente pelo Rust.
    println!("Iniciando consumo de dados...");
    for recebido in rx {
        println!("[CONSUMIDO] {}", recebido);
    }
    
    println!("Canal fechado. Todas as threads terminaram com segurança.");
}
EOF

rustc concurrency.rs -o concurrency_bin
./concurrency_bin

rm -f *.rs *_bin && cd .. && rmdir polydev_rs