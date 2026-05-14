tsql10.tsql
-- ============================================
-- T-SQL 10 - MERGE
-- ============================================

MERGE clientes AS destino
USING clientes_importacao AS origem
ON destino.id_cliente = origem.id_cliente

WHEN MATCHED THEN
    UPDATE SET
        destino.nome_cliente = origem.nome_cliente,
        destino.cidade = origem.cidade,
        destino.estado = origem.estado

WHEN NOT MATCHED THEN
    INSERT (id_cliente, nome_cliente, cidade, estado)
    VALUES (
        origem.id_cliente,
        origem.nome_cliente,
        origem.cidade,
        origem.estado
    );