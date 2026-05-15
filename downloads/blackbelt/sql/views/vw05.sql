CREATE OR ALTER VIEW dbo.bb_vw05_dependencias
AS
SELECT
    OBJECT_SCHEMA_NAME(d.referencing_id) AS referencing_schema,
    OBJECT_NAME(d.referencing_id) AS referencing_object,
    d.referenced_schema_name,
    d.referenced_entity_name
FROM sys.sql_expression_dependencies d;
GO