tsql07.tsql
-- ============================================
-- T-SQL 07 - SUM OVER
-- ============================================

SELECT
    data_venda,
    vendedor,
    valor_venda,
    SUM(valor_venda) OVER (
        PARTITION BY vendedor
        ORDER BY data_venda
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS acumulado_vendedor
FROM vendas
ORDER BY vendedor, data_venda;