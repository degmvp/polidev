-- fn04.tsql
-- Formata CPF
CREATE OR ALTER FUNCTION dbo.fn04_formatar_cpf (@cpf VARCHAR(20))
RETURNS VARCHAR(14)
AS
BEGIN
    SET @cpf = dbo.fn03_somente_numeros(@cpf);

    RETURN CASE 
        WHEN LEN(@cpf) = 11
        THEN STUFF(STUFF(STUFF(@cpf,4,0,'.'),8,0,'.'),12,0,'-')
        ELSE @cpf
    END;
END;
GO