CREATE OR ALTER FUNCTION dbo.bb_fn07_normaliza_texto
(
    @texto NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    SET @texto = LTRIM(RTRIM(@texto));

    WHILE CHARINDEX('  ', @texto) > 0
        SET @texto = REPLACE(@texto, '  ', ' ');

    RETURN @texto;
END;
GO