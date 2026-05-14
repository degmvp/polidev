tsql02.tsql
-- ============================================
-- T-SQL 02 - CASE WHEN
-- ============================================

SELECT
    id_pedido,
    valor_total,
    CASE
        WHEN valor_total >= 10000 THEN 'ALTO'
        WHEN valor_total >= 3000  THEN 'MEDIO'
        ELSE 'BAIXO'
    END AS faixa_valor
FROM pedidos
ORDER BY valor_total DESC;