CREATE OR ALTER PROCEDURE dbo.bb_sp03_dependencias_objetos
    @objeto NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        OBJECT_SCHEMA_NAME(d.referencing_id) AS referencing_schema,
        OBJECT_NAME(d.referencing_id) AS referencing_object,
        o.type_desc AS referencing_type,
        d.referenced_schema_name,
        d.referenced_entity_name,
        d.referenced_database_name
    FROM sys.sql_expression_dependencies d
    LEFT JOIN sys.objects o ON o.object_id = d.referencing_id
    WHERE OBJECT_NAME(d.referencing_id) LIKE '%' + @objeto + '%'
       OR d.referenced_entity_name LIKE '%' + @objeto + '%'
    ORDER BY referencing_schema, referencing_object;
END;
GO