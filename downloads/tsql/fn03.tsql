-- fn03.tsql
-- Remove caracteres não numéricos
CREATE OR ALTER FUNCTION dbo.fn03_somente_numeros (@texto VARCHAR(100))
RETURNS VARCHAR(100)
AS
BEGIN
    DECLARE @i INT = 1, @r VARCHAR(100) = '';

    WHILE @i <= LEN(@texto)
    BEGIN
        IF SUBSTRING(@texto, @i, 1) LIKE '[0-9]'
            SET @r += SUBSTRING(@texto, @i, 1);

        SET @i += 1;
    END;

    RETURN @r;
END;
GO