-- fn14.tsql
-- Calcula score de cliente
CREATE OR ALTER FUNCTION dbo.fn14_score_cliente
(
    @total_compras DECIMAL(18,2),
    @qtd_pedidos INT,
    @dias_sem_compra INT
)
RETURNS INT
AS
BEGIN
    DECLARE @score INT = 0;

    SET @score += CASE WHEN @total_compras >= 10000 THEN 40
                       WHEN @total_compras >= 5000 THEN 30
                       WHEN @total_compras >= 1000 THEN 20
                       ELSE 10 END;

    SET @score += CASE WHEN @qtd_pedidos >= 20 THEN 30
                       WHEN @qtd_pedidos >= 10 THEN 20
                       ELSE 10 END;

    SET @score -= CASE WHEN @dias_sem_compra > 180 THEN 30
                       WHEN @dias_sem_compra > 90 THEN 15
                       ELSE 0 END;

    RETURN CASE WHEN @score < 0 THEN 0 WHEN @score > 100 THEN 100 ELSE @score END;
END;
GO