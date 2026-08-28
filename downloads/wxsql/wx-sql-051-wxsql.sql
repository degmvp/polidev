CREATE OR ALTER PROCEDURE dbo.bb_sp01_seek_all
    @texto NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.name AS schema_name,
        o.name AS object_name,
        o.type_desc,
        o.create_date,
        o.modify_date
    FROM sys.objects o
    INNER JOIN sys.schemas s ON s.schema_id = o.schema_id
    WHERE o.name LIKE '%' + @texto + '%'
    ORDER BY o.type_desc, s.name, o.name;
END;
GO