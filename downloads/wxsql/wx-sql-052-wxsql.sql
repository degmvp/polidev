CREATE OR ALTER PROCEDURE dbo.bb_sp02_busca_colunas
    @coluna NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.name AS schema_name,
        t.name AS table_name,
        c.name AS column_name,
        ty.name AS data_type,
        c.max_length,
        c.is_nullable
    FROM sys.columns c
    INNER JOIN sys.objects t ON t.object_id = c.object_id
    INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
    INNER JOIN sys.types ty ON ty.user_type_id = c.user_type_id
    WHERE c.name LIKE '%' + @coluna + '%'
      AND t.type IN ('U','V')
    ORDER BY s.name, t.name, c.column_id;
END;
GO