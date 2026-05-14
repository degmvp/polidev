tsql08.tsql
-- ============================================
-- T-SQL 08 - LAG e LEAD
-- ============================================

SELECT
    data_venda,
    valor_venda,
    LAG(valor_venda) OVER (
        ORDER BY data_venda
    ) AS venda_anterior,
    LEAD(valor_venda) OVER (
        ORDER BY data_venda
    ) AS proxima_venda
FROM vendas;