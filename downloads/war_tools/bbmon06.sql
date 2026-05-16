bbmon06.sql
SELECT
    DB_NAME(database_id) AS database_name,
    name AS logical_name,
    type_desc,
    physical_name,
    size * 8 / 1024 AS size_mb,
    max_size,
    growth,
    is_percent_growth
FROM sys.master_files
ORDER BY database_name, type_desc, logical_name;