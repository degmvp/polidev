bbintel05.sql
SELECT
    s.name AS schema_name,
    COUNT(o.object_id) AS total_objects,
    SUM(CASE WHEN o.type = 'U' THEN 1 ELSE 0 END) AS total_tables,
    SUM(CASE WHEN o.type = 'V' THEN 1 ELSE 0 END) AS total_views,
    SUM(CASE WHEN o.type = 'P' THEN 1 ELSE 0 END) AS total_procedures,
    SUM(CASE WHEN o.type IN ('FN','IF','TF') THEN 1 ELSE 0 END) AS total_functions,
    MIN(o.create_date) AS first_object_created,
    MAX(o.modify_date) AS last_object_modified
FROM sys.schemas s
LEFT JOIN sys.objects o
    ON o.schema_id = s.schema_id
   AND o.is_ms_shipped = 0
GROUP BY
    s.name
ORDER BY
    total_objects DESC,
    s.name;