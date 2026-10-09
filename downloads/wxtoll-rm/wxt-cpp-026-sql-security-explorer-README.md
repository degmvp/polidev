# POLYDEV \| WX-TOOLS \| 026 \| SQL Security Explorer

**Arquivo:** `wxt-cpp-026-sql-security-explorer.cpp`\
**Versão demonstrada:** `1.0.0`\
**Banco:** Microsoft SQL Server

## Descrição

O **SQL Security Explorer** é uma ferramenta da coleção POLYDEV WX-TOOLS
para inspeção da segurança de bancos SQL Server pela linha de comando.

O banner de homologação demonstra consultas de resumo de segurança,
usuários, roles, permissões explícitas, segurança de objetos e
candidatos a usuários órfãos.

Comandos demonstrados:

-   `summary`
-   `users`
-   `roles`
-   `permissions <user>`
-   `object <schema.object>`
-   `orphans`

Também são demonstrados `--version` e o tratamento de objeto
inexistente.

## Versão

``` cmd
wxt-cpp-026-sql-security-explorer.exe --version
```

Saída demonstrada:

``` text
wxt-cpp-026-sql-security-explorer 1.0.0
```

## Sintaxe utilizada nos testes

``` cmd
wxt-cpp-026-sql-security-explorer.exe <command> [argument] --server .\WSRV25 --db WX_RECOVERY_LAB
```

## `summary`

Apresenta um resumo dos principals de segurança do banco.

``` cmd
wxt-cpp-026-sql-security-explorer.exe summary --server .\WSRV25 --db WX_RECOVERY_LAB
```

A seção **SECURITY SUMMARY** agrupa os principals por tipo, incluindo no
exemplo:

-   `DATABASE_USER`
-   `DATABASE_ROLE`
-   `APPLICATION_ROLE`
-   `WINDOWS_GROUP`
-   `WINDOWS_USER`

## `users`

Lista os usuários do banco.

``` cmd
wxt-cpp-026-sql-security-explorer.exe users --server .\WSRV25 --db WX_RECOVERY_LAB
```

A seção **DATABASE USERS** demonstra informações como:

-   `principal_id`
-   `user_name`
-   `type_desc`
-   `authentication_type_desc`
-   `orphan_candidate`
-   `create_date`
-   `modify_date`

No ambiente demonstrado aparece o usuário:

``` text
WX_TEST_USER
```

## `roles`

Mostra os membros das roles do banco.

``` cmd
wxt-cpp-026-sql-security-explorer.exe roles --server .\WSRV25 --db WX_RECOVERY_LAB
```

A seção **DATABASE ROLE MEMBERSHIP** apresenta:

-   `role_name`
-   `member_name`
-   `member_type`
-   `authentication_type`

O banner demonstra, entre outros, `WX_TEST_USER` como membro de:

``` text
db_datareader
```

## `permissions <user>`

Mostra as permissões explícitas de um usuário e suas associações a
roles.

``` cmd
wxt-cpp-026-sql-security-explorer.exe permissions WX_TEST_USER --server .\WSRV25 --db WX_RECOVERY_LAB
```

### EXPLICIT PERMISSIONS

A saída demonstrada inclui:

-   `principal_name`
-   `principal_type`
-   `state_desc`
-   `permission_name`
-   `class_desc`
-   `securable`
-   `column_name`

No exemplo de homologação, `WX_TEST_USER` possui permissões demonstradas
como:

``` text
GRANT CONNECT
GRANT SELECT
```

### ROLE MEMBERSHIP

Também é apresentada a associação:

``` text
db_datareader
```

## `object <schema.object>`

Examina as permissões explícitas aplicadas a um objeto.

``` cmd
wxt-cpp-026-sql-security-explorer.exe object dbo.DadosTeste --server .\WSRV25 --db WX_RECOVERY_LAB
```

A seção **OBJECT SECURITY** identifica o objeto e apresenta **EXPLICIT
OBJECT / COLUMN PERMISSIONS**.

No exemplo demonstrado:

``` text
principal : WX_TEST_USER
type      : SQL_USER
state     : GRANT
permission: SELECT
scope     : (object)
```

## `orphans`

Procura candidatos a usuários órfãos.

``` cmd
wxt-cpp-026-sql-security-explorer.exe orphans --server .\WSRV25 --db WX_RECOVERY_LAB
```

A seção apresentada é:

``` text
ORPHAN USER CANDIDATES
```

Na captura de homologação:

``` text
(no rows)
```

## Tratamento de erro --- objeto inexistente

O banner demonstra tratamento defensivo quando o objeto solicitado não
existe.

``` cmd
wxt-cpp-026-sql-security-explorer.exe object dbo.NAO_EXISTE --server .\WSRV25 --db WX_RECOVERY_LAB
```

Resultado demonstrado:

``` text
wxt-cpp-026-sql-security-explorer: error: object not found: dbo.NAO_EXISTE
```

## Sequência rápida de inspeção

``` cmd
wxt-cpp-026-sql-security-explorer.exe summary --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-026-sql-security-explorer.exe users --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-026-sql-security-explorer.exe roles --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-026-sql-security-explorer.exe permissions WX_TEST_USER --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-026-sql-security-explorer.exe object dbo.DadosTeste --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-026-sql-security-explorer.exe orphans --server .\WSRV25 --db WX_RECOVERY_LAB
```

## Ambiente demonstrado

``` text
SQL Server : .\WSRV25
Database   : WX_RECOVERY_LAB
User       : WX_TEST_USER
Object     : dbo.DadosTeste
```

## Visão funcional

``` text
SQL Security Explorer
        |
        +-- Security Summary
        +-- Database Users
        +-- Role Membership
        +-- User Permissions
        +-- Object / Column Permissions
        +-- Orphan User Candidates
```

## Arquivos do componente

Padrão POLYDEV:

``` text
wxt-cpp-026-sql-security-explorer.cpp
wxt-cpp-026-sql-security-explorer.exe
wxt-cpp-026-sql-security-explorer.png
wxt-cpp-026-sql-security-explorer-README.md
```

------------------------------------------------------------------------

**POLYDEV \| WX-TOOLS \| 026 \| SQL SECURITY EXPLORER**
