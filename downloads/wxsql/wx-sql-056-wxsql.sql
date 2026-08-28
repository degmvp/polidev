CREATE OR ALTER PROCEDURE dbo.bb_sp06_indices_fragmentados
    @min_fragmentacao DECIMAL(5,2) = 10.0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        DB_NAME() AS database_name,
        OBJECT_SCHEMA_NAME(ips.object_id) AS schema_name,
        OBJECT_NAME(ips.object_id) AS table_name,
        i.name AS index_name,
        ips.index_type_desc,
        ips.avg_fragmentation_in_percent,
        ips.page_count
    FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') ips
    INNER JOIN sys.indexes i
        ON i.object_id = ips.object_id
       AND i.index_id = ips.index_id
    WHERE ips.avg_fragmentation_in_percent >= @min_fragmentacao
      AND ips.page_count > 100
    ORDER BY ips.avg_fragmentation_in_percent DESC;
END;
GO