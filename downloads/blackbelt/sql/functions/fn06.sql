CREATE OR ALTER FUNCTION dbo.bb_fn06_nome_objeto_completo
(
    @schema SYSNAME,
    @objeto SYSNAME
)
RETURNS NVARCHAR(300)
AS
BEGIN
    RETURN QUOTENAME(@schema) + '.' + QUOTENAME(@objeto);
END;
GO