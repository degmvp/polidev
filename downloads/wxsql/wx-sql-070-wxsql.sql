/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER

Arquivo.........: spcat04.sql
Título..........: Catalog Explorer - List Functions
Procedure.......: poly_cat_ListFunctions
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Listar todas as funções existentes no banco atual.

Aplicações:
- Inventário de funções
- Engenharia reversa
- Auditoria técnica
- Documentação automática

Catálogo utilizado:
sys.objects
sys.schemas
sys.sql_modules

Execução:
EXEC poly_cat_ListFunctions;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_ListFunctions
AS
BEGIN
SET NOCOUNT ON;

SELECT
    s.name AS SchemaName,
    f.name AS FunctionName,
    f.type AS FunctionType,
    f.type_desc AS FunctionDescription,
    m.definition AS FunctionDefinition
FROM sys.objects f
     INNER JOIN sys.schemas s
        ON f.schema_id = s.schema_id
     INNER JOIN sys.sql_modules m
        ON f.object_id = m.object_id
WHERE f.type IN ('FN','IF','TF')
ORDER BY
    s.name,
    f.name;

END;
GO

EXEC poly_cat_ListFunctions;
GO