CREATE OR ALTER FUNCTION dbo.bb_fn09_ultimo_dia_mes
(
    @data DATE
)
RETURNS DATE
AS
BEGIN
    RETURN EOMONTH(@data);
END;
GO