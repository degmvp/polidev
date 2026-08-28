-- =============================================================================
-- SPCAT46.SQL
-- POLYDEV | SQL Server Catalog Explorer
-- Título : Intelligent Index Fragmentation Advisor
-- SGBD   : SQL Server 2016+ / Azure SQL
-- Objetivo:
--   Diagnosticar fragmentação de índices com relevância operacional,
--   cruzando fragmentação física com estatísticas de uso.
-- =============================================================================

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @MinPages INT = 1000;
DECLARE @MinFragmentation DECIMAL(5,2) = 5.00;
DECLARE @ScanMode VARCHAR(20) = 'SAMPLED'; -- LIMITED | SAMPLED | DETAILED

IF OBJECT_ID('tempdb..#Fragmentacao') IS NOT NULL DROP TABLE #Fragmentacao;
IF OBJECT_ID('tempdb..#UsoIndices') IS NOT NULL DROP TABLE #UsoIndices;

-- =============================================================================
-- 1. FRAGMENTAÇÃO FÍSICA DOS ÍNDICES
-- =============================================================================

SELECT
    ps.database_id,
    ps.object_id,
    ps.index_id,
    DB_NAME(ps.database_id) AS DatabaseName,
    SCHEMA_NAME(o.schema_id) AS SchemaName,
    o.name AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    ps.partition_number AS PartitionNumber,
    ps.index_level AS IndexLevel,
    ps.page_count AS PageCount,
    ps.avg_fragmentation_in_percent AS FragmentationPct,
    ps.avg_page_space_used_in_percent AS PageSpaceUsedPct,
    ps.record_count AS RecordCount,
    ps.fragment_count AS FragmentCount,
    i.fill_factor AS FillFactor,
    i.is_primary_key AS IsPrimaryKey,
    i.is_unique AS IsUnique
INTO #Fragmentacao
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, @ScanMode) ps
INNER JOIN sys.indexes i
    ON ps.object_id = i.object_id
   AND ps.index_id = i.index_id
INNER JOIN sys.objects o
    ON ps.object_id = o.object_id
WHERE
    o.is_ms_shipped = 0
    AND i.name IS NOT NULL
    AND ps.index_level = 0
    AND ps.page_count >= @MinPages;

-- =============================================================================
-- 2. ESTATÍSTICAS DE USO DOS ÍNDICES
-- Observação:
--   Esta DMV é zerada após restart da instância, detach do banco ou failover.
-- =============================================================================

SELECT
    database_id,
    object_id,
    index_id,
    user_seeks,
    user_scans,
    user_lookups,
    user_updates,
    (user_seeks + user_scans + user_lookups) AS TotalReads,
    last_user_seek,
    last_user_scan,
    last_user_lookup,
    last_user_update
INTO #UsoIndices
FROM sys.dm_db_index_usage_stats
WHERE database_id = DB_ID();

-- =============================================================================
-- 3. RELATÓRIO INTELIGENTE
-- =============================================================================

SELECT
    f.DatabaseName,
    f.SchemaName,
    f.TableName,
    f.IndexName,
    f.IndexType,
    f.PartitionNumber,
    f.PageCount,
    CAST(f.FragmentationPct AS DECIMAL(10,2)) AS FragmentationPct,
    CAST(f.PageSpaceUsedPct AS DECIMAL(10,2)) AS PageSpaceUsedPct,
    f.RecordCount,
    f.FragmentCount,
    f.FillFactor,
    ISNULL(u.TotalReads, 0) AS TotalReads,
    ISNULL(u.user_updates, 0) AS TotalUpdates,

    CASE
        WHEN ISNULL(u.TotalReads, 0) = 0 THEN 'NO_READS_RECORDED'
        WHEN ISNULL(u.TotalReads, 0) < 100 THEN 'LOW_USAGE'
        WHEN ISNULL(u.TotalReads, 0) < 1000 THEN 'MEDIUM_USAGE'
        ELSE 'HIGH_USAGE'
    END AS UsageClassification,

    CASE
        WHEN ISNULL(u.TotalReads, 0) = 0
             AND ISNULL(u.user_updates, 0) > 10000
            THEN 'REVIEW_DROP_CANDIDATE'

        WHEN f.FragmentationPct > 30
             AND f.PageCount > 10000
            THEN 'REBUILD_PRIORITY'

        WHEN f.FragmentationPct > 30
            THEN 'REBUILD'

        WHEN f.FragmentationPct > 10
            THEN 'REORGANIZE'

        ELSE 'OK'
    END AS RecommendedAction,

    CASE
        WHEN f.FragmentationPct > 30
            THEN
                'ALTER INDEX '
                + QUOTENAME(f.IndexName)
                + ' ON '
                + QUOTENAME(f.SchemaName)
                + '.'
                + QUOTENAME(f.TableName)
                + ' REBUILD WITH (MAXDOP = 4);'

        WHEN f.FragmentationPct > 10
            THEN
                'ALTER INDEX '
                + QUOTENAME(f.IndexName)
                + ' ON '
                + QUOTENAME(f.SchemaName)
                + '.'
                + QUOTENAME(f.TableName)
                + ' REORGANIZE;'

        ELSE
            '-- No action required for '
            + QUOTENAME(f.SchemaName)
            + '.'
            + QUOTENAME(f.TableName)
            + ' / '
            + QUOTENAME(f.IndexName)
    END AS MaintenanceCommand,

    CASE
        WHEN f.FragmentationPct > 50
             AND ISNULL(u.TotalReads, 0) > 1000
            THEN 'CRITICAL'

        WHEN f.FragmentationPct > 30
             AND ISNULL(u.TotalReads, 0) > 100
            THEN 'HIGH'

        WHEN f.FragmentationPct > 10
             AND ISNULL(u.TotalReads, 0) > 0
            THEN 'MEDIUM'

        ELSE 'LOW'
    END AS PriorityLevel,

    u.last_user_seek,
    u.last_user_scan,
    u.last_user_lookup,
    u.last_user_update

FROM #Fragmentacao f
LEFT JOIN #UsoIndices u
    ON f.database_id = u.database_id
   AND f.object_id = u.object_id
   AND f.index_id = u.index_id
WHERE f.FragmentationPct >= @MinFragmentation
ORDER BY
    CASE
        WHEN f.FragmentationPct > 50 AND ISNULL(u.TotalReads, 0) > 1000 THEN 1
        WHEN f.FragmentationPct > 30 AND ISNULL(u.TotalReads, 0) > 100 THEN 2
        WHEN f.FragmentationPct > 10 THEN 3
        ELSE 4
    END,
    f.FragmentationPct DESC,
    f.PageCount DESC;

-- =============================================================================
-- 4. RESUMO EXECUTIVO
-- =============================================================================

SELECT
    'SPCAT41_SUMMARY' AS ReportType,
    COUNT(*) AS TotalIndexesAnalyzed,
    SUM(CASE WHEN FragmentationPct > 30 THEN 1 ELSE 0 END) AS NeedRebuild,
    SUM(CASE WHEN FragmentationPct > 10 AND FragmentationPct <= 30 THEN 1 ELSE 0 END) AS NeedReorganize,
    SUM(CASE WHEN FragmentationPct <= 10 THEN 1 ELSE 0 END) AS Healthy,
    CAST(AVG(FragmentationPct) AS DECIMAL(10,2)) AS AvgFragmentationPct,
    SUM(PageCount) AS TotalPagesAnalyzed
FROM #Fragmentacao
WHERE FragmentationPct >= @MinFragmentation;

-- =============================================================================
-- 5. LIMPEZA
-- =============================================================================

DROP TABLE IF EXISTS #Fragmentacao;
DROP TABLE IF EXISTS #UsoIndices;

-- =============================================================================
-- NOTAS POLYDEV:
-- 1. REBUILD ONLINE foi removido propositalmente para evitar erro por edição.
-- 2. Para Enterprise/Developer, o DBA pode incluir ONLINE = ON manualmente.
-- 3. Estatísticas de uso podem zerar após restart/failover.
-- 4. REVIEW_DROP_CANDIDATE nunca deve ser executado automaticamente.
-- 5. Execute preferencialmente fora do horário de pico.
-- =============================================================================

