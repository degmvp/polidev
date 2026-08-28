CREATE OR ALTER VIEW dbo.bb_vw04_indices_principais
AS
SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS schema_name,
    OBJECT_NAME(i.object_id) AS table_name,
    i.name AS index_name,
    i.type_desc,
    i.is_primary_key,
    i.is_unique,
    i.fill_factor
FROM sys.indexes i
WHERE i.index_id > 0;
GO