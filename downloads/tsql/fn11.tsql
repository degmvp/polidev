-- fn11.tsql
-- Retorna dias úteis entre duas datas, desconsiderando sábado/domingo
CREATE OR ALTER FUNCTION dbo.fn11_dias_uteis (@inicio DATE, @fim DATE)
RETURNS INT
AS
BEGIN
    DECLARE @d DATE = @inicio;
    DECLARE @total INT = 0;

    WHILE @d <= @fim
    BEGIN
        IF DATENAME(WEEKDAY, @d) NOT IN ('Saturday', 'Sunday')
            SET @total += 1;

        SET @d = DATEADD(DAY, 1, @d);
    END;

    RETURN @total;
END;
GO