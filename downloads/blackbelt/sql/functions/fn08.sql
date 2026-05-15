CREATE OR ALTER FUNCTION dbo.bb_fn08_primeiro_dia_mes
(
    @data DATE
)
RETURNS DATE
AS
BEGIN
    RETURN DATEFROMPARTS(YEAR(@data), MONTH(@data), 1);
END;
GO