# POLYDEV \| WX-TOOLS \| 027 \| SQL Index Health Explorer

**Arquivo:** `wxt-cpp-027-sql-index-health-explorer.cpp`\
**Tecnologia:** C++17 + ODBC\
**Plataforma demonstrada:** Windows 11 / Visual Studio 2022 / SQL
Server\
**Modo de operação:** somente leitura

## Descrição

O **SQL Index Health Explorer** é uma ferramenta da coleção POLYDEV
WX-TOOLS para diagnóstico de índices do Microsoft SQL Server.

A ferramenta é somente leitura. Conforme documentado no banner, **não
executa `REBUILD`, `REORGANIZE` ou `DROP`**.

Comandos demonstrados:

-   `summary`
-   `indexes <schema.table>`
-   `fragmentation <schema.table>`
-   `usage <schema.table>`
-   `unused`
-   `top`

## Sintaxe utilizada nos testes

``` cmd
wxt-cpp-027-sql-index-health-explorer.exe <command> [schema.table] --server .\WSRV25 --db WX_RECOVERY_LAB
```

## `summary`

Apresenta um resumo dos índices do banco e do espaço utilizado.

``` cmd
wxt-cpp-027-sql-index-health-explorer.exe summary --server .\WSRV25 --db WX_RECOVERY_LAB
```

### DATABASE INDEX SUMMARY

O banner demonstra:

-   `index_count`
-   `clustered_indexes`
-   `nonclustered_indexes`
-   `unique_indexes`
-   `primary_keys`
-   `disabled_indexes`

### INDEX SPACE

Apresenta:

-   `total_rows`
-   `reserved_pages`
-   `used_pages`
-   `reserved_mb`
-   `used_mb`

Na homologação de `dbo.DadosTeste` foram demonstradas 100.000 linhas e
aproximadamente 20,82 MB reservados.

## `indexes <schema.table>`

Lista os índices da tabela informada.

``` cmd
wxt-cpp-027-sql-index-health-explorer.exe indexes dbo.DadosTeste --server .\WSRV25 --db WX_RECOVERY_LAB
```

Entre as informações apresentadas estão:

-   `index_id`
-   `index_name`
-   `type_desc`
-   indicador de índice único;
-   indicador de primary key;
-   indicador de índice desabilitado;
-   quantidade de linhas;
-   páginas reservadas;
-   páginas utilizadas;
-   espaço reservado em MB.

## `fragmentation <schema.table>`

Examina a fragmentação dos índices da tabela.

``` cmd
wxt-cpp-027-sql-index-health-explorer.exe fragmentation dbo.DadosTeste --server .\WSRV25 --db WX_RECOVERY_LAB
```

A saída demonstrada inclui:

-   `index_id`
-   `index_name`
-   `partition_number`
-   `index_type_desc`
-   `alloc_unit_type_desc`
-   `page_count`
-   `fragmentation_pct`
-   `page_density_pct`
-   `avg_fragment_pages`

Na captura de homologação, o índice de `dbo.DadosTeste` apresenta
fragmentação muito baixa.

## `usage <schema.table>`

Examina estatísticas de utilização dos índices.

``` cmd
wxt-cpp-027-sql-index-health-explorer.exe usage dbo.DadosTeste --server .\WSRV25 --db WX_RECOVERY_LAB
```

O painel **INDEX USAGE** demonstra informações como:

-   `index_id`
-   `index_name`
-   `type_desc`
-   `user_seeks`
-   `user_scans`
-   `user_lookups`
-   `user_updates`
-   `total_reads`
-   datas das últimas operações de seek, scan, lookup e update.

## `unused`

Procura candidatos a índices não utilizados.

``` cmd
wxt-cpp-027-sql-index-health-explorer.exe unused --server .\WSRV25 --db WX_RECOVERY_LAB
```

A seção apresentada é:

``` text
UNUSED INDEX CANDIDATES
```

Na captura de homologação:

``` text
(no rows)
```

## `top`

Lista os maiores índices por tamanho.

``` cmd
wxt-cpp-027-sql-index-health-explorer.exe top --server .\WSRV25 --db WX_RECOVERY_LAB
```

A seção **TOP INDEXES BY SIZE** demonstra:

-   schema;
-   tabela;
-   índice;
-   `index_id`;
-   tipo;
-   quantidade de linhas;
-   páginas reservadas;
-   páginas utilizadas;
-   MB reservados;
-   MB utilizados.

## Tratamento defensivo

O banner também demonstra o tratamento de tabela inexistente.

Exemplo:

``` cmd
wxt-cpp-027-sql-index-health-explorer.exe indexes dbo.NAO_EXISTE --server .\WSRV25 --db WX_RECOVERY_LAB
```

Resultado:

``` text
wxt-cpp-027-sql-index-health-explorer:
error: table not found: dbo.NAO_EXISTE
```

## Sequência rápida de diagnóstico

``` cmd
wxt-cpp-027-sql-index-health-explorer.exe summary --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-027-sql-index-health-explorer.exe indexes dbo.DadosTeste --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-027-sql-index-health-explorer.exe fragmentation dbo.DadosTeste --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-027-sql-index-health-explorer.exe usage dbo.DadosTeste --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-027-sql-index-health-explorer.exe unused --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-027-sql-index-health-explorer.exe top --server .\WSRV25 --db WX_RECOVERY_LAB
```

## Ambiente demonstrado

``` text
SQL Server : .\WSRV25
Database   : WX_RECOVERY_LAB
Tabela     : dbo.DadosTeste
```

## Segurança operacional

A ferramenta foi concebida para diagnóstico.

``` text
READ-ONLY
REBUILD     : não executa
REORGANIZE  : não executa
DROP        : não executa
```

Portanto, seus comandos de inspeção não realizam manutenção automática
dos índices.

## Arquivos do componente

Padrão POLYDEV:

``` text
wxt-cpp-027-sql-index-health-explorer.cpp
wxt-cpp-027-sql-index-health-explorer.exe
wxt-cpp-027-sql-index-health-explorer.png
wxt-cpp-027-sql-index-health-explorer-README.md
```

------------------------------------------------------------------------

**POLYDEV \| WX-TOOLS \| 027 \| SQL INDEX HEALTH EXPLORER**
