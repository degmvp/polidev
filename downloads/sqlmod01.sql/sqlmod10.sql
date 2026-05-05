10. STRING_AGG
Concatena valores de várias linhas em uma única linha. Excelente para relatórios.

SELECT 
    funcionario,
    STRING_AGG(salario::text, ' - ' ORDER BY mes) AS ficha_financeira
FROM folha_pagamento
GROUP BY funcionario;