CREATE OR ALTER PROCEDURE dbo.bb_sp15_documentacao_automatica_objetos
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.name AS schema_name,
        o.name AS object_name,
        o.type_desc,
        o.create_date,
        o.modify_date,
        p.name AS parameter_name,
        TYPE_NAME(p.user_type_id) AS parameter_type,
        p.max_length,
        p.is_output
    FROM sys.objects o
    INNER JOIN sys.schemas s ON s.schema_id = o.schema_id
    LEFT JOIN sys.parameters p ON p.object_id = o.object_id
    WHERE o.type IN ('P','FN','IF','TF','V','U')
    ORDER BY s.name, o.type_desc, o.name, p.parameter_id;
END;
GO