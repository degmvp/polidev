3. ROW_NUMBER
Numera linhas conforme uma ordem definida. Muito usado para ranking e paginação.

SELECT 
    nome,
    salario,
    ROW_NUMBER() OVER (ORDER BY salario DESC) AS posicao
FROM funcionarios;