-- fn12.tsql
-- Gera slug para URL
CREATE OR ALTER FUNCTION dbo.fn12_slug (@texto VARCHAR(300))
RETURNS VARCHAR(300)
AS
BEGIN
    SET @texto = LOWER(LTRIM(RTRIM(@texto)));
    SET @texto = REPLACE(@texto, ' ', '-');
    SET @texto = REPLACE(@texto, '--', '-');
    SET @texto = REPLACE(@texto, '.', '');
    SET @texto = REPLACE(@texto, ',', '');
    SET @texto = REPLACE(@texto, '/', '-');

    RETURN @texto;
END;
GO