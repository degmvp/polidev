bbmon08.sql
SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS schema_name,
    OBJECT_NAME(i.object_id) AS table_name,
    i.name AS index_name,
    ius.user_seeks,
    ius.user_scans,
    ius.user_lookups,
    ius.user_updates
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats ius
    ON ius.object_id = i.object_id
   AND ius.index_id = i.index_id
   AND ius.database_id = DB_ID()
WHERE i.index_id > 0
  AND i.is_primary_key = 0
  AND i.is_unique_constraint = 0
  AND OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1
ORDER BY
    ISNULL(ius.user_seeks,0) + ISNULL(ius.user_scans,0) + ISNULL(ius.user_lookups,0),
    ius.user_updates DESC;