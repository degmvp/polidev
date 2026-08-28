-- fn13.tsql
-- Máscara simples para telefone brasileiro
CREATE OR ALTER FUNCTION dbo.fn13_formatar_telefone (@telefone VARCHAR(30))
RETURNS VARCHAR(20)
AS
BEGIN
    SET @telefone = dbo.fn03_somente_numeros(@telefone);

    RETURN CASE
        WHEN LEN(@telefone) = 11
        THEN '(' + LEFT(@telefone,2) + ') ' + SUBSTRING(@telefone,3,5) + '-' + RIGHT(@telefone,4)
        WHEN LEN(@telefone) = 10
        THEN '(' + LEFT(@telefone,2) + ') ' + SUBSTRING(@telefone,3,4) + '-' + RIGHT(@telefone,4)
        ELSE @telefone
    END;
END;
GO