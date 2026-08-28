16. MERGE
Comando moderno para sincronizar dados entre tabelas.

MERGE INTO clientes c
USING novos_clientes n
ON c.email = n.email
WHEN MATCHED THEN
    UPDATE SET nome = n.nome
WHEN NOT MATCHED THEN
    INSERT (email, nome)
    VALUES (n.email, n.nome);