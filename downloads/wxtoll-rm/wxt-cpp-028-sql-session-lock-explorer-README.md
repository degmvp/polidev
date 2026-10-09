# POLYDEV \| WX-TOOLS \| 028 \| SQL Session & Lock Explorer

**Arquivo:** `wxt-cpp-028-sql-session-lock-explorer.cpp`\
**Versão demonstrada:** `1.0.0`\
**Banco:** Microsoft SQL Server\
**Status:** homologado

## Descrição

O **SQL Session & Lock Explorer** é uma ferramenta da coleção POLYDEV
WX-TOOLS para explorar sessões, requests, bloqueios, locks e waits do
SQL Server pela linha de comando.

O banner de homologação demonstra os comandos:

-   `summary`
-   `active`
-   `sessions`
-   `blockers`
-   `locks`
-   `waits`

Também demonstra `--version` e tratamento defensivo de comando inválido.

## Versão

``` cmd
wxt-cpp-028-sql-session-lock-explorer.exe --version
```

Saída demonstrada:

``` text
wxt-cpp-028-sql-session-lock-explorer 1.0.0
```

## Sintaxe utilizada nos testes

``` cmd
wxt-cpp-028-sql-session-lock-explorer.exe <command> --server .\WSRV25 --db WX_RECOVERY_LAB
```

## `summary`

Apresenta um resumo da atividade do servidor e informações da conexão
atual.

``` cmd
wxt-cpp-028-sql-session-lock-explorer.exe summary --server .\WSRV25 --db WX_RECOVERY_LAB
```

### SERVER ACTIVITY SUMMARY

O banner demonstra:

-   `user_sessions`
-   `active_requests`
-   `blocked_requests`
-   `blocker_sessions`
-   `waiting_locks`

### CURRENT CONNECTION

Apresenta informações como:

-   `session_id`
-   `database_name`
-   `original_login`
-   `host_name`
-   `program_name`

## `active`

Mostra os requests ativos.

``` cmd
wxt-cpp-028-sql-session-lock-explorer.exe active --server .\WSRV25 --db WX_RECOVERY_LAB
```

A seção apresentada é:

``` text
ACTIVE REQUESTS
```

Na captura de homologação não havia requests ativos no momento da
consulta, resultando em:

``` text
(no rows)
```

## `sessions`

Lista as sessões de usuário.

``` cmd
wxt-cpp-028-sql-session-lock-explorer.exe sessions --server .\WSRV25 --db WX_RECOVERY_LAB
```

A seção **USER SESSIONS** demonstra informações como:

-   `session_id`
-   `status`
-   `login_name`
-   `host_name`
-   `program_name`
-   `client_interface_name`
-   `database_name`
-   `cpu_time`
-   `memory_usage`
-   `reads`
-   `writes`
-   `logical_reads`
-   `open_transaction_count`
-   `login_time`
-   horários dos últimos requests

## `blockers`

Examina cadeias de bloqueio.

``` cmd
wxt-cpp-028-sql-session-lock-explorer.exe blockers --server .\WSRV25 --db WX_RECOVERY_LAB
```

A seção apresentada é:

``` text
BLOCKING CHAINS
```

Na captura de homologação não havia cadeia de bloqueio ativa:

``` text
(no rows)
```

## `locks`

Mostra os locks ativos.

``` cmd
wxt-cpp-028-sql-session-lock-explorer.exe locks --server .\WSRV25 --db WX_RECOVERY_LAB
```

A seção **ACTIVE LOCKS** demonstra informações como:

-   `session_id`
-   `database_name`
-   `resource_type`
-   `resource_subtype`
-   `request_mode`
-   `request_status`
-   `request_owner_type`
-   `object_name`
-   `resource_description`

## `waits`

Mostra requests/waits observados no SQL Server.

``` cmd
wxt-cpp-028-sql-session-lock-explorer.exe waits --server .\WSRV25 --db WX_RECOVERY_LAB
```

A seção **REQUEST WAITS** demonstra informações como:

-   `session_id`
-   `wait_duration_ms`
-   `wait_type`
-   `blocking_session_id`
-   `resource_description`
-   `status`
-   `database_name`
-   `command`
-   `cpu_time`
-   `total_elapsed_time`
-   `wait_resource`

## Tratamento de comando inválido

A ferramenta rejeita comandos desconhecidos.

Exemplo demonstrado:

``` cmd
wxt-cpp-028-sql-session-lock-explorer.exe banana --server .\WSRV25 --db WX_RECOVERY_LAB
```

Resultado:

``` text
wxt-cpp-028-sql-session-lock-explorer: error: unknown command: banana
```

## Sequência rápida de diagnóstico

``` cmd
wxt-cpp-028-sql-session-lock-explorer.exe summary --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-028-sql-session-lock-explorer.exe active --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-028-sql-session-lock-explorer.exe sessions --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-028-sql-session-lock-explorer.exe blockers --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-028-sql-session-lock-explorer.exe locks --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-028-sql-session-lock-explorer.exe waits --server .\WSRV25 --db WX_RECOVERY_LAB
```

## Registro demonstrado no SYS_TOOLS

O banner registra a ferramenta com:

``` text
tool_id     : 028
tool_name   : wxt-cpp-028-sql-session-lock-explorer
category    : SQL
description : Explora sessões, requests, bloqueios, locks e waits do SQL Server.
```

Também demonstra a confirmação do registro por consulta ao
`dbo.SYS_TOOLS`.

## Ambiente demonstrado

``` text
SQL Server : .\WSRV25
Database   : WX_RECOVERY_LAB
```

## Arquivo em produção

O banner demonstra o executável:

``` text
E:\@LIB-C++\bin\wxt-cpp-028-sql-session-lock-explorer.exe
```

## Homologação

Conforme o banner:

``` text
Compilação OK
Todos os comandos funcionais
Registro no SYS_TOOLS OK (tool_id = '028')
Executável em produção OK
Pronto para uso
```

## Arquivos do componente

Padrão POLYDEV:

``` text
wxt-cpp-028-sql-session-lock-explorer.cpp
wxt-cpp-028-sql-session-lock-explorer.exe
wxt-cpp-028-sql-session-lock-explorer.png
wxt-cpp-028-sql-session-lock-explorer-README.md
```

------------------------------------------------------------------------

**POLYDEV \| WX-TOOLS \| 028 \| SQL SESSION & LOCK EXPLORER**
