bbintel02.sql
SELECT
    OBJECT_SCHEMA_NAME(d.referencing_id) AS referencing_schema,
    OBJECT_NAME(d.referencing_id) AS referencing_object,
    o.type_desc AS referencing_type,
    d.referenced_schema_name,
    d.referenced_entity_name,
    d.referenced_database_name,
    d.referenced_server_name
FROM sys.sql_expression_dependencies d
LEFT JOIN sys.objects o
    ON o.object_id = d.referencing_id
ORDER BY
    referencing_schema,
    referencing_object,
    d.referenced_schema_name,
    d.referenced_entity_name;