# POLYDEV \| WX-TOOLS \| 030 \| SQL Server Health Explorer

**Arquivo:** `wxt-cpp-030-sql-server-health-explorer.cpp`\
**Tecnologia:** C++17 / SQL Server\
**Tipo:** ferramenta de diagnóstico via linha de comando

## Descrição

O **SQL Server Health Explorer** é uma ferramenta da coleção POLYDEV
WX-TOOLS destinada ao diagnóstico da saúde de uma instância Microsoft
SQL Server pela linha de comando.

O banner de homologação apresenta sete comandos:

-   `summary`
-   `databases`
-   `memory`
-   `cpu`
-   `io`
-   `tempdb`
-   `health`

Os exemplos abaixo utilizam a instância `.\WSRV25` e o banco
`WX_RECOVERY_LAB`.

## Sintaxe utilizada

``` cmd
wxt-cpp-030-sql-server-health-explorer.exe <command> --server .\WSRV25 --db WX_RECOVERY_LAB
```

## 1. `summary`

Apresenta um resumo da instância e de sua atividade.

``` cmd
wxt-cpp-030-sql-server-health-explorer.exe summary --server .\WSRV25 --db WX_RECOVERY_LAB
```

O painel demonstrado inclui informações como:

-   servidor e instância;
-   edição e versão do produto;
-   nível do produto/update;
-   sessão atual;
-   banco atual;
-   quantidade de bancos;
-   bancos online;
-   sessões de usuário;
-   requests ativos;
-   requests bloqueados.

## 2. `databases`

Examina a saúde dos bancos e o espaço dos arquivos.

``` cmd
wxt-cpp-030-sql-server-health-explorer.exe databases --server .\WSRV25 --db WX_RECOVERY_LAB
```

O painel **DATABASE HEALTH** demonstra informações como:

-   `database_id`
-   `database_name`
-   `state_desc`
-   `recovery_model_desc`
-   `user_access_desc`
-   `is_read_only`
-   `is_auto_close_on`
-   `is_auto_shrink_on`
-   `log_reuse_wait_desc`

O painel **DATABASE FILE SPACE** apresenta banco, tipo de arquivo,
quantidade de arquivos e espaço alocado.

## 3. `memory`

Examina memória física, memória do processo SQL Server e configuração de
memória.

``` cmd
wxt-cpp-030-sql-server-health-explorer.exe memory --server .\WSRV25 --db WX_RECOVERY_LAB
```

A saída demonstrada é dividida em:

-   `MEMORY HEALTH`
-   `SQL SERVER PROCESS MEMORY`
-   `MEMORY CONFIGURATION`

Entre os indicadores exibidos estão memória física, memória disponível,
page file, utilização de memória, commit disponível e configurações
`max server memory (MB)` e `min server memory (MB)`.

## 4. `cpu`

Examina CPU e schedulers do SQL Server.

``` cmd
wxt-cpp-030-sql-server-health-explorer.exe cpu --server .\WSRV25 --db WX_RECOVERY_LAB
```

A saída demonstrada contém:

### CPU / Scheduler Health

-   `cpu_count`
-   `scheduler_count`
-   `hyperthread_ratio`
-   `socket_count`
-   `cores_per_socket`
-   `numa_node_count`

### Visible Schedulers

Inclui informações como:

-   `scheduler_id`
-   `cpu_id`
-   `status`
-   `is_online`
-   `current_tasks_count`
-   `runnable_tasks_count`

## 5. `io`

Examina a atividade de I/O dos arquivos de banco.

``` cmd
wxt-cpp-030-sql-server-health-explorer.exe io --server .\WSRV25 --db WX_RECOVERY_LAB
```

O painel **DATABASE I/O HEALTH** demonstra métricas como:

-   banco;
-   tipo;
-   arquivo lógico;
-   quantidade de leituras;
-   quantidade de gravações;
-   stall de leitura;
-   stall de gravação;
-   stall total.

## 6. `tempdb`

Examina configuração e utilização do `tempdb`.

``` cmd
wxt-cpp-030-sql-server-health-explorer.exe tempdb --server .\WSRV25 --db WX_RECOVERY_LAB
```

A saída demonstrada contém:

### TEMPDB HEALTH

-   `file_id`
-   `name`
-   `type_desc`
-   `physical_name`
-   `size_mb`
-   `growth_setting`

### TEMPDB SPACE USAGE

-   `user_objects_mb`
-   `internal_objects_mb`
-   `version_store_mb`
-   `free_space_mb`

## 7. `health`

Executa a verificação consolidada da saúde do SQL Server.

``` cmd
wxt-cpp-030-sql-server-health-explorer.exe health --server .\WSRV25 --db WX_RECOVERY_LAB
```

O banner demonstra as seguintes seções:

### Consolidated Health Check

-   bancos que não estão ONLINE;
-   `AUTO_CLOSE` habilitado;
-   `AUTO_SHRINK` habilitado;
-   requests bloqueados;
-   schedulers com fila;
-   pressão de memória física;
-   pressão de memória virtual.

### Database States

Agrupa os bancos por estado.

### Recovery Models

Agrupa os bancos por recovery model.

### Current Activity

Apresenta:

-   sessões de usuário;
-   requests ativos;
-   requests bloqueados;
-   locks em espera.

### TempDB Snapshot

Apresenta:

-   objetos de usuário;
-   objetos internos;
-   version store;
-   espaço livre.

## Sequência rápida de diagnóstico

``` cmd
wxt-cpp-030-sql-server-health-explorer.exe summary --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-030-sql-server-health-explorer.exe databases --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-030-sql-server-health-explorer.exe memory --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-030-sql-server-health-explorer.exe cpu --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-030-sql-server-health-explorer.exe io --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-030-sql-server-health-explorer.exe tempdb --server .\WSRV25 --db WX_RECOVERY_LAB

wxt-cpp-030-sql-server-health-explorer.exe health --server .\WSRV25 --db WX_RECOVERY_LAB
```

## Ambiente demonstrado no banner

``` text
SQL Server : .\WSRV25
Database   : WX_RECOVERY_LAB
```

O banner mostra a ferramenta operando sobre SQL Server 2025, com os
resultados reais do ambiente de homologação POLYDEV.

## Finalidade operacional

O SQL Server Health Explorer reúne em uma única CLI informações que
normalmente exigiriam várias consultas de diagnóstico, permitindo uma
passagem rápida por:

``` text
Instância
   |
   +-- Bancos
   +-- Memória
   +-- CPU / Schedulers
   +-- I/O
   +-- TempDB
   |
   +-- Health consolidado
```

## Arquivos do componente

Padrão POLYDEV:

``` text
wxt-cpp-030-sql-server-health-explorer.cpp
wxt-cpp-030-sql-server-health-explorer.exe
wxt-cpp-030-sql-server-health-explorer.png
wxt-cpp-030-sql-server-health-explorer-README.md
```

------------------------------------------------------------------------

**POLYDEV \| WX-TOOLS \| 030 \| SQL SERVER HEALTH EXPLORER**
