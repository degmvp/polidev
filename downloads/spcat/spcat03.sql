/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER

Arquivo.........: spcat03.sql
Título..........: Catalog Explorer - List Procedures
Procedure.......: poly_cat_ListProcedures
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Listar todas as stored procedures existentes no banco atual.

Aplicações:
- Inventário de procedures
- Engenharia reversa
- Auditoria técnica
- Documentação automática

Catálogo utilizado:
sys.procedures
sys.schemas
sys.sql_modules

Execução:
EXEC poly_cat_ListProcedures;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_ListProcedures
AS
BEGIN
SET NOCOUNT ON;

```
SELECT
    s.name AS SchemaName,
    p.name AS ProcedureName,
    m.definition AS ProcedureDefinition
FROM sys.procedures p
     INNER JOIN sys.schemas s
        ON p.schema_id = s.schema_id
     INNER JOIN sys.sql_modules m
        ON p.object_id = m.object_id
ORDER BY
    s.name,
    p.name;
```

END;
GO

EXEC poly_cat_ListProcedures;
GO
