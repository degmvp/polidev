-- fn07.tsql
-- Último dia do mês
CREATE OR ALTER FUNCTION dbo.fn07_ultimo_dia_mes (@data DATE)
RETURNS DATE
AS
BEGIN
    RETURN EOMONTH(@data);
END;
GO