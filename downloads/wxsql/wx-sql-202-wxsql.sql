CREATE OR ALTER VIEW dbo.bb_vw02_colunas_detalhadas
AS
SELECT
    s.name AS schema_name,
    t.name AS table_name,
    c.name AS column_name,
    ty.name AS data_type,
    c.max_length,
    c.precision,
    c.scale,
    c.is_nullable
FROM sys.columns c
INNER JOIN sys.objects t
    ON t.object_id = c.object_id
INNER JOIN sys.schemas s
    ON s.schema_id = t.schema_id
INNER JOIN sys.types ty
    ON ty.user_type_id = c.user_type_id
WHERE t.type IN ('U','V');
GO