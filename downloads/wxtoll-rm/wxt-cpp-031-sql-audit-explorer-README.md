# POLYDEV \| WX-TOOLS \| 031 \| SQL Audit Explorer

**Arquivo:** `wxt-cpp-031-sql-audit-explorer.cpp`\
**Tecnologia:** C++17 + ODBC\
**Banco:** Microsoft SQL Server\
**Modo de operação:** somente leitura (read-only)

## Descrição

O **SQL Audit Explorer** é uma ferramenta de linha de comando da coleção
POLYDEV WX-TOOLS para consulta da trilha de auditoria do Microsoft SQL
Server.

A ferramenta permite inspecionar:

-   audits configurados no SQL Server;
-   status de execução dos audits;
-   especificações de auditoria no servidor;
-   especificações de auditoria no banco;
-   ações de auditoria disponíveis;
-   eventos capturados pela auditoria.

A operação é somente leitura.

## Sintaxe

``` cmd
wxt-cpp-031-sql-audit-explorer.exe <command> --server <server> [--db <database>]
```

## Comandos

### `audits`

Lista os SQL Server Audits configurados.

``` cmd
wxt-cpp-031-sql-audit-explorer.exe audits --server ".\WSRV25"
```

Na homologação, o audit exibido foi:

``` text
WX_AUDIT_031
```

com destino do tipo `FILE`.

### `status`

Mostra o status de execução dos audits.

``` cmd
wxt-cpp-031-sql-audit-explorer.exe status --server ".\WSRV25"
```

Entre as informações apresentadas estão:

-   `audit_id`
-   `name`
-   `status_desc`
-   `status_time`

### `server-spec`

Mostra as especificações de auditoria configuradas no nível do servidor.

``` cmd
wxt-cpp-031-sql-audit-explorer.exe server-spec --server ".\WSRV25"
```

Na homologação foi utilizada a especificação:

``` text
WX_SERVER_SPEC_031
```

### `db-spec`

Mostra as especificações de auditoria configuradas no banco informado.

``` cmd
wxt-cpp-031-sql-audit-explorer.exe db-spec --server ".\WSRV25" --db AdventureWorks2025
```

Na homologação foi utilizada a especificação:

``` text
WX_AUDIT_SPEC_031
```

O resultado demonstrado inclui ações como:

``` text
DELETE
INSERT
SELECT
UPDATE
```

### `actions`

Mostra as ações de auditoria disponíveis no SQL Server.

``` cmd
wxt-cpp-031-sql-audit-explorer.exe actions --server ".\WSRV25"
```

### `events`

Mostra os eventos capturados pela auditoria.

``` cmd
wxt-cpp-031-sql-audit-explorer.exe events --server ".\WSRV25" --db AdventureWorks2025
```

A saída demonstrada na homologação contém informações como:

-   `event_time`
-   `action_id`
-   `succeeded`
-   `login_name`
-   `database_name`
-   `schema_name`
-   `object_name`
-   `statement`

Foram demonstrados eventos de:

``` text
SELECT
INSERT
UPDATE
DELETE
```

## Opções

### `--server <server>`

Informa a instância do SQL Server.

Exemplo utilizado na homologação:

``` cmd
--server ".\WSRV25"
```

### `--db <database>`

Informa o banco de dados para os comandos que trabalham no contexto de
um database.

Exemplo utilizado na homologação:

``` cmd
--db AdventureWorks2025
```

## Exemplos rápidos

### Listar audits

``` cmd
wxt-cpp-031-sql-audit-explorer.exe audits --server ".\WSRV25"
```

### Consultar status

``` cmd
wxt-cpp-031-sql-audit-explorer.exe status --server ".\WSRV25"
```

### Consultar especificações do servidor

``` cmd
wxt-cpp-031-sql-audit-explorer.exe server-spec --server ".\WSRV25"
```

### Consultar especificações do banco

``` cmd
wxt-cpp-031-sql-audit-explorer.exe db-spec --server ".\WSRV25" --db AdventureWorks2025
```

### Consultar eventos capturados

``` cmd
wxt-cpp-031-sql-audit-explorer.exe events --server ".\WSRV25" --db AdventureWorks2025
```

## Ambiente demonstrado

``` text
SQL Server : .\WSRV25
Database   : AdventureWorks2025
Audit      : WX_AUDIT_031
Server Spec: WX_SERVER_SPEC_031
DB Spec    : WX_AUDIT_SPEC_031
```

## Segurança

O **SQL Audit Explorer** foi projetado para consulta da auditoria do SQL
Server em modo **read-only**.

Seu objetivo é permitir a inspeção das configurações e dos eventos de
auditoria sem modificar os objetos auditados.

## Arquivos do componente

Padrão POLYDEV:

``` text
wxt-cpp-031-sql-audit-explorer.cpp
wxt-cpp-031-sql-audit-explorer.exe
wxt-cpp-031-sql-audit-explorer.png
wxt-cpp-031-sql-audit-explorer-README.md
```

------------------------------------------------------------------------

**POLYDEV \| WX-TOOLS \| C++ \| 031 \| SQL Audit Explorer**
