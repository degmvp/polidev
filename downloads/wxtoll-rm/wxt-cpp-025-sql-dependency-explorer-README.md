# POLYDEV \| WX-TOOLS \| 025 \| SQL Dependency Explorer

**Arquivo:** `wxt-cpp-025-sql-dependency-explorer.cpp`\
**Versão:** `1.0.0`\
**Banco:** Microsoft SQL Server

## Descrição

O **SQL Dependency Explorer** é uma ferramenta da coleção POLYDEV
WX-TOOLS para explorar dependências entre objetos do SQL Server,
incluindo views, procedures, functions, triggers e outros objetos.

A ferramenta permite analisar referências, objetos que dependem de outro
objeto, impacto recursivo e a cadeia de dependências em formato de
árvore.

## Versão

``` cmd
wxt-cpp-025-sql-dependency-explorer.exe --version
```

Saída demonstrada:

``` text
wxt-cpp-025-sql-dependency-explorer version 1.0.0
```

## Sintaxe utilizada nos testes

``` cmd
wxt-cpp-025-sql-dependency-explorer.exe <command> [schema.object] --server .\WSRV25 --db WX_RECOVERY_LAB
```

## `database`

Apresenta um resumo das dependências existentes no banco.

``` cmd
wxt-cpp-025-sql-dependency-explorer.exe database --server .\WSRV25 --db WX_RECOVERY_LAB
```

A seção **DATABASE DEPENDENCY SUMMARY** demonstra:

### DEPENDENCY TYPES

Agrupa as dependências por tipo de objeto referenciador.

No ambiente de homologação:

``` text
VIEW    1
```

### MOST REFERENCED OBJECTS

Apresenta os objetos mais referenciados, incluindo:

-   `schema_name`
-   `entity_name`
-   `entity_type`
-   `referenced_by_count`

### CROSS-DATABASE / CROSS-SERVER REFERENCES

Identifica referências entre bancos ou servidores.

Na captura de homologação:

``` text
(no rows)
```

## `referenced-by <schema.object>`

Mostra quais objetos utilizam o objeto informado.

``` cmd
wxt-cpp-025-sql-dependency-explorer.exe referenced-by dbo.DadosTeste --server .\WSRV25 --db WX_RECOVERY_LAB
```

Na homologação, `dbo.DadosTeste` é referenciada por:

``` text
dbo.vw_DadosTeste
```

A saída demonstra informações como:

-   `schema_name`
-   `entity_name`
-   `entity_type`
-   `object_id`
-   `schema_bound`
-   `caller_dependent`

## `references <schema.object>`

Mostra quais objetos são referenciados pelo objeto informado.

``` cmd
wxt-cpp-025-sql-dependency-explorer.exe references dbo.vw_DadosTeste --server .\WSRV25 --db WX_RECOVERY_LAB
```

Na homologação:

``` text
dbo.vw_DadosTeste
        |
        +-- dbo.DadosTeste
```

A saída demonstra:

-   `server_name`
-   `database_name`
-   `schema_name`
-   `entity_name`
-   `entity_type`
-   `schema_bound`
-   `caller_dependent`
-   `ambiguous`

## `impact <schema.object>`

Executa análise recursiva de impacto.

``` cmd
wxt-cpp-025-sql-dependency-explorer.exe impact dbo.DadosTeste --server .\WSRV25 --db WX_RECOVERY_LAB
```

A seção **IMPACT ANALYSIS** demonstra os níveis de dependência
encontrados.

No ambiente homologado:

``` text
Nível 1 : dbo.vw_DadosTeste
Nível 2 : dbo.vw_DadosTeste_Nivel2
```

Isso permite visualizar quais objetos podem ser afetados por alterações
no objeto analisado.

## `tree <schema.object>`

Apresenta as dependências em formato de árvore.

``` cmd
wxt-cpp-025-sql-dependency-explorer.exe tree dbo.DadosTeste --server .\WSRV25 --db WX_RECOVERY_LAB
```

Resultado demonstrado:

``` text
dbo.DadosTeste
    `-- dbo.vw_DadosTeste [VIEW]
        `-- dbo.vw_DadosTeste_Nivel2 [VIEW]
```

## Tratamento de objeto inexistente

A ferramenta possui tratamento defensivo para objetos não encontrados.

``` cmd
wxt-cpp-025-sql-dependency-explorer.exe references dbo.NAO_EXISTE --server .\WSRV25 --db WX_RECOVERY_LAB
```

Resultado:

``` text
wxt-cpp-025-sql-dependency-explorer: error: object not found: dbo.NAO_EXISTE
```

## Sequência rápida de análise

``` cmd
wxt-cpp-025-sql-dependency-explorer.exe database --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-025-sql-dependency-explorer.exe referenced-by dbo.DadosTeste --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-025-sql-dependency-explorer.exe references dbo.vw_DadosTeste --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-025-sql-dependency-explorer.exe impact dbo.DadosTeste --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-025-sql-dependency-explorer.exe tree dbo.DadosTeste --server .\WSRV25 --db WX_RECOVERY_LAB
```

## Ambiente demonstrado

``` text
SQL Server : .\WSRV25
Database   : WX_RECOVERY_LAB

Objeto base:
dbo.DadosTeste

Dependências:
dbo.DadosTeste
    |
    +-- dbo.vw_DadosTeste
            |
            +-- dbo.vw_DadosTeste_Nivel2
```

## Visão funcional

``` text
SQL Dependency Explorer
        |
        +-- Database Summary
        +-- Referenced By
        +-- References
        +-- Impact Analysis (recursiva)
        +-- Dependency Tree
```

## Arquivos do componente

Padrão POLYDEV:

``` text
wxt-cpp-025-sql-dependency-explorer.cpp
wxt-cpp-025-sql-dependency-explorer.exe
wxt-cpp-025-sql-dependency-explorer.png
wxt-cpp-025-sql-dependency-explorer-README.md
```

------------------------------------------------------------------------

**POLYDEV \| WX-TOOLS \| 025 \| SQL DEPENDENCY EXPLORER**
