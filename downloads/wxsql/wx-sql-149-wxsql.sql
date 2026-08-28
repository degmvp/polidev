9. PARTITION BY
Divide os cálculos por grupos, como departamento, categoria ou funcionário.

SELECT 
    departamento,
    nome,
    salario,
    AVG(salario) OVER (PARTITION BY departamento) AS media_departamento
FROM funcionarios;