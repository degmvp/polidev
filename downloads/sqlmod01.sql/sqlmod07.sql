7. LEAD
Busca o valor da próxima linha. Útil para projeções e comparações futuras.

SELECT 
    mes,
    valor,
    LEAD(valor) OVER (ORDER BY mes) AS valor_proximo_mes
FROM vendas_mensais;