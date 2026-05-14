-- fn10.tsql
-- Divide string CSV em tabela
CREATE OR ALTER FUNCTION dbo.fn10_split_csv (@lista VARCHAR(MAX))
RETURNS @t TABLE (id INT IDENTITY(1,1), valor VARCHAR(200))
AS
BEGIN
    DECLARE @xml XML;

    SET @xml = CAST('<x>' + REPLACE(@lista, ',', '</x><x>') + '</x>' AS XML);

    INSERT INTO @t(valor)
    SELECT LTRIM(RTRIM(N.value('.', 'VARCHAR(200)')))
    FROM @xml.nodes('/x') AS T(N);

    RETURN;
END;
GO