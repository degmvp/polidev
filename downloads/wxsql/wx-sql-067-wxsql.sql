/********************************************************************************************
POLYDEV - SQL SERVER CATALOG EXPLORER

Arquivo.........: spcat02.sql
Título..........: Catalog Explorer - List Views
Procedure.......: poly_cat_ListViews
Categoria.......: spcat
Versão..........: 1.0

Objetivo:
Listar todas as views existentes no banco atual.

Aplicações:
- Inventário de views
- Engenharia reversa
- Auditoria técnica
- Documentação automática

Catálogo utilizado:
sys.views
sys.schemas
sys.sql_modules

Execução:
EXEC poly_cat_ListViews;

********************************************************************************************/

CREATE OR ALTER PROCEDURE poly_cat_ListViews
AS
BEGIN
SET NOCOUNT ON;

```
SELECT
    s.name AS SchemaName,
    v.name AS ViewName,
    m.definition AS ViewDefinition
FROM sys.views v
     INNER JOIN sys.schemas s
        ON v.schema_id = s.schema_id
     INNER JOIN sys.sql_modules m
        ON v.object_id = m.object_id
ORDER BY
    s.name,
    v.name;
```

END;
GO

EXEC poly_cat_ListViews;
GO
