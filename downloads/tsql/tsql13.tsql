tsql13.tsql
-- ============================================
-- T-SQL 13 - TEMP TABLE
-- ============================================

CREATE TABLE #ResumoVendas (
    vendedor VARCHAR(100),
    total DECIMAL(18,2)
);

INSERT INTO #ResumoVendas (vendedor, total)
SELECT
    vendedor,
    SUM(valor_venda)
FROM vendas
GROUP BY vendedor;

SELECT *
FROM #ResumoVendas
ORDER BY total DESC;

DROP TABLE #ResumoVendas;