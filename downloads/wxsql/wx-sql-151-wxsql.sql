11. CASE WHEN
Permite criar lógica condicional diretamente no SQL.

SELECT 
    nome,
    salario,
    CASE 
        WHEN salario >= 10000 THEN 'Alto'
        WHEN salario >= 5000 THEN 'Médio'
        ELSE 'Baixo'
    END AS faixa_salarial
FROM funcionarios;