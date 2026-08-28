-- fn01.tsql
-- Normaliza texto: tira espaços extras e coloca maiúsculo
CREATE OR ALTER FUNCTION dbo.fn01_normalizar_texto (@texto VARCHAR(500))
RETURNS VARCHAR(500)
AS
BEGIN
    RETURN UPPER(LTRIM(RTRIM(REPLACE(REPLACE(@texto, CHAR(13), ''), CHAR(10), ''))));
END;
GO