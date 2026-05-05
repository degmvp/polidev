19. CUBE
Cria combinações automáticas de agrupamentos, útil em relatórios analíticos.

SELECT 
    categoria,
    regiao,
    SUM(valor) AS total
FROM vendas
GROUP BY CUBE (categoria, regiao);