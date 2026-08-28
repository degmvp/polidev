CREATE OR ALTER PROCEDURE dbo.bb_sp13_rebuild_reorganize_indice
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        OBJECT_SCHEMA_NAME(ips.object_id) AS schema_name,
        OBJECT_NAME(ips.object_id) AS table_name,
        i.name AS index_name,
        ips.avg_fragmentation_in_percent,
        ips.page_count,
        CASE
            WHEN ips.avg_fragmentation_in_percent >= 30 THEN
                'ALTER INDEX [' + i.name + '] ON [' +
                OBJECT_SCHEMA_NAME(ips.object_id) + '].[' +
                OBJECT_NAME(ips.object_id) + '] REBUILD;'
            WHEN ips.avg_fragmentation_in_percent >= 10 THEN
                'ALTER INDEX [' + i.name + '] ON [' +
                OBJECT_SCHEMA_NAME(ips.object_id) + '].[' +
                OBJECT_NAME(ips.object_id) + '] REORGANIZE;'
            ELSE
                '-- Sem ação necessária'
        END AS comando_sugerido
    FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
    INNER JOIN sys.indexes i
        ON i.object_id = ips.object_id
       AND i.index_id = ips.index_id
    WHERE ips.page_count > 100
      AND ips.index_id > 0
    ORDER BY ips.avg_fragmentation_in_percent DESC;
END;
GO