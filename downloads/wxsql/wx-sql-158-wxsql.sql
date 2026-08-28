18. GROUPING SETS
Gera vários agrupamentos em uma única consulta.

SELECT 
    categoria,
    vendedor,
    SUM(valor) AS total
FROM vendas
GROUP BY GROUPING SETS (
    (categoria),
    (vendedor),
    (categoria, vendedor),
    ()
);