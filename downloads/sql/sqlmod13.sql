13. COALESCE
Substitui valores nulos por um valor padrão.

SELECT 
    nome,
    COALESCE(telefone, 'Sem telefone') AS telefone
FROM clientes;