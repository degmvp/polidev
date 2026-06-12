7. Rebuild (Reconstrução)
Descarta o índice antigo e cria um novo do zero. Elimina 100% da fragmentação (interna e externa) e recria as estatísticas. É uma operação pesada e bloqueante (por padrão).
Deve ser usado quando a fragmentação está muito alta (geralmente acima de 30%).

-- Rebuild Offline (padrão, bloqueia a tabela para gravações)
ALTER INDEX IX_Cliente_Email ON Clientes REBUILD;

-- Rebuild Online (não bloqueia a tabela, requer Enterprise Edition ou SQL Azure)
ALTER INDEX IX_Cliente_Email ON Clientes REBUILD WITH (ONLINE = ON);