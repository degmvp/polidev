# POLYDEV \| WX-TOOLS \| 024 \| SQL Storage Explorer

**Arquivo:** `wxt-cpp-024-sql-storage-explorer.cpp`\
**Versão:** `1.0.0`\
**Tecnologia:** C++ / ODBC / Microsoft SQL Server\
**Status:** homologada

## Descrição

O **SQL Storage Explorer** é uma ferramenta de linha de comando da
coleção POLYDEV WX-TOOLS para explorar a estrutura física de
armazenamento dos objetos no SQL Server.

A ferramenta apresenta de forma hierárquica como objetos e índices
utilizam partições, allocation units e páginas:

``` text
OBJECT -> INDEX -> PARTITION -> ALLOCATION -> PAGES
```

## Requisitos

-   Windows
-   ODBC Driver 18 for SQL Server
-   acesso ao SQL Server com autenticação atual do Windows ou conforme
    configuração do ambiente

## Sintaxe

``` cmd
wxt-cpp-024-sql-storage-explorer.exe <command> [object_name] --server <servidor\instancia> --db <banco>
```

Exemplo de conexão utilizado na homologação:

``` cmd
--server .\WSRV25 --db WX_RECOVERY_LAB
```

## Comandos disponíveis

``` text
object       Mapa completo do objeto
indexes      Índices do objeto
partitions   Partições do objeto
allocation   Allocation units do objeto
top          Ranking de objetos do database
```

## `object <schema.object>`

Apresenta o mapa completo de armazenamento do objeto.

``` cmd
wxt-cpp-024-sql-storage-explorer.exe object dbo.DadosTeste --server .\WSRV25 --db WX_RECOVERY_LAB
```

O resultado demonstrado contém informações gerais do objeto e as seções
**STORAGE SUMMARY** e **INDEX STORAGE**.

Entre os dados apresentados estão:

-   banco e schema;
-   nome e `object_id`;
-   tipo do objeto;
-   datas de criação e modificação;
-   quantidade de partições;
-   linhas;
-   páginas totais e utilizadas;
-   espaço reservado, utilizado e livre;
-   armazenamento por índice.

## `indexes <schema.object>`

Mostra os índices e seu consumo de armazenamento.

``` cmd
wxt-cpp-024-sql-storage-explorer.exe indexes dbo.DadosTeste --server .\WSRV25 --db WX_RECOVERY_LAB
```

A seção **INDEX STORAGE** demonstra informações como:

-   `index_id`
-   `index_name`
-   `type_desc`
-   índice único;
-   primary key;
-   quantidade de partições;
-   linhas;
-   páginas totais;
-   páginas utilizadas;
-   MB reservados;
-   MB utilizados.

## `partitions <schema.object>`

Examina as partições do objeto.

``` cmd
wxt-cpp-024-sql-storage-explorer.exe partitions dbo.DadosTeste --server .\WSRV25 --db WX_RECOVERY_LAB
```

A seção **PARTITION MAP** demonstra:

-   índice;
-   número da partição;
-   `partition_id`;
-   `hobt_id`;
-   quantidade de linhas;
-   compressão de dados;
-   data space;
-   tipo do data space.

## `allocation <schema.object>`

Mostra as allocation units utilizadas pelo objeto.

``` cmd
wxt-cpp-024-sql-storage-explorer.exe allocation dbo.DadosTeste --server .\WSRV25 --db WX_RECOVERY_LAB
```

A seção **ALLOCATION MAP** demonstra informações como:

-   índice;
-   partição;
-   `allocation_unit_id`;
-   tipo da allocation unit;
-   páginas totais;
-   páginas utilizadas;
-   páginas de dados;
-   MB reservados;
-   MB utilizados;
-   MB de dados.

Tipos de allocation unit destacados na documentação visual:

``` text
IN_ROW_DATA
LOB_DATA
ROW_OVERFLOW_DATA
```

## `top`

Apresenta um ranking dos objetos do banco por utilização de storage.

``` cmd
wxt-cpp-024-sql-storage-explorer.exe top --server .\WSRV25 --db WX_RECOVERY_LAB
```

A seção **TOP STORAGE OBJECTS** demonstra:

-   `schema_name`
-   `object_name`
-   `total_pages`
-   `used_pages`
-   `reserved_mb`
-   `used_mb`
-   `free_mb`

No ambiente de homologação aparecem, entre outros:

``` text
dbo.DadosTeste_Recovery
dbo.DadosTeste
```

## Cadeia física de armazenamento

A ferramenta organiza a análise segundo a estrutura:

``` text
OBJECT
  |
  +-- sys.objects
        |
        +-- INDEX
              sys.indexes
                |
                +-- PARTITION
                      sys.partitions
                        |
                        +-- ALLOCATION UNIT
                              sys.allocation_units
                                |
                                +-- PAGES / STORAGE
                                      sys.dm_db_partition_stats
```

### OBJECT

Fornece informações gerais do objeto.

### INDEX

Mostra a estrutura e o tipo dos índices, como clustered e nonclustered.

### PARTITION

Apresenta partições, quantidade de linhas, compressão e filegroup/data
space.

### ALLOCATION UNIT

Mostra como o armazenamento é separado entre `IN_ROW_DATA`, `LOB_DATA` e
`ROW_OVERFLOW_DATA`.

### PAGES

Apresenta métricas como:

``` text
total_pages
used_pages
data_pages
```

## Principais informações disponíveis

Conforme o banner da ferramenta:

-   rows por índice e partição;
-   páginas reservadas, usadas e de dados;
-   tamanho em MB reservado, usado e de dados;
-   tipo de allocation unit;
-   compressão de dados;
-   filegroup/data space;
-   ranking de objetos por uso de storage;
-   visão completa da cadeia física de armazenamento.

## Ambiente demonstrado

``` text
SQL Server : .\WSRV25
Database   : WX_RECOVERY_LAB
Object     : dbo.DadosTeste
```

Na homologação, `dbo.DadosTeste` apresenta 100.000 linhas e
aproximadamente 20,82 MB reservados.

## Sequência rápida de inspeção

``` cmd
wxt-cpp-024-sql-storage-explorer.exe object dbo.DadosTeste --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-024-sql-storage-explorer.exe indexes dbo.DadosTeste --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-024-sql-storage-explorer.exe partitions dbo.DadosTeste --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-024-sql-storage-explorer.exe allocation dbo.DadosTeste --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-024-sql-storage-explorer.exe top --server .\WSRV25 --db WX_RECOVERY_LAB
```

## Arquivos do componente

Padrão POLYDEV:

``` text
wxt-cpp-024-sql-storage-explorer.cpp
wxt-cpp-024-sql-storage-explorer.exe
wxt-cpp-024-sql-storage-explorer.png
wxt-cpp-024-sql-storage-explorer-README.md
```

------------------------------------------------------------------------

**POLYDEV \| WX-TOOLS \| 024 \| SQL STORAGE EXPLORER**
