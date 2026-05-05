14. NULLIF
Evita erros como divisão por zero, transformando um valor em NULL.

SELECT 
    produto,
    vendas,
    estoque,
    vendas / NULLIF(estoque, 0) AS giro_estoque
FROM produtos;