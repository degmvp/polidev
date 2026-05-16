bbintel04.sql
SELECT
    s.name AS schema_name,
    o.name AS object_name,
    o.type_desc,
    o.create_date,
    o.modify_date,
    DATEDIFF(DAY, o.modify_date, GETDATE()) AS days_since_last_modify
FROM sys.objects o
INNER JOIN sys.schemas s
    ON s.schema_id = o.schema_id
WHERE o.is_ms_shipped = 0
  AND o.type IN ('P','V','FN','IF','TF','U')
ORDER BY
    days_since_last_modify DESC,
    s.name,
    o.name;