CREATE OR ALTER FUNCTION dbo.bb_fn01_split_string
(
    @texto NVARCHAR(MAX),
    @delimitador NCHAR(1)
)
RETURNS @resultado TABLE
(
    id INT IDENTITY(1,1),
    valor NVARCHAR(MAX)
)
AS
BEGIN
    DECLARE @pos INT;

    WHILE LEN(@texto) > 0
    BEGIN
        SET @pos = CHARINDEX(@delimitador, @texto);

        IF @pos = 0
        BEGIN
            INSERT INTO @resultado(valor) VALUES (LTRIM(RTRIM(@texto)));
            BREAK;
        END;

        INSERT INTO @resultado(valor)
        VALUES (LTRIM(RTRIM(SUBSTRING(@texto, 1, @pos - 1))));

        SET @texto = SUBSTRING(@texto, @pos + 1, LEN(@texto));
    END;

    RETURN;
END;
GO