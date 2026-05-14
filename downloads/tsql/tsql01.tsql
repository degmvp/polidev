tsql01.tsql
-- ============================================
-- T-SQL 01 - SELECT Avançado
-- ============================================

SELECT
    id_cliente,
    nome_cliente AS cliente,
    cidade,
    estado,
    ativo
FROM clientes
WHERE ativo = 1
  AND estado IN ('SP', 'RJ', 'MG')
ORDER BY estado, nome_cliente;