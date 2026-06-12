4. Fill Factor (Fator de Preenchimento)
Define a porcentagem de espaço em cada página de folha do índice que será preenchida com dados, deixando o resto livre para futuros crescimentos (evitando Page Splits, que geram fragmentação). O padrão é 0 (ou 100%).
Usado em tabelas com muita concorrência de escrita (OLTP). Se o Fill Factor for 90, ele deixa 10% livre. Ao criar ou recriar:

-- Criando com Fill Factor de 80%
CREATE NONCLUSTERED INDEX IX_Cliente_Email 
ON Clientes (Email) 
WITH (FILLFACTOR = 80);

-- Alterando um índice existente
ALTER INDEX IX_Cliente_Email ON Clientes REBUILD WITH (FILLFACTOR = 80);