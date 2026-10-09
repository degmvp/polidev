# POLYDEV \| WX-TOOLS \| 018 \| SQL Deleted Ghost Row Hunter

**Executável:** `wxt-cpp-018-sql-deleted-ghost-row-hunter.exe`\
**Tecnologia:** C++17\
**Alvo:** arquivos de dados Microsoft SQL Server (`MDF` / `NDF`)\
**Modo:** offline / somente leitura

## Descrição

O **SQL Deleted Ghost Row Hunter** é uma ferramenta da coleção POLYDEV
WX-TOOLS para localizar linhas excluídas (*ghost rows*) que ainda
permanecem fisicamente em arquivos de dados do SQL Server.

A ferramenta trabalha diretamente sobre estruturas de páginas,
identifica allocation units, analisa slots e recupera dados de linhas
mesmo quando os registros já não estão acessíveis normalmente pelo SQL
Server.

Conforme o banner:

``` text
Offline scan
Read-only
Forensic recovery
No SQL Server required
```

## Uso

``` cmd
wxt-cpp-018-sql-deleted-ghost-row-hunter.exe hunt <data_file.mdf> <output.csv>
```

## Exemplo

``` cmd
wxt-cpp-018-sql-deleted-ghost-row-hunter.exe hunt "E:\DATA-tools\WX_GHOST_LAB_DELETED.mdf" "E:\DATA-tools\wxt-cpp-018-final-evidence.csv"
```

## Comandos

### `hunt`

Analisa o arquivo de dados e exporta as linhas excluídas encontradas
para CSV.

``` cmd
wxt-cpp-018-sql-deleted-ghost-row-hunter.exe hunt <data_file.mdf> <output.csv>
```

### `help`

Mostra as informações de uso.

``` cmd
wxt-cpp-018-sql-deleted-ghost-row-hunter.exe help
```

## Características

Conforme a documentação visual, a ferramenta:

-   funciona offline, sem exigir SQL Server;
-   opera em modo somente leitura;
-   localiza linhas excluídas / ghost rows;
-   interpreta páginas de dados e metadados de slots;
-   extrai valores de colunas das linhas recuperadas;
-   gera relatório CSV detalhado;
-   suporta arquivos MDF e NDF;
-   é implementada em C++17;
-   pode ser utilizada em análise forense e auditorias.

## Exemplo de saída

O banner demonstra uma execução sobre:

``` text
E:\DATA-tools\WX_GHOST_LAB_DELETED.mdf
```

com saída em:

``` text
E:\DATA-tools\wxt-cpp-018-final-evidence.csv
```

Resumo demonstrado:

``` text
Total rows found       : 1000
Active rows            : 990
Deleted (ghost) rows   : 10
```

Chaves das linhas excluídas encontradas:

``` text
501, 502, 503, 504, 505, 506, 507, 508, 509, 510
```

Ao final:

``` text
CSV saved: E:\DATA-tools\wxt-cpp-018-final-evidence.csv

Scan completed successfully.
```

## Exemplo de linhas recuperadas

O banner representa o relatório de evidência com linhas como:

``` text
RowKey   Status    Sample Data
501      DELETED   ...
502      DELETED   ...
503      DELETED   ...
504      DELETED   ...
505      DELETED   ...
506      DELETED   ...
507      DELETED   ...
508      DELETED   ...
509      DELETED   ...
510      DELETED   ...
```

Resultado apresentado:

``` text
10 deleted rows recovered from disk!
```

## Funcionamento conceitual

``` text
MDF / NDF
   |
   v
leitura física
   |
   v
páginas de dados
   |
   v
allocation units
   |
   v
slots
   |
   +-- linhas ativas
   |
   +-- ghost rows
          |
          v
   extração dos valores
          |
          v
         CSV
```

## Operação somente leitura

A ferramenta é apresentada como:

``` text
READ-ONLY
```

Seu objetivo é inspecionar o arquivo de dados sem modificá-lo.

Isso é especialmente importante em cenários de recuperação e análise
forense, nos quais preservar a evidência original é fundamental.

## Casos de uso

Conforme o banner:

-   recuperar registros apagados acidentalmente;
-   investigar incidentes de perda de dados;
-   análise forense de arquivos SQL Server;
-   validar integridade de dados;
-   complementar estratégias de backup e recuperação.

## Cenário demonstrado

A documentação visual mostra a identificação de registros excluídos
diretamente nas páginas/slots do arquivo, exemplificando entradas como:

``` text
Page (...) DATA    Slot 501 - DELETED
Page (...) DATA    Slot 502 - DELETED
Page (...) DATA    Slot 503 - DELETED
...
Page (...) DATA    Slot 510 - DELETED
```

## Saída CSV

O comando `hunt` recebe explicitamente o caminho do CSV de saída:

``` cmd
wxt-cpp-018-sql-deleted-ghost-row-hunter.exe hunt <arquivo.mdf> <saida.csv>
```

Isso permite preservar os resultados da análise para inspeção posterior,
documentação e evidência.

## Visão funcional

``` text
SQL DELETED GHOST ROW HUNTER
             |
             +-- MDF / NDF
                    |
                    +-- scan offline
                    +-- parse pages
                    +-- inspect slots
                    +-- identify ghost rows
                    +-- recover column values
                    |
                    +-- export CSV
```

## Arquivos do componente

Padrão POLYDEV:

``` text
wxt-cpp-018-sql-deleted-ghost-row-hunter.cpp
wxt-cpp-018-sql-deleted-ghost-row-hunter.exe
wxt-cpp-018-sql-deleted-ghost-row-hunter.png
wxt-cpp-018-sql-deleted-ghost-row-hunter-README.md
```

------------------------------------------------------------------------

**POLYDEV \| WX-TOOLS \| 018 \| SQL DELETED GHOST ROW HUNTER**

*Data may be deleted, but not always gone.*
