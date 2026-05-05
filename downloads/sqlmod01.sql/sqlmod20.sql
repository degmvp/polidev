20. Consulta estilo PIVOT com SUM e CASE
Transforma linhas em colunas. Muito útil para ficha financeira, meses e relatórios anuais.

SELECT 
    nome,
    SUM(CASE WHEN mes = 1 THEN salario ELSE 0 END) AS jan,
    SUM(CASE WHEN mes = 2 THEN salario ELSE 0 END) AS fev,
    SUM(CASE WHEN mes = 3 THEN salario ELSE 0 END) AS mar,
    SUM(CASE WHEN mes = 4 THEN salario ELSE 0 END) AS abr,
    SUM(CASE WHEN mes = 5 THEN salario ELSE 0 END) AS mai,
    SUM(CASE WHEN mes = 6 THEN salario ELSE 0 END) AS jun,
    SUM(CASE WHEN mes = 7 THEN salario ELSE 0 END) AS jul,
    SUM(CASE WHEN mes = 8 THEN salario ELSE 0 END) AS ago,
    SUM(CASE WHEN mes = 9 THEN salario ELSE 0 END) AS set,
    SUM(CASE WHEN mes = 10 THEN salario ELSE 0 END) AS out,
    SUM(CASE WHEN mes = 11 THEN salario ELSE 0 END) AS nov,
    SUM(CASE WHEN mes = 12 THEN salario ELSE 0 END) AS dez,
    SUM(salario) AS total_ano
FROM folha_pagamento
GROUP BY nome;