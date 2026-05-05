4. RANK
Cria ranking permitindo empates. Quando há empate, pula posições.

SELECT 
    vendedor,
    total_vendas,
    RANK() OVER (ORDER BY total_vendas DESC) AS ranking
FROM vendedores;