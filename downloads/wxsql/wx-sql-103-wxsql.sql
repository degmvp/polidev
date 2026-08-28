9. DMVs (Dynamic Management Views)
São "visões" do sistema que permitem monitorar a saúde, performance e o estado interno do SQL Server em tempo real. Elas são a base de tudo o que vimos acima (Missing Indexes, Unused, Fragmentação vêm delas).
As principais para índices começam com sys.dm_db_index_...

-- Exemplo: Ver o custo de I/O gerado pelos índices (ajuda a achar gargalos)
SELECT 
    OBJECT_NAME(i.object_id) AS Tabela,
    i.name AS Indice,
    ios.logical_reads, ios.physical_reads
FROM sys.dm_db_index_operational_stats(DB_ID(), NULL, NULL, NULL) ios
INNER JOIN sys.indexes i ON i.object_id = ios.object_id AND i.index_id = ios.index_id
WHERE ios.database_id = DB_ID()
ORDER BY ios.logical_reads DESC;