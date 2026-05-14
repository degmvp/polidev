-- fn09.tsql
-- Classifica faixa de valor
CREATE OR ALTER FUNCTION dbo.fn09_faixa_valor (@valor DECIMAL(18,2))
RETURNS VARCHAR(20)
AS
BEGIN
    RETURN CASE
        WHEN @valor IS NULL THEN 'INDEFINIDO'
        WHEN @valor < 100 THEN 'BAIXO'
        WHEN @valor < 1000 THEN 'MEDIO'
        WHEN @valor < 10000 THEN 'ALTO'
        ELSE 'PREMIUM'
    END;
END;
GO