/*
=============================================================
TSQL25_08 - Diagnóstico de Performance do Banco
=============================================================
Conjunto de procedures para análise de performance:
queries lentas, índices ausentes, bloqueios, estatísticas
de tabelas e health check geral do banco.

Compatível: SQL Server 2016+ / Azure SQL
=============================================================
*/

-- Top queries mais lentas (por tempo de execução)
CREATE OR ALTER PROCEDURE dbo.sp_TopQueriesLentas
    @Top INT = 20,
    @OrdenarPor NVARCHAR(20) = 'tempo'  -- 'tempo', 'cpu', 'io', 'execucoes'
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@Top)
        qs.total_elapsed_time / qs.execution_count / 1000    AS AvgTempoMs,
        qs.total_worker_time / qs.execution_count / 1000     AS AvgCpuMs,
        qs.total_logical_reads / qs.execution_count           AS AvgLeituras,
        qs.total_logical_writes / qs.execution_count          AS AvgEscritas,
        qs.execution_count                                    AS Execucoes,
        qs.total_elapsed_time / 1000                          AS TempoTotalMs,
        qs.creation_time                                      AS CompiladoEm,
        qs.last_execution_time                                AS UltimaExecucao,
        SUBSTRING(st.text,
            (qs.statement_start_offset / 2) + 1,
            (CASE qs.statement_end_offset
                WHEN -1 THEN DATALENGTH(st.text)
                ELSE qs.statement_end_offset
            END - qs.statement_start_offset) / 2 + 1)        AS TextoQuery,
        qp.query_plan                                         AS PlanoExecucao
    FROM sys.dm_exec_query_stats qs
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
    CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
    ORDER BY
        CASE @OrdenarPor
            WHEN 'tempo'     THEN qs.total_elapsed_time / qs.execution_count
            WHEN 'cpu'       THEN qs.total_worker_time / qs.execution_count
            WHEN 'io'        THEN qs.total_logical_reads / qs.execution_count
            WHEN 'execucoes' THEN qs.execution_count
            ELSE qs.total_elapsed_time / qs.execution_count
        END DESC;
END
GO

-- Índices ausentes recomendados pelo SQL Server
CREATE OR ALTER PROCEDURE dbo.sp_IndicesAusentes
    @Top INT = 30
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@Top)
        DB_NAME(mid.database_id)                              AS Banco,
        OBJECT_SCHEMA_NAME(mid.object_id, mid.database_id) +
            '.' + OBJECT_NAME(mid.object_id, mid.database_id) AS Tabela,
        mid.equality_columns                                   AS ColunasIgualdade,
        mid.inequality_columns                                 AS ColunasDesigualdade,
        mid.included_columns                                   AS ColunasIncluidas,
        migs.avg_user_impact                                   AS ImpactoPercent,
        migs.user_seeks                                        AS BuscasUsuario,
        migs.user_scans                                        AS ScansUsuario,
        migs.avg_total_user_cost                               AS CustoMedio,
        CAST(migs.avg_user_impact * migs.user_seeks *
             migs.avg_total_user_cost AS DECIMAL(18,2))        AS ScoreBeneficio,
        'CREATE NONCLUSTERED INDEX [IX_' +
            OBJECT_NAME(mid.object_id, mid.database_id) + '_' +
            REPLACE(REPLACE(ISNULL(mid.equality_columns,''), ', ', '_'), '[', '') +
            '] ON ' + OBJECT_SCHEMA_NAME(mid.object_id, mid.database_id) +
            '.' + OBJECT_NAME(mid.object_id, mid.database_id) +
            ' (' + ISNULL(mid.equality_columns, '') +
            CASE WHEN mid.equality_columns IS NOT NULL
                  AND mid.inequality_columns IS NOT NULL THEN ', ' ELSE '' END +
            ISNULL(mid.inequality_columns, '') + ')' +
            CASE WHEN mid.included_columns IS NOT NULL
                 THEN ' INCLUDE (' + mid.included_columns + ')' ELSE '' END AS DDLSugerido
    FROM sys.dm_db_missing_index_details mid
    INNER JOIN sys.dm_db_missing_index_groups mig
        ON mid.index_handle = mig.index_handle
    INNER JOIN sys.dm_db_missing_index_group_stats migs
        ON mig.index_group_handle = migs.group_handle
    WHERE mid.database_id = DB_ID()
    ORDER BY ScoreBeneficio DESC;
END
GO

-- Health Check geral do banco
CREATE OR ALTER PROCEDURE dbo.sp_HealthCheck
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Informações do servidor
    SELECT
        @@SERVERNAME            AS Servidor,
        @@VERSION               AS Versao,
        DB_NAME()               AS BancoAtual,
        SUSER_SNAME()           AS UsuarioAtual,
        SYSDATETIME()           AS DataHoraServidor;

    -- 2. Tamanho das tabelas
    SELECT
        s.name + '.' + t.name                                AS Tabela,
        p.rows                                                AS Linhas,
        CAST(SUM(a.total_pages) * 8 / 1024.0 AS DECIMAL(10,2)) AS TamanhoMB,
        CAST(SUM(a.used_pages) * 8 / 1024.0 AS DECIMAL(10,2))  AS UsadoMB,
        CAST((SUM(a.total_pages) - SUM(a.used_pages)) * 8 / 1024.0
             AS DECIMAL(10,2))                                AS LivreMB
    FROM sys.tables t
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    INNER JOIN sys.indexes i ON t.object_id = i.object_id
    INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
    INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
    GROUP BY s.name, t.name, p.rows
    ORDER BY SUM(a.total_pages) DESC;

    -- 3. Sessões ativas e bloqueios
    SELECT
        s.session_id            AS SPID,
        s.login_name            AS Login,
        s.status                AS Status,
        DB_NAME(s.database_id)  AS Banco,
        r.blocking_session_id   AS BloqueadoPor,
        r.wait_type             AS TipoEspera,
        r.wait_time / 1000      AS EsperaSegundos,
        r.cpu_time              AS CpuMs,
        st.text                 AS QueryAtual
    FROM sys.dm_exec_sessions s
    LEFT JOIN sys.dm_exec_requests r ON s.session_id = r.session_id
    OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) st
    WHERE s.is_user_process = 1
      AND s.status <> 'sleeping'
    ORDER BY r.cpu_time DESC;

    -- 4. Uso de memória
    SELECT
        physical_memory_in_use_kb / 1024        AS MemoriaUsadaMB,
        locked_page_allocations_kb / 1024       AS MemoriaLockedMB,
        total_virtual_address_space_kb / 1024   AS VirtualTotalMB,
        available_commit_limit_kb / 1024        AS CommitDisponivelMB
    FROM sys.dm_os_process_memory;
END
GO

-- ===================== EXEMPLO DE USO =====================
--
-- -- Queries mais lentas por CPU
-- EXEC dbo.sp_TopQueriesLentas @Top = 10, @OrdenarPor = 'cpu';
--
-- -- Índices recomendados
-- EXEC dbo.sp_IndicesAusentes @Top = 15;
--
-- -- Health check completo
-- EXEC dbo.sp_HealthCheck;
