# POLYDEV \| WX-TOOLS \| 032 \| SQL Backup Explorer

**Arquivo:** `wxt-cpp-032-sql-backup-explorer.cpp`\
**Versão:** `1.0.0`\
**Tecnologia:** C++17 + ODBC\
**Modo de operação:** somente leitura (read-only)

## Descrição

O **SQL Backup Explorer** é uma ferramenta de linha de comando da
coleção POLYDEV WX-TOOLS para inspeção do histórico e da saúde dos
backups do Microsoft SQL Server.

A ferramenta consulta informações do SQL Server e do banco `msdb` para
apresentar:

-   resumo dos últimos backups FULL, DIFF e LOG;
-   situação de backup de um banco específico;
-   histórico recente de backups;
-   arquivos/dispositivos físicos utilizados pelos backups;
-   avaliação da saúde dos backups, com avisos e condições críticas.

A ferramenta não executa BACKUP, RESTORE nem altera dados do SQL Server.

## Requisitos

-   Windows
-   Microsoft SQL Server
-   ODBC Driver 18 for SQL Server
-   Visual Studio 2022 para compilação do fonte
-   C++17
-   biblioteca `odbc32.lib`
-   autenticação integrada do Windows com permissão para consultar as
    informações utilizadas pela ferramenta

A conexão é realizada inicialmente no banco `master` usando:

-   `Trusted_Connection=Yes`
-   `TrustServerCertificate=Yes`

## Sintaxe

``` cmd
wxt-cpp-032-sql-backup-explorer.exe <command> [options]
```

## Comandos

### `summary`

Mostra o último backup FULL, DIFF e LOG para cada banco de usuário do
SQL Server.

``` cmd
wxt-cpp-032-sql-backup-explorer.exe summary --server ".\WSRV25"
```

### `database`

Mostra o estado de backup de um banco específico, incluindo estado do
banco, recovery model, último FULL, último DIFF, último LOG e quantidade
de backup sets encontrados.

O parâmetro `--db` é obrigatório para este comando.

``` cmd
wxt-cpp-032-sql-backup-explorer.exe database --server ".\WSRV25" --db WX_RECOVERY_LAB
```

### `history`

Mostra os 100 backups mais recentes, ordenados pela data de término do
backup.

A saída inclui:

-   banco;
-   tipo do backup;
-   início;
-   término;
-   duração em segundos;
-   tamanho;
-   tamanho comprimido;
-   usuário.

Sem `--db`, consulta o histórico geral. Com `--db`, filtra pelo banco
informado.

``` cmd
wxt-cpp-032-sql-backup-explorer.exe history --server ".\WSRV25" --db WX_RECOVERY_LAB
```

### `files`

Mostra os dispositivos/arquivos físicos associados aos backups.

A saída inclui:

-   banco;
-   tipo do backup;
-   data/hora de término;
-   tipo do dispositivo;
-   caminho físico do arquivo/dispositivo.

``` cmd
wxt-cpp-032-sql-backup-explorer.exe files --server ".\WSRV25" --db WX_RECOVERY_LAB
```

Exemplo de arquivos utilizados durante a homologação:

``` text
E:\@LIB-C++\WX_RECOVERY_LAB_FULL.bak
E:\@LIB-C++\WX_RECOVERY_LAB_DIFF.bak
E:\@LIB-C++\WX_RECOVERY_LAB_LOG.trn
```

### `health`

Executa uma avaliação consolidada da saúde dos backups dos bancos de
usuário ONLINE.

``` cmd
wxt-cpp-032-sql-backup-explorer.exe health --server ".\WSRV25"
```

A classificação utilizada pela versão 1.0.0 é:

  -----------------------------------------------------------------------
  Condição                            Resultado
  ----------------------------------- -----------------------------------
  Nenhum FULL encontrado              `CRITICAL: NO FULL BACKUP`

  Último FULL com 7 dias ou mais      `CRITICAL: FULL >= 7 DAYS`

  Último FULL com 1 dia ou mais       `WARNING: FULL >= 1 DAY`

  Recovery model FULL sem backup de   `WARNING: NO LOG BACKUP`
  LOG                                 

  Recovery model FULL com LOG de 24   `WARNING: LOG >= 24 HOURS`
  horas ou mais                       

  Nenhuma das condições acima         `OK`
  -----------------------------------------------------------------------

## Opções

### `--server <server>`

Instância do SQL Server.

Exemplo:

``` cmd
--server ".\WSRV25"
```

O parâmetro `--server` é obrigatório para a execução dos comandos de
consulta.

### `--db <database>`

Banco usado como filtro pelos comandos `database`, `history` e `files`.

Exemplo:

``` cmd
--db WX_RECOVERY_LAB
```

### `--help`

Exibe a ajuda integrada.

``` cmd
wxt-cpp-032-sql-backup-explorer.exe --help
```

Também são aceitos:

``` cmd
wxt-cpp-032-sql-backup-explorer.exe -h
wxt-cpp-032-sql-backup-explorer.exe help
```

### `--version`

Exibe a versão da ferramenta.

``` cmd
wxt-cpp-032-sql-backup-explorer.exe --version
```

ou:

``` cmd
wxt-cpp-032-sql-backup-explorer.exe -v
```

Saída esperada:

``` text
wxt-cpp-032-sql-backup-explorer 1.0.0
```

## Sequência rápida de operação

Para uma inspeção completa do ambiente:

``` cmd
wxt-cpp-032-sql-backup-explorer.exe summary --server ".\WSRV25"

wxt-cpp-032-sql-backup-explorer.exe health --server ".\WSRV25"

wxt-cpp-032-sql-backup-explorer.exe database --server ".\WSRV25" --db WX_RECOVERY_LAB

wxt-cpp-032-sql-backup-explorer.exe history --server ".\WSRV25" --db WX_RECOVERY_LAB

wxt-cpp-032-sql-backup-explorer.exe files --server ".\WSRV25" --db WX_RECOVERY_LAB
```

## Compilação

O fonte foi desenvolvido para Visual Studio 2022, C++17, utilizando
ODBC.

A biblioteca necessária é:

``` text
odbc32.lib
```

O próprio fonte inclui:

``` cpp
#pragma comment(lib, "odbc32.lib")
```

## Segurança

O SQL Backup Explorer foi projetado como utilitário de inspeção
**read-only**.

As consultas utilizadas pela versão 1.0.0 leem informações de catálogo e
histórico, principalmente de:

-   `sys.databases`
-   `msdb.dbo.backupset`
-   `msdb.dbo.backupmediafamily`

Nenhum dos comandos da ferramenta executa alteração de dados ou inicia
operações de backup/restore.

## Ambiente de homologação POLYDEV

Exemplos desta documentação utilizam:

``` text
SQL Server : .\WSRV25
Database   : WX_RECOVERY_LAB
```

## Arquivos do componente

Padrão POLYDEV:

``` text
wxt-cpp-032-sql-backup-explorer.cpp
wxt-cpp-032-sql-backup-explorer.exe
wxt-cpp-032-sql-backup-explorer.png
wxt-cpp-032-sql-backup-explorer-README.md
```

## Versão

**1.0.0**

------------------------------------------------------------------------

**POLYDEV \| WX-TOOLS \| C++ \| 032 \| SQL Backup Explorer**
