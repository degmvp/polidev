17. JSON no SQL
Permite consultar dados armazenados em formato JSON.

SELECT 
    dados->>'nome' AS nome,
    dados->>'cidade' AS cidade
FROM clientes_json;