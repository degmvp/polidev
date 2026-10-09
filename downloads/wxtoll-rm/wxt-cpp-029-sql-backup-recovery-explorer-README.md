# POLYDEV \| WX-TOOLS \| 029 \| SQL Backup & Recovery Explorer

**Arquivo:** `wxt-cpp-029-sql-backup-recovery-explorer.cpp`\
**Versão demonstrada:** `1.0.0`\
**Tecnologia:** C++ / Microsoft SQL Server\
**Status:** testes funcionais OK --- source frozen

## Descrição

O **SQL Backup & Recovery Explorer** é uma ferramenta da coleção POLYDEV
WX-TOOLS para explorar o histórico de backups, arquivos de backup,
cadeia de recuperação e estado dos bancos no SQL Server.

O banner de homologação demonstra os comandos:

-   `summary`
-   `history`
-   `latest`
-   `files`
-   `chain`
-   `recovery`

Também demonstra `--version` e o tratamento defensivo de comando
inválido.

## Versão

``` cmd
wxt-cpp-029-sql-backup-recovery-explorer.exe --version
```

Saída demonstrada:

``` text
wxt-cpp-029-sql-backup-recovery-explorer 1.0.0
```

## Sintaxe utilizada nos testes

``` cmd
wxt-cpp-029-sql-backup-recovery-explorer.exe <command> --server .\WSRV25 --db WX_RECOVERY_LAB
```

## `summary`

Apresenta um resumo dos backups registrados.

``` cmd
wxt-cpp-029-sql-backup-recovery-explorer.exe summary --server .\WSRV25 --db WX_RECOVERY_LAB
```

O banner demonstra a seção **BACKUP SUMMARY**, com informações como:

-   quantidade de backup sets;
-   quantidade de FULL backups;
-   differential backups;
-   log backups;
-   bancos com histórico;
-   backup mais antigo;
-   backup mais recente.

Também apresenta **BACKUP SIZE**, com tamanho total e tamanho
comprimido.

## `history`

Apresenta o histórico detalhado de backups.

``` cmd
wxt-cpp-029-sql-backup-recovery-explorer.exe history --server .\WSRV25 --db WX_RECOVERY_LAB
```

Entre as colunas demonstradas estão:

-   `database_name`
-   `backup_type`
-   `backup_start_date`
-   `backup_finish_date`
-   `backup_mb`
-   `compressed_mb`
-   `is_copy_only`
-   `is_password`
-   `user_name`

## `latest`

Mostra o último backup por banco/tipo.

``` cmd
wxt-cpp-029-sql-backup-recovery-explorer.exe latest --server .\WSRV25 --db WX_RECOVERY_LAB
```

A saída **LATEST BACKUP BY DATABASE / TYPE** demonstra:

-   banco;
-   tipo de backup;
-   início;
-   término;
-   tamanho;
-   tamanho comprimido;
-   recovery model.

## `files`

Mostra as mídias e arquivos físicos associados aos backups.

``` cmd
wxt-cpp-029-sql-backup-recovery-explorer.exe files --server .\WSRV25 --db WX_RECOVERY_LAB
```

A seção **BACKUP MEDIA / FILES** demonstra informações como:

-   `database_name`
-   `backup_type`
-   `backup_finish_date`
-   `physical_device_name`
-   `device_type`
-   `backup_name`
-   `description`

## `chain`

Examina a cadeia de recuperação dos backups por meio dos LSNs.

``` cmd
wxt-cpp-029-sql-backup-recovery-explorer.exe chain --server .\WSRV25 --db WX_RECOVERY_LAB
```

A seção **BACKUP RECOVERY CHAIN** demonstra campos como:

-   `database_name`
-   `backup_type`
-   `backup_start_date`
-   `backup_finish_date`
-   `first_lsn`
-   `last_lsn`
-   `checkpoint_lsn`
-   `database_backup_lsn`
-   `differential_base_lsn`
-   `is_copy_only`
-   `recovery_model`

Esse comando é especialmente útil para visualizar os identificadores que
compõem a cadeia lógica de recuperação.

## `recovery`

Examina o estado dos bancos e informações relacionadas à recuperação.

``` cmd
wxt-cpp-029-sql-backup-recovery-explorer.exe recovery --server .\WSRV25 --db WX_RECOVERY_LAB
```

O banner demonstra duas áreas principais.

### DATABASE RECOVERY STATUS

Inclui informações como:

-   `database_id`
-   `database_name`
-   `state_desc`
-   `recovery_model_desc`
-   `user_access_desc`
-   `is_read_only`
-   `is_auto_close_on`
-   `is_auto_shrink_on`
-   `log_reuse_wait_desc`
-   `compatibility_level`
-   `create_date`

### LAST KNOWN BACKUPS

Apresenta por banco:

-   último FULL;
-   último DIFF;
-   último LOG.

## Tratamento de comando inválido

A ferramenta possui tratamento defensivo para comandos desconhecidos.

Exemplo demonstrado:

``` cmd
wxt-cpp-029-sql-backup-recovery-explorer.exe banana --server .\WSRV25 --db WX_RECOVERY_LAB
```

Resultado:

``` text
error: unknown command: banana
```

## Sequência rápida de inspeção

``` cmd
wxt-cpp-029-sql-backup-recovery-explorer.exe summary --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-029-sql-backup-recovery-explorer.exe history --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-029-sql-backup-recovery-explorer.exe latest --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-029-sql-backup-recovery-explorer.exe files --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-029-sql-backup-recovery-explorer.exe chain --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-029-sql-backup-recovery-explorer.exe recovery --server .\WSRV25 --db WX_RECOVERY_LAB
```

## Ambiente demonstrado

``` text
SQL Server : .\WSRV25
Database   : WX_RECOVERY_LAB
```

## Visão funcional

``` text
SQL Backup & Recovery Explorer
        |
        +-- Summary
        +-- History
        +-- Latest
        +-- Files
        +-- Recovery Chain (LSNs)
        +-- Recovery Status
```

## Arquivos do componente

Padrão POLYDEV:

``` text
wxt-cpp-029-sql-backup-recovery-explorer.cpp
wxt-cpp-029-sql-backup-recovery-explorer.exe
wxt-cpp-029-sql-backup-recovery-explorer.png
wxt-cpp-029-sql-backup-recovery-explorer-README.md
```

## Homologação

Conforme o banner:

``` text
WX-TOOLS 029 | TESTES FUNCIONAIS: OK | SOURCE FROZEN
VERSION  ✓
SUMMARY  ✓
HISTORY  ✓
LATEST   ✓
FILES    ✓
CHAIN    ✓
RECOVERY ✓
DEFENSIVO ✓
```

------------------------------------------------------------------------

**POLYDEV \| WX-TOOLS \| 029 \| SQL BACKUP & RECOVERY EXPLORER**
