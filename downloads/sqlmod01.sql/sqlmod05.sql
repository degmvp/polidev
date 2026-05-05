5. DENSE_RANK
Também cria ranking com empates, mas não pula posições.

SELECT 
    vendedor,
    total_vendas,
    DENSE_RANK() OVER (ORDER BY total_vendas DESC) AS ranking
FROM vendedores;