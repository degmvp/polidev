-- fn02.tsql
-- Valida email básico
CREATE OR ALTER FUNCTION dbo.fn02_email_valido (@email VARCHAR(255))
RETURNS BIT
AS
BEGIN
    RETURN CASE
        WHEN @email LIKE '%_@_%._%' 
         AND @email NOT LIKE '% %'
         AND @email NOT LIKE '%@%@%'
        THEN 1 ELSE 0
    END;
END;
GO