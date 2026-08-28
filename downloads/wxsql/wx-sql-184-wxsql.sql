tsql09.tsql
-- ============================================
-- T-SQL 09 - PIVOT
-- ============================================

SELECT
    vendedor,
    [2024] AS vendas_2024,
    [2025] AS vendas_2025,
    [2026] AS vendas_2026
FROM (
    SELECT
        vendedor,
        YEAR(data_venda) AS ano,
        valor_venda
    FROM vendas
) origem
PIVOT (
    SUM(valor_venda)
    FOR ano IN ([2024], [2025], [2026])
) p;