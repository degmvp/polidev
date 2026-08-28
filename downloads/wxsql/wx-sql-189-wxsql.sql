tsql14.tsql
-- ============================================
-- T-SQL 14 - TABLE VARIABLE
-- ============================================

DECLARE @Produtos TABLE (
    id_produto INT,
    nome_produto VARCHAR(100),
    preco DECIMAL(18,2)
);

INSERT INTO @Produtos
VALUES
(1, 'Mouse', 80.00),
(2, 'Teclado', 150.00),
(3, 'Monitor', 900.00);

SELECT *
FROM @Produtos
WHERE preco >= 100;