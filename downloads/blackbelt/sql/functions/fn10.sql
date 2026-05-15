CREATE OR ALTER FUNCTION dbo.bb_fn10_texto_seguro_sql
(
    @texto NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    RETURN REPLACE(@texto, '''', '''''');
END;
GO