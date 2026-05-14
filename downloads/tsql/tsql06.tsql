tsql06.tsql
-- ============================================
-- T-SQL 06 - RANK e DENSE_RANK
-- ============================================

SELECT
    vendedor,
    valor_venda,
    RANK() OVER (
        ORDER BY valor_venda DESC
    ) AS posicao_rank,
    DENSE_RANK() OVER (
        ORDER BY valor_venda DESC
    ) AS posicao_dense
FROM vendas;