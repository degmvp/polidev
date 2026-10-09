# POLYDEV \| WX-TOOLS \| 023 \| SQL Catalog Map

**Arquivo:** `wxt-cpp-023-sql-catalog-map.cpp`\
**Versão:** `1.0.0`\
**Tecnologia:** C++ / ODBC / Microsoft SQL Server\
**Status:** homologada

## Descrição

O **SQL Catalog Map** é uma ferramenta de linha de comando da coleção
POLYDEV WX-TOOLS que se conecta ao SQL Server via ODBC e explora o
catálogo lógico de um banco de dados.

A ferramenta exibe informações sobre:

-   banco de dados;
-   schemas;
-   objetos;
-   colunas;
-   índices;
-   constraints;
-   dependências.

## Requisitos

-   Windows
-   ferramenta C++ com ODBC
-   ODBC Driver 18 for SQL Server ou compatível
-   acesso ao SQL Server por autenticação integrada ou configurada
-   permissões de leitura no banco de dados

## Sintaxe

``` cmd
wxt-cpp-023-sql-catalog-map COMMAND [OBJECT] --server SERVER --db DATABASE [options]
```

## Comandos

``` text
database
schemas
objects
object <schema.object>
dependencies <schema.object>
```

## Opções

``` text
--server SERVER    Instância SQL Server
--db DATABASE      Banco a inspecionar
--driver DRIVER    Nome do driver ODBC
-h, --help         Exibe a ajuda
-v, --version      Exibe a versão
```

O driver padrão documentado no banner é:

``` text
ODBC Driver 18 for SQL Server
```

## Versão

``` cmd
wxt-cpp-023-sql-catalog-map.exe --version
```

Saída demonstrada:

``` text
wxt-cpp-023-sql-catalog-map 1.0.0
```

## Ajuda

``` cmd
wxt-cpp-023-sql-catalog-map.exe --help
```

Exibe a sintaxe, comandos, opções e exemplos de operação.

## `database`

Apresenta uma visão geral do banco e estatísticas dos objetos.

``` cmd
wxt-cpp-023-sql-catalog-map.exe database --server ".\WSRV25" --db WX_RECOVERY_LAB
```

A saída demonstrada contém:

### DATABASE MAP

-   `database_name`
-   `status`
-   `recovery_model`
-   `compatibility_level`
-   `collation_name`
-   `create_date`

### OBJECT SUMMARY

Agrupa objetos por tipo e apresenta sua quantidade.

### SCHEMA SUMMARY

Apresenta schemas e quantidade de objetos.

## `schemas`

Lista os schemas e a quantidade de objetos associados.

``` cmd
wxt-cpp-023-sql-catalog-map.exe schemas --server ".\WSRV25" --db WX_RECOVERY_LAB
```

A seção **SCHEMA MAP** demonstra:

-   `schema_id`
-   `schema_name`
-   `owner_name`
-   `object_count`

## `objects`

Apresenta o inventário de objetos de usuário.

``` cmd
wxt-cpp-023-sql-catalog-map.exe objects --server ".\WSRV25" --db WX_RECOVERY_LAB
```

A seção **OBJECT INVENTORY** demonstra informações como:

-   `schema_name`
-   `object_name`
-   `type`
-   `type_desc`
-   `object_id`
-   `create_date`
-   `modify_date`

No ambiente demonstrado aparecem objetos como:

``` text
dbo.DadosTeste
dbo.DadosTeste_Recovery
```

## `object <schema.object>`

Inspeciona detalhadamente um objeto.

``` cmd
wxt-cpp-023-sql-catalog-map.exe object dbo.DadosTeste --server ".\WSRV25" --db WX_RECOVERY_LAB
```

A seção **OBJECT INSPECTOR** apresenta dados gerais do objeto e três
áreas principais.

### COLUMNS

Demonstra:

-   `column_id`
-   `column_name`
-   `data_type`
-   `type_size`
-   `nullable`
-   `identity_column`
-   `computed_column`

### INDEXES

Demonstra:

-   `index_id`
-   `index_name`
-   `type_desc`
-   `is_unique`
-   `primary_key`
-   `unique_constraint`
-   `disabled`

### INDEX COLUMNS

Apresenta a composição das colunas do índice, incluindo ordinal, coluna,
ordenação e inclusão.

### CONSTRAINTS

Apresenta nome e tipo das constraints associadas ao objeto.

## `dependencies <schema.object>`

Mostra as relações de referência do objeto.

``` cmd
wxt-cpp-023-sql-catalog-map.exe dependencies dbo.DadosTeste --server ".\WSRV25" --db WX_RECOVERY_LAB
```

A seção **DEPENDENCY MAP** é dividida em:

``` text
REFERENCES
REFERENCED BY
```

No exemplo registrado no banner para `dbo.DadosTeste`, ambas as seções
retornaram:

``` text
(no rows)
```

## Sequência rápida de inspeção

``` cmd
wxt-cpp-023-sql-catalog-map.exe database --server ".\WSRV25" --db WX_RECOVERY_LAB

wxt-cpp-023-sql-catalog-map.exe schemas --server ".\WSRV25" --db WX_RECOVERY_LAB

wxt-cpp-023-sql-catalog-map.exe objects --server ".\WSRV25" --db WX_RECOVERY_LAB

wxt-cpp-023-sql-catalog-map.exe object dbo.DadosTeste --server ".\WSRV25" --db WX_RECOVERY_LAB

wxt-cpp-023-sql-catalog-map.exe dependencies dbo.DadosTeste --server ".\WSRV25" --db WX_RECOVERY_LAB
```

## Cenários de uso

Conforme a documentação visual:

-   mapear rapidamente a estrutura de um banco de dados;
-   auditoria e documentação de objetos;
-   análise de dependências entre objetos;
-   suporte em processos de recuperação e migração.

## Ambiente demonstrado

``` text
SQL Server : .\WSRV25
Database   : WX_RECOVERY_LAB
Object     : dbo.DadosTeste
```

## Arquivos do componente

Padrão POLYDEV:

``` text
wxt-cpp-023-sql-catalog-map.cpp
wxt-cpp-023-sql-catalog-map.exe
wxt-cpp-023-sql-catalog-map.png
wxt-cpp-023-sql-catalog-map-README.md
```

------------------------------------------------------------------------

**POLYDEV \| WX-TOOLS \| 023 \| SQL CATALOG MAP**
