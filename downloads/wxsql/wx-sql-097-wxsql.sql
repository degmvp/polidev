2. Missing Indexes (Índices Ausentes)
Descrição: O Otimizador de Consultas do SQL Server mantém um registro de índices que não existem, mas que ele calculou que fariam uma consulta rodar muito mais rápido.
Muito útil para DBAs descobrirem o que falta criar.

SELECT 
    mid.statement AS Tabela,
    mid.equality_columns AS Colunas_Igualdade,
    mid.inequality_columns AS Colunas_Desigualdade,
    mid.included_columns AS Colunas_Incluidas,
    migs.user_seeks AS Buscas_Potenciais,
    migs.avg_user_impact AS Impacto_Perc
FROM sys.dm_db_missing_index_details mid
INNER JOIN sys.dm_db_missing_index_groups mig ON mid.index_handle = mig.index_handle
INNER JOIN sys.dm_db_missing_index_group_stats migs ON mig.index_group_handle = migs.group_handle
WHERE migs.avg_user_impact > 70 -- Apenas os que teriam alto impacto
ORDER BY migs.user_seeks DESC;