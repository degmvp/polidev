3. Unused Indexes (Índices Não Utilizados)
São índices que existem na base, ocupam espaço em disco e RAM (Buffer Pool), mas nunca (ou quase nunca) são usados nas consultas. Pior: todo INSERT, UPDATE ou DELETE precisa manter esse índice atualizado, gerando custo sem benefício.
Encontrar esses índices para excluí-los e liberar recursos.

SELECT 
    OBJECT_NAME(i.OBJECT_ID) AS Tabela,
    i.name AS Indice,
    i.type_desc AS Tipo,
    s.user_seeks, s.user_scans, s.user_lookups, s.user_updates
FROM sys.dm_db_index_usage_stats s
INNER JOIN sys.indexes i ON s.object_id = i.object_id AND s.index_id = i.index_id
WHERE OBJECTPROPERTY(i.OBJECT_ID, 'IsUserTable') = 1
  AND s.database_id = DB_ID()
  AND (s.user_seeks + s.user_scans + s.user_lookups) = 0 -- Nunca foi lido
  AND s.user_updates > 0 -- Mas foi escrito (custo sem benefício)
ORDER BY s.user_updates DESC;