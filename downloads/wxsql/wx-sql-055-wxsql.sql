CREATE OR ALTER PROCEDURE dbo.bb_sp05_tamanho_tabelas
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.name AS schema_name,
        t.name AS table_name,
        SUM(p.rows) AS total_rows,
        CAST(SUM(a.total_pages) * 8.0 / 1024 AS DECIMAL(18,2)) AS total_mb,
        CAST(SUM(a.used_pages) * 8.0 / 1024 AS DECIMAL(18,2)) AS used_mb,
        CAST((SUM(a.total_pages) - SUM(a.used_pages)) * 8.0 / 1024 AS DECIMAL(18,2)) AS unused_mb
    FROM sys.tables t
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.indexes i ON t.object_id = i.object_id
    INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
    INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
    GROUP BY s.name, t.name
    ORDER BY total_mb DESC;
END;
GO