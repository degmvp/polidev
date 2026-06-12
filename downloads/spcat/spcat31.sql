1. Fragmentação
 Ocorre quando a ordem lógica das páginas de dados em um índice não corresponde à ordem física no disco (Fragmentação Externa) ou quando há muito espaço vazio dentro das páginas de dados (Fragmentação Interna). Acontece devido a INSERTs, UPDATEs e DELETEs constantes.
Uso/Exemplo: Índices muito fragmentados causam leituras de disco desnecessárias (mais I/O). Para verificar a fragmentação:

SELECT 
    OBJECT_NAME(ind.OBJECT_ID) AS Tabela,
    ind.name AS Indice,
    indexstats.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') indexstats
INNER JOIN sys.indexes ind ON ind.object_id = indexstats.object_id AND ind.index_id = indexstats.index_id
WHERE indexstats.avg_fragmentation_in_percent > 10 -- Filtro comum
ORDER BY indexstats.avg_fragmentation_in_percent DESC;
