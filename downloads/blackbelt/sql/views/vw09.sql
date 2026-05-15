CREATE OR ALTER VIEW dbo.bb_vw09_procedures_functions
AS
SELECT
    s.name AS schema_name,
    o.name AS object_name,
    o.type_desc,
    o.create_date,
    o.modify_date
FROM sys.objects o
INNER JOIN sys.schemas s
    ON s.schema_id = o.schema_id
WHERE o.type IN ('P','FN','IF','TF');
GO