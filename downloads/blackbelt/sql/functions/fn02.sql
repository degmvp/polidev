CREATE OR ALTER FUNCTION dbo.bb_fn02_somente_numeros
(
    @texto NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @i INT = 1;
    DECLARE @saida NVARCHAR(MAX) = '';
    DECLARE @c NCHAR(1);

    WHILE @i <= LEN(@texto)
    BEGIN
        SET @c = SUBSTRING(@texto, @i, 1);

        IF @c LIKE '[0-9]'
            SET @saida += @c;

        SET @i += 1;
    END;

    RETURN @saida;
END;
GO