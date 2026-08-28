12. FILTER em agregações
Permite somar ou contar apenas registros que atendem a uma condição.

SELECT 
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE status = 'ativo') AS ativos,
    COUNT(*) FILTER (WHERE status = 'inativo') AS inativos
FROM clientes;