5. Seek vs Scan
Descrição:

Index Seek (Busca): O SQL Server usa a estrutura em árvore (B-Tree) do índice para ir direto ao dado desejado. É extremamente rápido (como procurar uma palavra no dicionário).
Index Scan (Escaneamento): O SQL Server lê o índice inteiro do começo ao fim. É lento, mas às vezes necessário (como ler todo um livro).

Gera SEEK: SELECT * FROM Clientes WHERE ID = 123 (O ID geralmente é a Chave Primária com índice clusterizado).
Gera SCAN: SELECT * FROM Clientes WHERE Nome LIKE '%Silva%' (O % no início impede o uso da árvore do índice, forçando a leitura completa).