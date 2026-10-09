# POLYDEV | WX-TOOLS | C++ | 004 — System Monitor

## Visão geral

O **System Monitor** é uma ferramenta CLI em C++17 para inspecionar processos, discos, memória e arquivos de log em **Linux**. O código utiliza interfaces do sistema como `/proc`, `sysinfo` e `statvfs`.

**Fonte:** `wxt-cpp-004-system-monitor.cpp`  
**Banner:** `wxt-cpp-004-system-monitor.png`  
**Versão declarada no fonte:** 1.0.

## Recursos e comandos

| Comando | Finalidade | Opções |
|---|---|---|
| `procs` | Monitorar processos | `--sort cpu\|mem\|pid`, `--filter STR`, `--count N` |
| `disk` | Mostrar uso de disco e partições | `--path DIR`, `--all`, `--bytes` |
| `mem` | Mostrar RAM e swap | `--watch N`, `--bytes` |
| `logs` | Visualizar e filtrar logs | `--file PATH`, `--lines N`, `--filter STR`, `--follow` ou `-f` |

Opções globais: `--no-color` para desativar cores; `-h` ou `--help` para consultar a ajuda.

## Ambiente e compilação

Requer Linux com suporte às interfaces `/proc`, `sysinfo` e `statvfs`. Não é um programa Windows nativo, apesar de usar C++17.

No Ubuntu 24.04:

```bash
g++-13 -std=c++17 -O2 wxt-cpp-004-system-monitor.cpp -o wxt-cpp-004-system-monitor
```

## Exemplos de uso

```bash
./wxt-cpp-004-system-monitor --help
./wxt-cpp-004-system-monitor procs --sort mem --count 15
./wxt-cpp-004-system-monitor procs --filter python
./wxt-cpp-004-system-monitor disk --path /
./wxt-cpp-004-system-monitor disk --all
./wxt-cpp-004-system-monitor mem
./wxt-cpp-004-system-monitor mem --watch 5
./wxt-cpp-004-system-monitor logs --file /var/log/syslog --lines 30
./wxt-cpp-004-system-monitor logs --file /var/log/syslog --filter error --follow
./wxt-cpp-004-system-monitor disk --no-color
```

O caminho do log é apenas um exemplo: o arquivo deve existir no sistema e estar acessível ao usuário que executa o comando. Para encerrar os modos contínuos (`--watch` ou `--follow`), utilize **Ctrl+C**.

## Segurança e observações

- Os comandos de inspeção não foram projetados para modificar processos, discos ou memória.
- A leitura de determinados processos e logs pode exigir permissões específicas.
- O comando `logs` apenas lê arquivos de log; não realiza rotação ou exclusão.
- A disponibilidade dos dados depende do ambiente Linux e dos arquivos presentes.

---

**POLYDEV | WX-TOOLS | C++ | 004 — System Monitor**
