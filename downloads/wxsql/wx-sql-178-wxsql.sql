tsql03.tsql
-- ============================================
-- T-SQL 03 - CTE Simples
-- ============================================

WITH vendas_cliente AS (
    SELECT
        id_cliente,
        SUM(valor_total) AS total_vendas
    FROM pedidos
    GROUP BY id_cliente
)
SELECT
    c.nome_cliente,
    v.total_vendas
FROM vendas_cliente v
JOIN clientes c
    ON c.id_cliente = v.id_cliente
ORDER BY v.total_vendas DESC;