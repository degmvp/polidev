-- fn05.tsql
-- Calcula idade correta considerando aniversário
CREATE OR ALTER FUNCTION dbo.fn05_idade (@nascimento DATE)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(YEAR, @nascimento, GETDATE())
           - CASE 
                WHEN DATEADD(YEAR, DATEDIFF(YEAR, @nascimento, GETDATE()), @nascimento) > GETDATE()
                THEN 1 ELSE 0
             END;
END;
GO