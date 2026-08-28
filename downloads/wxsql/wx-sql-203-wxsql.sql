CREATE OR ALTER VIEW dbo.bb_vw03_tamanho_tabelas
AS
SELECT
    s.name AS schema_name,
    t.name AS table_name,
    SUM(p.rows) AS total_rows,
    CAST(SUM(a.total_pages) * 8.0 / 1024 AS DECIMAL(18,2)) AS total_mb
FROM sys.tables t
INNER JOIN sys.schemas s
    ON s.schema_id = t.schema_id
INNER JOIN sys.indexes i
    ON i.object_id = t.object_id
INNER JOIN sys.partitions p
    ON p.object_id = i.object_id
   AND p.index_id = i.index_id
INNER JOIN sys.allocation_units a
    ON a.container_id = p.partition_id
GROUP BY s.name, t.name;
GO