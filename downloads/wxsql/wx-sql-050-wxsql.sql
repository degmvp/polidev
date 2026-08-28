-- fn15.tsql
-- Retorna calendário entre duas datas
CREATE OR ALTER FUNCTION dbo.fn15_calendario (@inicio DATE, @fim DATE)
RETURNS @cal TABLE
(
    data_ref DATE,
    ano INT,
    mes INT,
    dia INT,
    nome_mes VARCHAR(20),
    dia_semana VARCHAR(20),
    fim_semana BIT
)
AS
BEGIN
    WHILE @inicio <= @fim
    BEGIN
        INSERT INTO @cal
        SELECT
            @inicio,
            YEAR(@inicio),
            MONTH(@inicio),
            DAY(@inicio),
            DATENAME(MONTH, @inicio),
            DATENAME(WEEKDAY, @inicio),
            CASE WHEN DATENAME(WEEKDAY, @inicio) IN ('Saturday','Sunday') THEN 1 ELSE 0 END;

        SET @inicio = DATEADD(DAY, 1, @inicio);
    END;

    RETURN;
END;
GO