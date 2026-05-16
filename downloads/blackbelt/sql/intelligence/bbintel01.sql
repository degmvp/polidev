bbintel01.sql
SELECT
    s.name AS schema_name,
    o.name AS object_name,
    o.type,
    o.type_desc,
    o.create_date,
    o.modify_date
FROM sys.objects o
INNER JOIN sys.schemas s
    ON s.schema_id = o.schema_id
WHERE o.is_ms_shipped = 0
ORDER BY
    s.name,
    o.type_desc,
    o.name;