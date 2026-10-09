# POLYDEV | WX-TOOLS | C++ | 005 — NetTools

## Visão geral

O **NetTools v1.0** é um utilitário de linha de comando em **C++17** para diagnóstico e varredura de rede em Linux.

A ferramenta reúne scanner de portas TCP com multi-threading, ping múltiplo em paralelo, consultas DNS e listagem de interfaces de rede, com saída colorida e objetiva no terminal.

## Principais recursos

- Scanner de portas TCP com multi-threading.
- Ping múltiplo em paralelo.
- DNS lookup completo.
- Consultas A, CNAME, MX, NS e TXT.
- Listagem de interfaces de rede.
- Cores ANSI no terminal.
- Barra de progresso.
- Código C++17 leve e eficiente.
- Sem dependências externas.

## Subcomandos

| Comando | Descrição |
|---|---|
| `scan` | Escaneia portas TCP de um host usando conexão direta |
| `ping` | Executa ping em múltiplos hosts em paralelo com estatísticas |
| `dns` | Executa DNS lookup completo — A, CNAME, MX, NS e TXT |
| `ifaces` | Lista interfaces de rede, status e endereços |

## Opções globais

| Opção | Descrição |
|---|---|
| `--no-color` | Desabilita cores ANSI no terminal |
| `-h`, `--help` | Exibe a mensagem de ajuda |

## Scanner TCP

O comando `scan` utiliza sockets não bloqueantes com `select()` para controlar o timeout e executa a análise com múltiplas threads.

```text
nettools scan [opções]
```

### Opções do scan

| Opção | Padrão | Descrição |
|---|---:|---|
| `-h HOST` | `127.0.0.1` | Host alvo, IP ou domínio |
| `-s PORT` | `1` | Porta inicial |
| `-e PORT` | `1024` | Porta final |
| `-t THREADS` | `50` | Número de threads |
| `-T TIMEOUT` | `500` | Timeout em milissegundos |

## Exemplos

### Escanear portas de um host

```text
nettools scan -h 192.168.0.1 -s 1 -e 100
```

Exemplo de resultado:

```text
Scan de portas TCP - 192.168.0.1
Threads: 50 | Timeout: 500 ms

PORTA    ESTADO    SERVIÇO
22       open      ssh
80       open      http
443      open      https
3306     closed
8080     closed
```

### Ping em múltiplos hosts

```text
nettools ping 192.168.0.1 8.8.8.8
```

### DNS lookup

```text
nettools dns exemplo.com
```

### Listar interfaces de rede

```text
nettools ifaces
```

## Aplicações

O NetTools é indicado para:

- administradores de rede;
- profissionais de TI e segurança;
- diagnóstico de conectividade;
- identificação de serviços acessíveis;
- testes em ambientes Linux e servidores;
- estudos e aprendizado de redes.

## Segurança e uso responsável

O scanner deve ser utilizado somente em hosts, redes e ambientes próprios ou para os quais exista autorização de teste.

## Tecnologia

```text
Linguagem : C++17
Plataforma: Linux
Tipo      : Aplicação de linha de comando
Versão    : 1.0
```

## Filosofia

**Conectividade revela oportunidades.**

O WX-TOOLS 005 concentra tarefas comuns de diagnóstico de rede em um utilitário pequeno, direto e eficiente.

---

**POLYDEV | WX-TOOLS | C++ | 005 — NetTools v1.0**  
*Ferramentas reais para desenvolvedores reais.*
