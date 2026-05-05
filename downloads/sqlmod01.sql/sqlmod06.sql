6. LAG
Busca o valor da linha anterior. Excelente para comparar mês atual com mês anterior.

SELECT 
    mes,
    valor,
    LAG(valor) OVER (ORDER BY mes) AS valor_mes_anterior
FROM vendas_mensais;