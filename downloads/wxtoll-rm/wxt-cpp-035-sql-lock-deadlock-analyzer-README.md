# POLYDEV | WX-TOOLS | 035 | SQL Lock & Deadlock Analyzer

**Versão:** 1.1.0  
**Linguagem:** C++17  
**Plataforma:** Windows / Visual Studio 2022  
**Integração:** ODBC Driver 18 for SQL Server  
**Tipo:** diagnóstico somente leitura

## Descrição

Utilitário de linha de comando para diagnosticar locks, sessões, requisições bloqueadas e tarefas em espera no SQL Server. Consulta os relatórios históricos de deadlock da sessão Extended Events `system_health` (escopo de servidor) e apresenta os participantes, vítimas, comandos SQL, recursos, índices e relações entre processos. Também permite consultar o XML completo dos eventos.

## Arquivos padronizados

- Fonte: `wxt-cpp-035-sql-lock-deadlock-analyzer.cpp`
- Executável: `wxt-cpp-035-sql-lock-deadlock-analyzer.exe`
- Banner: `wxt-cpp-035-sql-lock-deadlock-analyzer.png`
- Documentação: `wxt-cpp-035-sql-lock-deadlock-analyzer-README.md`

## Comandos

| Comando | Finalidade |
|---|---|
| `locks` | Locks e recursos atualmente registrados |
| `blocking` | Requisições atualmente bloqueadas |
| `waits` | Tarefas e tipos de espera |
| `sessions` | Sessões e atividade atual |
| `deadlocks` | Resumo interpretado de deadlocks históricos |
| `deadlock-xml` | XML bruto dos eventos de deadlock |
| `health` | Diagnóstico consolidado dos comandos anteriores, exceto XML bruto |
| `--help` | Ajuda |
| `--version` | Versão |

## Execução no PowerShell

```powershell
& "E:\@LIB-C++\bin\wxt-cpp-035-sql-lock-deadlock-analyzer.exe" health --server ".\WSRV25" --db "WX_RECOVERY_LAB"
```

Para consultar apenas os deadlocks:

```powershell
& "E:\@LIB-C++\bin\wxt-cpp-035-sql-lock-deadlock-analyzer.exe" deadlocks --server ".\WSRV25" --db "WX_RECOVERY_LAB"
```

## Requisitos e segurança

- SQL Server acessível pela instância informada.
- ODBC Driver 18 for SQL Server instalado.
- Autenticação integrada do Windows (`Trusted_Connection=Yes`).
- Permissões de visualização das DMVs e eventos necessárias, conforme a versão/configuração do SQL Server.
- O programa consulta dados; **não encerra sessões, não altera transações e não modifica registros**.
- O histórico de deadlocks depende da retenção de eventos pelo `system_health`; não representa necessariamente todo o histórico do servidor.
- Os horários `utc_timestamp` são exibidos em UTC (`Z`).

## Homologação — 09/10/2026

Compilação confirmada no Visual Studio 2022. Testes reais executados na instância `.\WSRV25`, banco `WX_RECOVERY_LAB`. O comando `deadlocks` identificou dois eventos: um com vítima SPID 57 (participantes 57 e 73) e outro com vítima SPID 55 (participantes 55, 57 e 73), envolvendo a tabela `dbo.WX_Deadlock_Test` e bloqueios exclusivos de chaves. O comando `health` executou as consultas consolidadas, sem bloqueios ou tarefas em espera no momento do teste.

## Observação de publicação

O slug de todos os arquivos é `wxt-cpp-035-sql-lock-deadlock-analyzer`. Conferir a correspondência entre número, título e banner antes de publicar no catálogo POLYDEV.
