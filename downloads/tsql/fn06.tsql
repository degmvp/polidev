-- fn06.tsql
-- Primeiro dia do mês
CREATE OR ALTER FUNCTION dbo.fn06_primeiro_dia_mes (@data DATE)
RETURNS DATE
AS
BEGIN
    RETURN DATEFROMPARTS(YEAR(@data), MONTH(@data), 1);
END;
GO