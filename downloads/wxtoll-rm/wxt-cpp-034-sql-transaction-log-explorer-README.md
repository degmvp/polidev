# POLYDEV | WX-TOOLS | 034 — SQL Transaction Log Explorer

## Visão geral

Utilitário de diagnóstico em **C++17 + ODBC** para inspecionar o log de transações de um banco no SQL Server. Os comandos consultam DMVs e metadados, sem executar `ALTER DATABASE`, `DBCC SHRINKFILE`, `BACKUP` ou recuperação automática.

- **Fonte:** `wxt-cpp-034-sql-transaction-log-explorer.cpp`
- **Executável:** `wxt-cpp-034-sql-transaction-log-explorer.exe`
- **Banner:** `wxt-cpp-034-sql-transaction-log-explorer.png`
- **Versão:** 1.0.0
- **Ambiente homologado funcionalmente:** Windows 11, Visual Studio 2022, SQL Server 2025, instância `.\WSRV25`, banco `WX_RECOVERY_LAB`.

## Requisitos

- Windows e compilador com suporte a C++17 (Visual Studio 2022).
- Microsoft ODBC Driver 18 for SQL Server.
- Acesso à instância SQL Server e permissões suficientes para consultar as DMVs usadas (as permissões exigidas podem variar por versão do servidor).
- Autenticação integrada do Windows por padrão; o programa também aceita `--user` e `--password` (evite senha literal na linha de comando em ambientes compartilhados).

## Compilação

No projeto do Visual Studio 2022, incluir o `.cpp`, habilitar `/std:c++17`, `/EHsc` e `/utf-8`. O fonte inclui `#pragma comment(lib, "odbc32.lib")`. Configure a saída para `wxt-cpp-034-sql-transaction-log-explorer.exe`.

## Sintaxe

```powershell
& "E:\@LIB-C++\bin\wxt-cpp-034-sql-transaction-log-explorer.exe" <comando> --server ".\WSRV25" --db "WX_RECOVERY_LAB"
```

## Comandos

| Comando | Descrição |
|---|---|
| `status` | Espaço total, utilizado, percentual de uso e log gerado desde o último backup conforme DMV. |
| `vlf` | Resumo e mapa dos Virtual Log Files, incluindo tamanhos e estados. |
| `reuse` | Recovery model, estado do banco e motivo de espera para reutilização do log. |
| `transactions` | Transações de banco retornadas pelas DMVs, com dados de sessão quando disponíveis. |
| `growth` | Tamanho, limite máximo e configuração de autogrowth do arquivo de log; não é histórico de eventos de crescimento. |
| `health` | Executa as consultas consolidadas de status, VLF, reuse, transactions e growth e exibe orientação geral. |

## Exemplos

```powershell
$exe = "E:\@LIB-C++\bin\wxt-cpp-034-sql-transaction-log-explorer.exe"
& $exe --version
& $exe status --server ".\WSRV25" --db "WX_RECOVERY_LAB"
& $exe vlf --server ".\WSRV25" --db "WX_RECOVERY_LAB"
& $exe reuse --server ".\WSRV25" --db "WX_RECOVERY_LAB"
& $exe transactions --server ".\WSRV25" --db "WX_RECOVERY_LAB"
& $exe growth --server ".\WSRV25" --db "WX_RECOVERY_LAB"
& $exe health --server ".\WSRV25" --db "WX_RECOVERY_LAB"
```

## Resultados observados na homologação

| Indicador | Resultado no momento do teste |
|---|---|
| Log total | 135,99 MB |
| Log utilizado | 39,19 MB (28,82%) |
| VLFs | 6 (1 ativo e 5 inativos) |
| `log_reuse_wait_desc` | `NOTHING` |
| Transações retornadas | Nenhuma linha |
| Arquivo de log | `WX_RECOVERY_LAB_log.ldf`, 136 MB |
| Autogrowth | 64 MB fixos |

Esses valores são uma **amostra do ambiente de teste**, não valores constantes do programa nem garantia de saúde futura. `NOTHING` não significa que todo o espaço possa ser liberado imediatamente. O `health` apresenta dados e orientação geral; não aplica correções automáticas.

## Segurança e limitações

A ferramenta faz consultas de diagnóstico e não altera dados ou configuração persistente do banco. Não executa operações de backup, truncamento ou redução de log. A ausência de transações na saída significa apenas que nenhuma linha foi retornada pelos critérios da consulta naquele instante. Recomendações de administração devem ser validadas separadamente pelo DBA.

## Homologação

Os seis comandos (`status`, `vlf`, `reuse`, `transactions`, `growth` e `health`) foram executados no `WX_RECOVERY_LAB` com saídas coerentes. Publicação no GitHub e registro no Supabase devem ser confirmados separadamente.
