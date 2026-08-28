tsql05.tsql
-- ============================================
-- T-SQL 05 - ROW_NUMBER
-- ============================================

SELECT
    ROW_NUMBER() OVER (
        PARTITION BY estado
        ORDER BY nome_cliente
    ) AS sequencia_estado,
    nome_cliente,
    estado
FROM clientes;