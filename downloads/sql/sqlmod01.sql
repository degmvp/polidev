1. CTE - Common Table Expression
Permite criar uma consulta temporária nomeada, melhorando a organização do SQL.

WITH vendas_mes AS (
    SELECT vendedor, SUM(valor) AS total
    FROM vendas
    GROUP BY vendedor
)
SELECT *
FROM vendas_mes
WHERE total > 10000;
