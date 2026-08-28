-- fn08.tsql
-- Diferença percentual segura
CREATE OR ALTER FUNCTION dbo.fn08_variacao_percentual
(
    @valor_anterior DECIMAL(18,4),
    @valor_atual    DECIMAL(18,4)
)
RETURNS DECIMAL(18,4)
AS
BEGIN
    RETURN CASE 
        WHEN @valor_anterior = 0 THEN NULL
        ELSE ((@valor_atual - @valor_anterior) / @valor_anterior) * 100
    END;
END;
GO