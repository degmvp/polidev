8. SUM com OVER
Calcula acumulados sem precisar de subqueries complexas.

SELECT 
    mes,
    valor,
    SUM(valor) OVER (ORDER BY mes) AS acumulado
FROM vendas_mensais;